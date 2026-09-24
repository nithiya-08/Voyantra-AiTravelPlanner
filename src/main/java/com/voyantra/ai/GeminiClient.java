package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONObject;

import com.voyantra.util.AppConfig;

/**
 * Shared low-level Gemini API caller, used by both the itinerary generator
 * and the chatbot, so the HTTP/retry/parsing logic lives in one place.
 */
public class GeminiClient {

    private static final String API_KEY =
        AppConfig.get("GEMINI_API_KEY", "YOUR_GEMINI_API_KEY_HERE");

    private static final String URL_STRING =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent?key=" + API_KEY;

    /**
     * Sends a prompt to Gemini and returns the cleaned text reply
     * (markdown code fences stripped, if the model added any).
     */
    public static String generateRaw(String prompt) throws Exception {
        String rawResponse = callGeminiWithRetry(prompt, 3);

        JSONObject fullResponse = new JSONObject(rawResponse);
        String aiText = fullResponse
            .getJSONArray("candidates")
            .getJSONObject(0)
            .getJSONObject("content")
            .getJSONArray("parts")
            .getJSONObject(0)
            .getString("text");

        aiText = aiText.trim();
        if (aiText.startsWith("```")) {
            aiText = aiText.replaceAll("```json", "").replaceAll("```", "").trim();
        }
        return aiText;
    }

    // ---- Retries the Gemini call a few times if the server is temporarily busy (503) ----
    private static String callGeminiWithRetry(String prompt, int maxAttempts) throws Exception {
        Exception lastError = null;
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                return callGemini(prompt);
            } catch (Exception e) {
                lastError = e;
                boolean isBusy = e.getMessage() != null && e.getMessage().contains("503");
                if (isBusy && attempt < maxAttempts) {
                    try {
                        Thread.sleep(2000L * attempt);
                    } catch (InterruptedException ignored) {}
                    continue;
                }
                throw e;
            }
        }
        throw lastError;
    }

    private static String callGemini(String prompt) throws Exception {
        String escapedPrompt = prompt.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ");
        String jsonBody = "{"
            + "\"contents\": [{"
            + "  \"parts\": [{ \"text\": \"" + escapedPrompt + "\" }]"
            + "}]"
            + "}";

        URL url = new URL(URL_STRING);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);
        conn.setConnectTimeout(8000);
        // Measured real-world latency on this model has gone as high as ~29s
        // even for a successful, short response — a 25s timeout was killing
        // calls right before they would have succeeded. 45s gives headroom
        // for a full multi-day itinerary, which generates more text than a
        // short prompt and so can take even longer.
        conn.setReadTimeout(45000);

        try (OutputStream os = conn.getOutputStream()) {
            byte[] input = jsonBody.getBytes("utf-8");
            os.write(input, 0, input.length);
        }

        int responseCode = conn.getResponseCode();
        BufferedReader reader;
        if (responseCode == 200) {
            reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
        } else {
            reader = new BufferedReader(new InputStreamReader(conn.getErrorStream(), "utf-8"));
        }

        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();

        if (responseCode != 200) {
            throw new Exception("Gemini API error (" + responseCode + "): " + response.toString());
        }

        return response.toString();
    }
}

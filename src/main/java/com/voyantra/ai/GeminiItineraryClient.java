package com.voyantra.ai;

import org.json.JSONArray;

public class GeminiItineraryClient {

    /**
     * Sends trip details to Gemini and returns a JSONArray of days, e.g.:
     * [
     *   {"day": 1, "activities": "...", "food": "...", "hotel": "...", "weather": "..."},
     *   ...
     * ]
     */
    public JSONArray generateItinerary(String destination, double budget, int numDays,
                                        String travelStyle, String interests) throws Exception {

        String prompt = "Create a " + numDays + "-day travel itinerary for " + destination + ". "
            + "Budget: Rs " + (int) budget + " total. Travel style: " + travelStyle + ". "
            + "Interests: " + interests + ". "
            + "Respond with ONLY a valid JSON array, no markdown, no explanation, no code fences. "
            + "Each element must have exactly these keys: "
            + "\"day\" (number), \"activities\" (string), \"food\" (string), "
            + "\"hotel\" (string), \"weather\" (string). "
            + "Example format: "
            + "[{\"day\":1,\"activities\":\"...\",\"food\":\"...\",\"hotel\":\"...\",\"weather\":\"...\"}]";

        String aiText = GeminiClient.generateRaw(prompt);
        return new JSONArray(aiText);
    }
}

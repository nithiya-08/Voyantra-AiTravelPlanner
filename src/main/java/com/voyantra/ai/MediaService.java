package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONArray;
import org.json.JSONObject;

import com.voyantra.util.AppConfig;
import com.voyantra.util.TtlCache;

public class MediaService {

    private static final String UNSPLASH_ACCESS_KEY =
        AppConfig.get("UNSPLASH_ACCESS_KEY", "YOUR_UNSPLASH_ACCESS_KEY_HERE");
    private static final String YOUTUBE_API_KEY =
        AppConfig.get("YOUTUBE_API_KEY", "YOUR_YOUTUBE_API_KEY_HERE");

    // A destination's photos/video don't change from one page view to the
    // next — cache them so every view of the same trip doesn't re-hit
    // Unsplash/YouTube.
    private static final TtlCache<String[]> IMAGE_CACHE = new TtlCache<>(24 * 60 * 60 * 1000L);
    private static final TtlCache<String> VIDEO_CACHE = new TtlCache<>(24 * 60 * 60 * 1000L);

    /**
     * Returns a direct image URL for the given destination, or null if it fails.
     */
    public static String[] getDestinationImages(String destination) {
        String cacheKey = destination.toLowerCase();
        String[] cached = IMAGE_CACHE.get(cacheKey);
        if (cached != null) return cached;
        try {
            String query = URLEncoder.encode(destination, "UTF-8");
            String urlString = "https://api.unsplash.com/search/photos?query=" + query
                + "&per_page=5&client_id=" + UNSPLASH_ACCESS_KEY;

            String response = callGet(urlString);
            if (response == null) return null;

            JSONObject json = new JSONObject(response);
            JSONArray results = json.getJSONArray("results");
            if (results.length() == 0) return null;

            String[] urls = new String[results.length()];
            for (int i = 0; i < results.length(); i++) {
                urls[i] = results.getJSONObject(i).getJSONObject("urls").getString("regular");
            }
            IMAGE_CACHE.put(cacheKey, urls);
            return urls;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    /**
     * Returns a YouTube video ID for a "<destination> travel guide" search,
     * or null if it fails. Use it to build an embed URL like:
     * https://www.youtube.com/embed/VIDEO_ID
     */
    public static String getDestinationVideoId(String destination) {
        String cacheKey = destination.toLowerCase();
        String cached = VIDEO_CACHE.get(cacheKey);
        if (cached != null) return cached;
        try {
            String query = URLEncoder.encode(destination + " travel guide", "UTF-8");
            String urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet"
                + "&q=" + query
                + "&type=video&maxResults=1&key=" + YOUTUBE_API_KEY;

            String response = callGet(urlString);
            if (response == null) return null;

            JSONObject json = new JSONObject(response);
            JSONArray items = json.getJSONArray("items");
            if (items.length() == 0) return null;

            String videoId = items.getJSONObject(0)
                .getJSONObject("id")
                .getString("videoId");
            VIDEO_CACHE.put(cacheKey, videoId);
            return videoId;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ---- Shared helper for simple GET requests ----
    private static String callGet(String urlString) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);

        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            return null;
        }

        BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
        StringBuilder response = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            response.append(line);
        }
        reader.close();
        return response.toString();
    }
}
package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import com.voyantra.util.AppConfig;

/**
 * Fallback recommendations from Google Places, used only when no approved
 * Voyantra vendor covers a destination yet — real Voyantra listings (with
 * reviews, verification badges, signature dishes) always take priority over
 * this. Reuses the same key as GoogleMapsService; if that key doesn't have
 * the Places API enabled, or the request fails for any reason, this returns
 * an empty list so the caller can fall back further (e.g. to the AI text
 * blurb) rather than breaking the page.
 */
public class GooglePlacesService {

    private static final String API_KEY = AppConfig.get("GOOGLE_MAPS_EMBED_KEY", "");

    public static boolean isConfigured() {
        return !API_KEY.trim().isEmpty();
    }

    public static List<Place> searchPlaces(String query) {
        List<Place> results = new ArrayList<>();
        if (!isConfigured()) return results;

        try {
            String encodedQuery = URLEncoder.encode(query, "UTF-8");
            String urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?query="
                + encodedQuery + "&key=" + API_KEY;

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(6000);
            conn.setReadTimeout(6000);

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) return results;

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) response.append(line);
            reader.close();

            JSONObject json = new JSONObject(response.toString());
            String status = json.optString("status", "");
            if (!"OK".equals(status)) return results; // ZERO_RESULTS, REQUEST_DENIED (API not enabled), etc.

            JSONArray arr = json.optJSONArray("results");
            if (arr == null) return results;

            for (int i = 0; i < Math.min(arr.length(), 3); i++) {
                JSONObject r = arr.getJSONObject(i);
                double rating = r.has("rating") ? r.optDouble("rating") : -1;
                results.add(new Place(
                    r.optString("name", ""),
                    rating,
                    r.optString("formatted_address", r.optString("vicinity", "")),
                    r.optString("place_id", "")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return results;
    }

    public static class Place {
        public final String name;
        public final double rating; // -1 if Google has no rating for this place
        public final String address;
        public final String placeId;

        public Place(String name, double rating, String address, String placeId) {
            this.name = name;
            this.rating = rating;
            this.address = address;
            this.placeId = placeId;
        }

        public String mapsUrl() {
            return "https://www.google.com/maps/place/?q=place_id:" + placeId;
        }
    }
}

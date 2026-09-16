package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.JSONArray;
import org.json.JSONObject;

public class GeocodingService {

    /**
     * Converts a place name into coordinates (and its country code, used for
     * currency conversion and the domestic/international checklist).
     * Returns null if not found.
     */
    public static Coordinates getCoordinates(String placeName) {
        try {
            String query = URLEncoder.encode(placeName, "UTF-8");
            String urlString = "https://nominatim.openstreetmap.org/search?q=" + query
                + "&format=json&limit=1&addressdetails=1";

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);
            // Nominatim requires a User-Agent header identifying the app
            conn.setRequestProperty("User-Agent", "VoyantraTravelPlanner/1.0");

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) return null;

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();

            JSONArray results = new JSONArray(response.toString());
            if (results.length() == 0) return null;

            JSONObject first = results.getJSONObject(0);
            double lat = Double.parseDouble(first.getString("lat"));
            double lon = Double.parseDouble(first.getString("lon"));
            String countryCode = null;
            if (first.has("address") && first.getJSONObject("address").has("country_code")) {
                countryCode = first.getJSONObject("address").getString("country_code").toUpperCase();
            }

            return new Coordinates(lat, lon, countryCode);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static class Coordinates {
        public final double latitude;
        public final double longitude;
        public final String countryCode; // ISO 3166-1 alpha-2, e.g. "IN", "FR" — may be null

        public Coordinates(double latitude, double longitude, String countryCode) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.countryCode = countryCode;
        }
    }
}

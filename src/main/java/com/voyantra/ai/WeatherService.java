package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import com.voyantra.util.AppConfig;

public class WeatherService {

    private static final String API_KEY =
        AppConfig.get("OPENWEATHERMAP_API_KEY", "YOUR_OPENWEATHERMAP_API_KEY_HERE");

    /**
     * Returns a simple object holding the current weather for a city.
     * If the lookup fails (city not found, API not ready yet, etc.),
     * returns null so the calling page can just skip showing weather.
     */
    public static WeatherInfo getCurrentWeather(String city) {
        try {
            String urlString = "https://api.openweathermap.org/data/2.5/weather?q="
                + java.net.URLEncoder.encode(city, "UTF-8")
                + "&appid=" + API_KEY + "&units=metric";

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                return null; // city not found, or key not active yet
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();

            JSONObject json = new JSONObject(response.toString());
            double temp = json.getJSONObject("main").getDouble("temp");
            String description = json.getJSONArray("weather").getJSONObject(0).getString("description");
            int humidity = json.getJSONObject("main").getInt("humidity");

            return new WeatherInfo(temp, description, humidity);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Returns a real day-by-day forecast for as many of the trip's days as
     * OpenWeatherMap's free tier supports (up to 5 days out). Days beyond
     * that aren't included — the caller should fall back to the AI's
     * general seasonal note for those.
     */
    public static List<WeatherInfo> getForecast(String city, int numDays) {
        List<WeatherInfo> result = new ArrayList<>();
        try {
            String urlString = "https://api.openweathermap.org/data/2.5/forecast?q="
                + java.net.URLEncoder.encode(city, "UTF-8")
                + "&appid=" + API_KEY + "&units=metric";

            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            if (conn.getResponseCode() != 200) {
                return result;
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            reader.close();

            JSONObject json = new JSONObject(response.toString());
            JSONArray list = json.getJSONArray("list");

            // The API returns one entry every 3 hours. Group by calendar
            // date and pick the entry closest to midday for each date.
            java.util.LinkedHashMap<String, JSONObject> bestPerDay = new java.util.LinkedHashMap<>();
            java.util.LinkedHashMap<String, Integer> bestHourDiff = new java.util.LinkedHashMap<>();

            for (int i = 0; i < list.length(); i++) {
                JSONObject entry = list.getJSONObject(i);
                String dtText = entry.getString("dt_txt"); // e.g. "2026-09-18 12:00:00"
                String date = dtText.substring(0, 10);
                int hour = Integer.parseInt(dtText.substring(11, 13));
                int diff = Math.abs(hour - 12);

                if (!bestHourDiff.containsKey(date) || diff < bestHourDiff.get(date)) {
                    bestHourDiff.put(date, diff);
                    bestPerDay.put(date, entry);
                }
            }

            int day = 0;
            for (JSONObject entry : bestPerDay.values()) {
                if (day >= numDays) break;
                double temp = entry.getJSONObject("main").getDouble("temp");
                String description = entry.getJSONArray("weather").getJSONObject(0).getString("description");
                int humidity = entry.getJSONObject("main").getInt("humidity");
                result.add(new WeatherInfo(temp, description, humidity));
                day++;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // ---- Simple holder class for the weather result ----
    public static class WeatherInfo {
        public final double temperature;
        public final String description;
        public final int humidity;

        public WeatherInfo(double temperature, String description, int humidity) {
            this.temperature = temperature;
            this.description = description;
            this.humidity = humidity;
        }
    }
}
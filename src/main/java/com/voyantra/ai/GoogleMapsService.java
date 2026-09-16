package com.voyantra.ai;

import java.net.URLEncoder;
import java.util.List;

import com.voyantra.util.AppConfig;

/**
 * Builds Google Maps Embed API iframe URLs (the same pattern MediaService
 * uses for YouTube: an API key server-side, embedded via a plain iframe —
 * the Embed API itself is free, unlike the JS Maps SDK). If no key is
 * configured, isConfigured() returns false and the page should fall back to
 * the free Leaflet/OpenStreetMap map instead.
 */
public class GoogleMapsService {

    private static final String EMBED_API_KEY = AppConfig.get("GOOGLE_MAPS_EMBED_KEY", "");

    public static boolean isConfigured() {
        return !EMBED_API_KEY.trim().isEmpty();
    }

    /** points: list of {lat, lon} pairs, in visit order. */
    public static String directionsEmbedUrl(List<double[]> points) throws Exception {
        String key = URLEncoder.encode(EMBED_API_KEY, "UTF-8");

        if (points.size() == 1) {
            String q = points.get(0)[0] + "," + points.get(0)[1];
            return "https://www.google.com/maps/embed/v1/place?key=" + key
                + "&q=" + URLEncoder.encode(q, "UTF-8");
        }

        double[] origin = points.get(0);
        double[] dest = points.get(points.size() - 1);

        StringBuilder url = new StringBuilder("https://www.google.com/maps/embed/v1/directions?key=").append(key);
        url.append("&origin=").append(URLEncoder.encode(origin[0] + "," + origin[1], "UTF-8"));
        url.append("&destination=").append(URLEncoder.encode(dest[0] + "," + dest[1], "UTF-8"));

        if (points.size() > 2) {
            StringBuilder waypoints = new StringBuilder();
            for (int i = 1; i < points.size() - 1; i++) {
                if (i > 1) waypoints.append("|");
                waypoints.append(points.get(i)[0]).append(",").append(points.get(i)[1]);
            }
            url.append("&waypoints=").append(URLEncoder.encode(waypoints.toString(), "UTF-8"));
        }

        return url.toString();
    }
}

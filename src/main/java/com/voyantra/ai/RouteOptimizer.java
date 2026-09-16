package com.voyantra.ai;

import java.util.ArrayList;
import java.util.List;

public class RouteOptimizer {

    // ---- One stop in the trip, with its name and coordinates ----
    public static class Stop {
        public String name;
        public double latitude;
        public double longitude;

        public Stop(String name, double latitude, double longitude) {
            this.name = name;
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    /**
     * Returns the stops reordered into an efficient visiting sequence,
     * starting from the first stop in the input list.
     * Uses the Nearest Neighbor algorithm: at each step, go to whichever
     * unvisited stop is closest to the current one.
     */
    public static List<Stop> optimizeRoute(List<Stop> stops) {
        if (stops.size() <= 2) {
            return stops; // nothing to optimize with 0-2 stops
        }

        List<Stop> unvisited = new ArrayList<>(stops);
        List<Stop> route = new ArrayList<>();

        // Start at the first stop the user entered
        Stop current = unvisited.remove(0);
        route.add(current);

        // Repeatedly jump to the nearest remaining stop
        while (!unvisited.isEmpty()) {
            Stop nearest = null;
            double nearestDistance = Double.MAX_VALUE;

            for (Stop candidate : unvisited) {
                double distance = haversineDistance(
                    current.latitude, current.longitude,
                    candidate.latitude, candidate.longitude
                );
                if (distance < nearestDistance) {
                    nearestDistance = distance;
                    nearest = candidate;
                }
            }

            route.add(nearest);
            unvisited.remove(nearest);
            current = nearest;
        }

        return route;
    }

    /**
     * Calculates the straight-line distance (in kilometers) between two
     * points on Earth, given their latitude/longitude. This is the
     * standard "Haversine formula" used in mapping and routing.
     */
    public static double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
        final int EARTH_RADIUS_KM = 6371;

        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                 + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                 * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_KM * c;
    }
}
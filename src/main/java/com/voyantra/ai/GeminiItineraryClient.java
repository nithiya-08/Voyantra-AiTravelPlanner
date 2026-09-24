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
        return generateItinerary(destination, budget, numDays, travelStyle, interests, null, null);
    }

    /**
     * Same as above, but when a real approved Voyantra vendor exists for this destination
     * (hotelVendorName / restaurantVendorName), the AI is nudged to use its exact name in
     * the "hotel"/"food" text so the suggestion is a real, bookable listing rather than a
     * generic AI guess. The caller still links the day to the vendor by ID separately
     * (this is a best-effort text nudge, not a guarantee of exact wording).
     */
    public JSONArray generateItinerary(String destination, double budget, int numDays,
                                        String travelStyle, String interests,
                                        String hotelVendorName, String restaurantVendorName) throws Exception {

        StringBuilder realOptions = new StringBuilder();
        if (hotelVendorName != null && !hotelVendorName.trim().isEmpty()) {
            realOptions.append("A real, bookable local stay called \"").append(hotelVendorName)
                .append("\" is available here — use this exact name for the \"hotel\" field on every day. ");
        }
        if (restaurantVendorName != null && !restaurantVendorName.trim().isEmpty()) {
            realOptions.append("A real local restaurant called \"").append(restaurantVendorName)
                .append("\" is available here — mention it by this exact name in the \"food\" field at least once. ");
        }

        String prompt = "Create a " + numDays + "-day travel itinerary for " + destination + ". "
            + "Budget: Rs " + (int) budget + " total. Travel style: " + travelStyle + ". "
            + "Interests: " + interests + ". "
            + realOptions.toString()
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

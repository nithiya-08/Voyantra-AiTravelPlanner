package com.voyantra.ai;

import com.voyantra.util.TtlCache;

/**
 * Asks Gemini for a short, general write-up of good areas to stay/eat/visit
 * near a destination. This is AI-generated general guidance, not a verified
 * directory — real, bookable options should come from the vendor marketplace
 * (approved Voyantra vendor listings) first; this text fills the gap when a
 * destination has no listed vendors yet, and the UI should make clear it's
 * AI guidance, not a listing.
 */
public class NearbyRecommendationService {

    // Same generic-per-destination reasoning as EmergencyInfoService: this
    // was a fresh Gemini call on every page view of a destination with no
    // vendors, which was a major source of slow trip-details.jsp loads.
    private static final TtlCache<String> CACHE = new TtlCache<>(7L * 24 * 60 * 60 * 1000L);

    public static String getAiSuggestions(String destination) {
        String cacheKey = destination.toLowerCase();
        String cached = CACHE.get(cacheKey);
        if (cached != null) return cached;
        try {
            String prompt = "A traveler is visiting " + destination + ". In under 80 words, plain text, "
                + "no markdown, no headings, suggest: the kind of neighborhood/area that's best to stay in, "
                + "one or two well-known types of local food to try, and one nearby place or experience worth "
                + "visiting. Keep it general and useful, not a list of specific business names.";

            String result = GeminiClient.generateRaw(prompt);
            if (result != null) CACHE.put(cacheKey, result);
            return result;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}

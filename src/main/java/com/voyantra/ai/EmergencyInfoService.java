package com.voyantra.ai;

import org.json.JSONObject;

/**
 * Asks Gemini for general emergency/safety info for a destination (there's
 * no live emergency-services API in use, so this is AI-generated general
 * guidance, not a verified directory — the UI should make that clear).
 */
public class EmergencyInfoService {

    public static EmergencyInfo getEmergencyInfo(String destination) {
        try {
            String prompt = "For a traveler visiting " + destination + ", give general emergency and safety "
                + "information. Respond with ONLY a valid JSON object, no markdown, no explanation, no code fences, "
                + "with exactly these keys: \"emergencyNumber\" (the general police/ambulance emergency phone "
                + "number used in that country/region), \"hospitalNote\" (one short sentence on finding a nearby "
                + "hospital or major medical facility there), \"embassyNote\" (one short sentence — if this is "
                + "likely an international destination for an Indian traveler, a note about locating the nearest "
                + "Indian embassy/consulate; if it's within India, say local ID/medical insurance is usually enough).";

            String aiText = GeminiClient.generateRaw(prompt);
            JSONObject json = new JSONObject(aiText);

            return new EmergencyInfo(
                json.optString("emergencyNumber", "Not available"),
                json.optString("hospitalNote", ""),
                json.optString("embassyNote", "")
            );
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public static class EmergencyInfo {
        public final String emergencyNumber;
        public final String hospitalNote;
        public final String embassyNote;

        public EmergencyInfo(String emergencyNumber, String hospitalNote, String embassyNote) {
            this.emergencyNumber = emergencyNumber;
            this.hospitalNote = hospitalNote;
            this.embassyNote = embassyNote;
        }
    }
}

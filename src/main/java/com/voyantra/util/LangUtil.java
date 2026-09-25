package com.voyantra.util;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;

/**
 * Reads the tourist's selected UI language (set by js/i18n.js as a
 * "voyantra_lang" cookie alongside its localStorage copy) so server-side AI
 * calls can be asked to respond in that language too, not just the static
 * page text.
 */
public class LangUtil {

    private static final Map<String, String> NAMES = new HashMap<>();
    static {
        NAMES.put("en", "English");
        NAMES.put("ta", "Tamil");
        NAMES.put("hi", "Hindi");
        NAMES.put("fr", "French");
        NAMES.put("de", "German");
        NAMES.put("es", "Spanish");
    }

    /** Returns the language code from the request's cookies, defaulting to "en". */
    public static String getLangCode(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("voyantra_lang".equals(c.getName()) && NAMES.containsKey(c.getValue())) {
                    return c.getValue();
                }
            }
        }
        return "en";
    }

    /** Returns the full English name of a language code, e.g. "ta" -> "Tamil". */
    public static String languageName(String code) {
        return NAMES.getOrDefault(code, "English");
    }

    /** Convenience: the full language name straight from the request. */
    public static String getLangName(HttpServletRequest request) {
        return languageName(getLangCode(request));
    }
}

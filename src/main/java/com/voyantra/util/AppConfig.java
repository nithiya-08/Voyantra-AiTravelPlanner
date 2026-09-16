package com.voyantra.util;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Central place to read secrets/config, checked in this order:
 *   1. config.local.properties — a file outside the source tree (project
 *      root), never committed to git, never served over the web. This is
 *      where your real API keys/passwords for local development live.
 *   2. An environment variable of the same name (so the app can be deployed
 *      to a cloud host with secrets set in its dashboard).
 *   3. The placeholder default passed in by the caller.
 *
 * Nothing here should hold a real secret — see config.local.properties.example
 * for the keys this app expects, and copy it to config.local.properties with
 * your real values (that copy is gitignored).
 */
public class AppConfig {

    private static final Properties LOCAL_PROPERTIES = new Properties();

    static {
        String[] candidatePaths = {
            "C:/Users/MY PC/eclipse-workspace/AITravelPlanner/config.local.properties",
            "config.local.properties"
        };
        for (String path : candidatePaths) {
            try (FileInputStream in = new FileInputStream(path)) {
                LOCAL_PROPERTIES.load(in);
                break;
            } catch (IOException ignored) {
                // try the next candidate path
            }
        }
    }

    public static String get(String key, String placeholderDefault) {
        String fromProperties = LOCAL_PROPERTIES.getProperty(key);
        if (fromProperties != null && !fromProperties.trim().isEmpty()) {
            return fromProperties.trim();
        }
        String fromEnv = System.getenv(key);
        if (fromEnv != null && !fromEnv.trim().isEmpty()) {
            return fromEnv.trim();
        }
        return placeholderDefault;
    }
}

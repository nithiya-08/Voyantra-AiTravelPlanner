package com.voyantra.util;

import java.util.concurrent.ConcurrentHashMap;

/**
 * A minimal in-memory cache with a fixed time-to-live per entry. Used by the
 * external-API-backed services (weather, images, AI text) so that repeat
 * page views of the same destination don't re-issue the same slow network
 * call every time — the result only depends on the destination, not on who
 * is looking at it or how many times. Not distributed/persistent; scoped to
 * a single Tomcat instance, which is all this app runs on.
 */
public class TtlCache<V> {

    private static class Entry<V> {
        final V value;
        final long expiresAt;
        Entry(V value, long ttlMillis) {
            this.value = value;
            this.expiresAt = System.currentTimeMillis() + ttlMillis;
        }
        boolean isExpired() {
            return System.currentTimeMillis() > expiresAt;
        }
    }

    private final ConcurrentHashMap<String, Entry<V>> store = new ConcurrentHashMap<>();
    private final long ttlMillis;

    public TtlCache(long ttlMillis) {
        this.ttlMillis = ttlMillis;
    }

    public V get(String key) {
        Entry<V> entry = store.get(key);
        if (entry == null || entry.isExpired()) {
            return null;
        }
        return entry.value;
    }

    public void put(String key, V value) {
        store.put(key, new Entry<>(value, ttlMillis));
    }
}

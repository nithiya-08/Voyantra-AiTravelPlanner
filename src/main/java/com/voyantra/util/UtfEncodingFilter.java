package com.voyantra.util;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Two site-wide concerns handled in one filter:
 *  1. Forces UTF-8 on every request/response, so names or destinations typed
 *     in Tamil/Hindi/etc. survive the round trip instead of being mangled.
 *  2. Tells browsers never to cache dynamic pages (JSPs and servlets) — those
 *     reflect session/DB state (who's logged in, their trip list) and a
 *     cached copy can silently show stale or even another user's data after
 *     logging in as someone else. Static assets under /js/ are left
 *     cacheable (they're versioned with a ?v= query string when changed).
 */
public class UtfEncodingFilter implements Filter {

    public void init(FilterConfig filterConfig) {}

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (request.getCharacterEncoding() == null) {
            request.setCharacterEncoding("UTF-8");
        }
        response.setCharacterEncoding("UTF-8");

        if (request instanceof HttpServletRequest && response instanceof HttpServletResponse) {
            String uri = ((HttpServletRequest) request).getRequestURI();
            if (uri == null || !uri.contains("/js/")) {
                HttpServletResponse httpResponse = (HttpServletResponse) response;
                httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                httpResponse.setHeader("Pragma", "no-cache");
                httpResponse.setDateHeader("Expires", 0);
            }
        }

        chain.doFilter(request, response);
    }

    public void destroy() {}
}

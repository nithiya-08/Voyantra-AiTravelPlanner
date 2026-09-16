package com.voyantra.ai;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;

/**
 * Converts a trip's Rs budget into the destination country's local currency,
 * for travelers going abroad. Uses the free, keyless Frankfurter exchange
 * rate API. Domestic (India) trips or unrecognized countries are skipped.
 */
public class CurrencyService {

    // Common destination countries -> their currency code. Not exhaustive —
    // add more ISO country codes here as needed.
    private static final Map<String, String> COUNTRY_TO_CURRENCY = new HashMap<>();
    static {
        COUNTRY_TO_CURRENCY.put("US", "USD"); COUNTRY_TO_CURRENCY.put("GB", "GBP");
        COUNTRY_TO_CURRENCY.put("FR", "EUR"); COUNTRY_TO_CURRENCY.put("DE", "EUR");
        COUNTRY_TO_CURRENCY.put("ES", "EUR"); COUNTRY_TO_CURRENCY.put("IT", "EUR");
        COUNTRY_TO_CURRENCY.put("NL", "EUR"); COUNTRY_TO_CURRENCY.put("PT", "EUR");
        COUNTRY_TO_CURRENCY.put("AT", "EUR"); COUNTRY_TO_CURRENCY.put("IE", "EUR");
        COUNTRY_TO_CURRENCY.put("GR", "EUR"); COUNTRY_TO_CURRENCY.put("JP", "JPY");
        COUNTRY_TO_CURRENCY.put("CN", "CNY"); COUNTRY_TO_CURRENCY.put("KR", "KRW");
        COUNTRY_TO_CURRENCY.put("TH", "THB"); COUNTRY_TO_CURRENCY.put("SG", "SGD");
        COUNTRY_TO_CURRENCY.put("MY", "MYR"); COUNTRY_TO_CURRENCY.put("ID", "IDR");
        COUNTRY_TO_CURRENCY.put("VN", "VND"); COUNTRY_TO_CURRENCY.put("PH", "PHP");
        COUNTRY_TO_CURRENCY.put("AE", "AED"); COUNTRY_TO_CURRENCY.put("SA", "SAR");
        COUNTRY_TO_CURRENCY.put("QA", "QAR"); COUNTRY_TO_CURRENCY.put("LK", "LKR");
        COUNTRY_TO_CURRENCY.put("NP", "NPR"); COUNTRY_TO_CURRENCY.put("BD", "BDT");
        COUNTRY_TO_CURRENCY.put("AU", "AUD"); COUNTRY_TO_CURRENCY.put("NZ", "NZD");
        COUNTRY_TO_CURRENCY.put("CA", "CAD"); COUNTRY_TO_CURRENCY.put("MX", "MXN");
        COUNTRY_TO_CURRENCY.put("BR", "BRL"); COUNTRY_TO_CURRENCY.put("ZA", "ZAR");
        COUNTRY_TO_CURRENCY.put("EG", "EGP"); COUNTRY_TO_CURRENCY.put("TR", "TRY");
        COUNTRY_TO_CURRENCY.put("RU", "RUB"); COUNTRY_TO_CURRENCY.put("CH", "CHF");
        COUNTRY_TO_CURRENCY.put("SE", "SEK"); COUNTRY_TO_CURRENCY.put("NO", "NOK");
        COUNTRY_TO_CURRENCY.put("DK", "DKK"); COUNTRY_TO_CURRENCY.put("MV", "MVR");
        COUNTRY_TO_CURRENCY.put("BT", "BTN"); COUNTRY_TO_CURRENCY.put("IN", "INR");
    }

    public static String currencyForCountry(String countryCode) {
        if (countryCode == null) return null;
        return COUNTRY_TO_CURRENCY.get(countryCode.toUpperCase());
    }

    /**
     * Converts a Rs (INR) amount into the given currency. Returns null if the
     * currency is INR itself, unrecognized, or the lookup fails.
     */
    public static Double convertFromInr(double amountInr, String toCurrency) {
        if (toCurrency == null || toCurrency.equalsIgnoreCase("INR")) return null;
        try {
            String urlString = "https://api.frankfurter.dev/v1/latest?base=INR&symbols=" + toCurrency;
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            if (conn.getResponseCode() != 200) return null;

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) response.append(line);
            reader.close();

            JSONObject json = new JSONObject(response.toString());
            if (!json.has("rates") || !json.getJSONObject("rates").has(toCurrency)) return null;

            double rate = json.getJSONObject("rates").getDouble(toCurrency);
            return amountInr * rate;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}

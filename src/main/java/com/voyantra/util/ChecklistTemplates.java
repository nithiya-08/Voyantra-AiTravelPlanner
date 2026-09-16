package com.voyantra.util;

import java.util.ArrayList;
import java.util.List;

/** Default pre-trip checklist items, seeded once per trip. */
public class ChecklistTemplates {

    public static List<String> defaultItems(boolean international) {
        List<String> items = new ArrayList<>();
        items.add("Book/confirm tickets");
        items.add("ID proof (Aadhaar/passport)");
        items.add("Phone charger & power bank");
        items.add("Medicines / first-aid basics");
        items.add("Cash and one backup payment card");
        items.add("Weather-appropriate clothing");

        if (international) {
            items.add("Valid passport (6+ months validity)");
            items.add("Visa for destination country");
            items.add("Travel insurance");
            items.add("International roaming / local SIM plan");
            items.add("Power plug adapter for destination country");
        } else {
            items.add("Any advance-booked hotel/homestay confirmation");
        }

        return items;
    }
}

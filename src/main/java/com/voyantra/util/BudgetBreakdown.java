package com.voyantra.util;

/**
 * A simple, deterministic estimated split of a trip's budget across
 * stay / food / activities / transport, based on travel style. This is a
 * planning estimate shown on the trip page, not a real cost calculation.
 */
public class BudgetBreakdown {

    public final double stay;
    public final double food;
    public final double activities;
    public final double transport;

    private BudgetBreakdown(double budget, double stayPct, double foodPct, double activitiesPct, double transportPct) {
        this.stay = budget * stayPct;
        this.food = budget * foodPct;
        this.activities = budget * activitiesPct;
        this.transport = budget * transportPct;
    }

    public static BudgetBreakdown forTrip(double budget, String travelStyle) {
        String style = travelStyle == null ? "" : travelStyle.trim().toLowerCase();
        switch (style) {
            case "family":
                return new BudgetBreakdown(budget, 0.40, 0.25, 0.25, 0.10);
            case "couple":
                return new BudgetBreakdown(budget, 0.40, 0.25, 0.25, 0.10);
            case "friends":
                return new BudgetBreakdown(budget, 0.35, 0.30, 0.25, 0.10);
            case "solo":
            default:
                return new BudgetBreakdown(budget, 0.35, 0.25, 0.30, 0.10);
        }
    }
}

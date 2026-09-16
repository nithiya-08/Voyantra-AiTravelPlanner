/*
 * Voyantra i18n — translates every element carrying data-i18n / data-i18n-placeholder,
 * and injects a language switcher into the page header.
 *
 * To add a new translatable string anywhere in the app:
 *   1. Add data-i18n="some_key" to the element (text) or data-i18n-placeholder="some_key" (input placeholder).
 *   2. Add "some_key" to the TRANSLATIONS object below, for every language.
 * To add a new language: add its code to LANGUAGES and a full key set to TRANSLATIONS.
 */
(function () {
  var LANGUAGES = [
    { code: 'en', label: 'English' },
    { code: 'ta', label: 'தமிழ்' },
    { code: 'hi', label: 'हिन्दी' },
    { code: 'fr', label: 'Français' },
    { code: 'de', label: 'Deutsch' },
    { code: 'es', label: 'Español' }
  ];

  var TRANSLATIONS = {
    en: {
      nav_home: "Home", nav_about: "About Us", nav_how: "How It Works", nav_features: "Features",
      nav_contact: "Contact Us", nav_login: "Log in", nav_getstarted: "Get Started",
      nav_dashboard: "Dashboard", nav_logout: "Log out", nav_admin: "Admin",

      hero_eyebrow: "AI-planned, budget-first",
      hero_lead: "Most travel sites hand you a pile of hotels, reviews and flights and leave the planning to you. Tell us your budget, your days, and what you're into — we'll lay out the whole trip, day by day.",
      hero_cta_primary: "Plan my trip →", hero_cta_secondary: "See how it works",
      hero_micro: "One form in, one complete day-wise plan out",
      hero_visual_line: "You set the shape of the trip. The AI fills in the rest — stays, food and activities, day by day.",
      hero_output_label: "Output", hero_output_value: "A complete day-wise itinerary",
      chip_budget_t: "Budget", chip_budget_d: "Any amount",
      chip_days_t: "Days", chip_days_d: "Any length",
      chip_style_t: "Style", chip_style_d: "Solo · family",

      about_kicker: "About us", about_heading: "We think travel planning should take minutes, not evenings.",
      about_stat1: "inputs needed to start", about_stat2: "AI-generated, day by day",

      how_kicker: "How it works", how_heading: "Four inputs. One complete plan.",
      how_sub: "Everything downstream — hotels, food, activities, weather — is generated from what you tell us up front.",
      step1_t: "Set your budget", step1_d: "Total spend for the trip. Every suggestion after this is built to fit inside it.",
      step2_t: "Pick your days", step2_d: "How long you're travelling — from a quick weekend to a two-week trip.",
      step3_t: "Tell us the style", step3_d: "Solo, family, or with friends. It shapes the pace and the stays we suggest.",
      step4_t: "Get your itinerary", step4_d: "A day-by-day plan with food, stays and things to do — ready to save or download.",

      features_kicker: "What you get", features_heading: "Built around the trip, not the booking.",
      features_sub: "Other platforms stop at search results. This one keeps going until you have a plan.",
      feat1_t: "Budget-aware suggestions", feat1_d: "Hotels, food and activities are picked to fit inside what you set.",
      feat2_t: "Weather, built in", feat2_d: "See the forecast for each day of your trip before you pack a bag.",
      feat3_t: "Day-by-day structure", feat3_d: "An actual sequence, so you know what happens on Day 2 versus Day 4.",
      feat4_t: "See it before you go", feat4_d: "Photos and short videos of your destinations, alongside the plan.",
      feat5_t: "Download as PDF", feat5_d: "Keep a copy of your itinerary offline — no signal required on arrival.",
      feat6_t: "Edit anytime", feat6_d: "Plans change. Come back and adjust any day whenever you need to.",

      contact_kicker: "Contact", contact_heading: "Questions before you start planning?", contact_sub: "Reach out and we'll get back to you.",
      contact_email_l: "Email", contact_phone_l: "Phone", contact_based_l: "Based in",
      contact_name_ph: "Your name", contact_email_ph: "Your email", contact_msg_ph: "Your message", contact_send: "Send message",

      cta_heading: "Your next trip is one form away.", cta_sub: "Set a budget, pick your days, and let the plan build itself.", cta_button: "Start planning free →",
      footer_note: "Built with Java · MySQL · Gemini API",

      auth_login_title: "Welcome back", auth_login_sub: "Log in to see your saved trips and itineraries.",
      auth_email_label: "Email", auth_password_label: "Password", auth_remember: "Remember me", auth_forgot: "Forgot password?",
      auth_login_btn: "Log in", auth_login_switch: "Don't have an account?", auth_login_switch_link: "Register here",

      auth_register_title: "Create your account", auth_register_sub: "Start planning trips with AI in under a minute.",
      auth_name_label: "Full name", auth_phone_label: "Phone number", auth_confirm_label: "Confirm password",
      auth_register_btn: "Create account", auth_register_switch: "Already have an account?", auth_register_switch_link: "Log in",

      otp_title: "Check your email", otp_verify_btn: "Verify",

      tripform_kicker: "New trip", tripform_heading: "Tell us the shape of your trip", tripform_sub: "Four inputs — we'll take it from here.",
      tripform_dest_label: "Destinations", tripform_dest_hint: "(add all the places you want to visit)",
      tripform_addstop: "+ Add another stop",
      tripform_budget_label: "Budget", tripform_budget_hint: "(total for the trip)",
      tripform_days_label: "Number of days", tripform_style_label: "Travel style", tripform_style_select: "Select one",
      tripform_interests_label: "Interests", tripform_interests_hint: "(pick at least one)",
      tripform_submit: "Save trip details",
      interest_nature: "Nature", interest_food: "Food", interest_adventure: "Adventure",
      interest_culture: "Culture", interest_relax: "Relax", interest_shopping: "Shopping",
      style_solo: "Solo", style_family: "Family", style_friends: "Friends", style_couple: "Couple",

      dashboard_heading: "Your trips", dashboard_sub: "Every trip you've planned, in one place.",
      dashboard_newtrip: "+ New trip", dashboard_empty: "You haven't planned any trips yet.",
      dashboard_empty_cta: "Plan your first trip →", dashboard_view: "View", dashboard_edit: "Edit", dashboard_delete: "Delete",
      dashboard_shared_badge: "Shared with you",

      td_kicker: "Trip details", td_download: "Download as PDF", td_regenerate: "Regenerate itinerary",
      td_share: "Share trip", td_itinerary_heading: "Day-wise itinerary",
      td_generate_btn: "Generate itinerary with AI", td_generate_wait: "This can take up to 20-30 seconds — please don't close this tab.",
      td_empty_p1: "No AI itinerary generated yet for this trip.", td_empty_p2: "Click below and the AI will build your day-wise plan.",
      td_activities: "Activities", td_food: "Food", td_stay: "Stay", td_weather: "Weather",
      td_forecast_badge: "Forecast", td_seasonal_badge: "Seasonal estimate",
      td_route_heading: "Optimized route:", td_total_distance: "Total distance:",
      td_budget_label: "Budget", td_duration_label: "Duration", td_style_label: "Style", td_interests_label: "Interests",
      td_current_weather: "Current weather in",
      td_expenses_heading: "Expenses", td_expense_add: "Add expense", td_expense_category: "Category",
      td_expense_desc: "Description", td_expense_amount: "Amount", td_expense_spent: "Spent so far",
      td_collab_heading: "Collaborators", td_collab_invite: "Invite by email", td_collab_add: "Invite",
      td_budget_breakdown: "Estimated budget breakdown",

      edittrip_kicker: "Edit trip", edittrip_heading: "Update your trip", edittrip_sub: "Change any detail below and save.", edittrip_save: "Save changes"
    },

    ta: {
      nav_home: "முகப்பு", nav_about: "எங்களை பற்றி", nav_how: "இது எப்படி செயல்படுகிறது", nav_features: "அம்சங்கள்",
      nav_contact: "தொடர்பு கொள்ள", nav_login: "உள்நுழைய", nav_getstarted: "தொடங்குங்கள்",
      nav_dashboard: "டாஷ்போர்டு", nav_logout: "வெளியேறு", nav_admin: "நிர்வாகி",

      hero_eyebrow: "AI திட்டமிட்டது, பட்ஜெட்டை முதன்மையாகக் கொண்டது",
      hero_lead: "பெரும்பாலான பயண தளங்கள் ஹோட்டல்கள், மதிப்புரைகள் மற்றும் விமானங்களை மட்டும் தருகின்றன — திட்டமிடல் உங்கள் வேலை. உங்கள் பட்ஜெட், நாட்கள், விருப்பங்களை சொல்லுங்கள் — நாங்கள் நாள்வாரியாக முழு பயணத்தையும் வடிவமைத்துத் தருகிறோம்.",
      hero_cta_primary: "எனது பயணத்தைத் திட்டமிடு →", hero_cta_secondary: "இது எப்படி செயல்படுகிறது எனப் பார்க்க",
      hero_micro: "ஒரு படிவம் உள்ளீடு, ஒரு முழுமையான நாள்வாரி திட்டம் வெளியீடு",
      hero_visual_line: "பயணத்தின் வடிவத்தை நீங்கள் அமைக்கிறீர்கள். மீதமுள்ளதை AI நிரப்புகிறது — தங்குமிடங்கள், உணவு, செயல்பாடுகள், நாள்தோறும்.",
      hero_output_label: "வெளியீடு", hero_output_value: "ஒரு முழுமையான நாள்வாரி பயணத் திட்டம்",
      chip_budget_t: "பட்ஜெட்", chip_budget_d: "எந்த தொகையும்",
      chip_days_t: "நாட்கள்", chip_days_d: "எந்த நீளமும்",
      chip_style_t: "பாணி", chip_style_d: "தனி · குடும்பம்",

      about_kicker: "எங்களை பற்றி", about_heading: "பயண திட்டமிடல் மணி நேரங்களில் அல்ல, நிமிடங்களில் முடிய வேண்டும் என நினைக்கிறோம்.",
      about_stat1: "தொடங்க தேவையான உள்ளீடுகள்", about_stat2: "AI உருவாக்கியது, நாள்தோறும்",

      how_kicker: "இது எப்படி செயல்படுகிறது", how_heading: "நான்கு உள்ளீடுகள். ஒரு முழுமையான திட்டம்.",
      how_sub: "ஹோட்டல்கள், உணவு, செயல்பாடுகள், வானிலை — அனைத்தும் நீங்கள் முன்பே தரும் தகவலிலிருந்து உருவாக்கப்படுகிறது.",
      step1_t: "உங்கள் பட்ஜெட்டை அமைக்கவும்", step1_d: "பயணத்திற்கான மொத்த செலவு. இதற்குப் பின் அனைத்து பரிந்துரைகளும் இதற்குள் பொருந்தும் வகையில் அமையும்.",
      step2_t: "உங்கள் நாட்களைத் தேர்ந்தெடுக்கவும்", step2_d: "நீங்கள் பயணிக்கும் காலம் — வார இறுதி முதல் இரண்டு வார பயணம் வரை.",
      step3_t: "பாணியைச் சொல்லுங்கள்", step3_d: "தனியாக, குடும்பத்துடன், அல்லது நண்பர்களுடன். இது வேகத்தையும் தங்குமிடங்களையும் தீர்மானிக்கும்.",
      step4_t: "உங்கள் பயணத் திட்டத்தைப் பெறுங்கள்", step4_d: "உணவு, தங்குமிடம், செயல்பாடுகளுடன் கூடிய நாள்வாரி திட்டம் — சேமிக்க அல்லது பதிவிறக்க தயார்.",

      features_kicker: "நீங்கள் பெறுவது", features_heading: "முன்பதிவுக்காக அல்ல, பயணத்திற்காக வடிவமைக்கப்பட்டது.",
      features_sub: "மற்ற தளங்கள் தேடல் முடிவுகளுடன் நிற்கின்றன. இது ஒரு முழு திட்டம் கிடைக்கும் வரை தொடர்கிறது.",
      feat1_t: "பட்ஜெட்டை கருத்தில் கொண்ட பரிந்துரைகள்", feat1_d: "ஹோட்டல்கள், உணவு, செயல்பாடுகள் உங்கள் பட்ஜெட்டிற்குள் பொருந்துமாறு தேர்ந்தெடுக்கப்படுகின்றன.",
      feat2_t: "வானிலை உள்ளடக்கம்", feat2_d: "பயணப் பையைப் பொதிவதற்கு முன் ஒவ்வொரு நாளின் வானிலை முன்னறிவிப்பையும் காணுங்கள்.",
      feat3_t: "நாள்வாரி கட்டமைப்பு", feat3_d: "ஒரு உண்மையான வரிசை, எனவே 2ஆம் நாள் மற்றும் 4ஆம் நாளுக்கு இடையே என்ன நடக்கும் என்று உங்களுக்குத் தெரியும்.",
      feat4_t: "பயணத்திற்கு முன் பாருங்கள்", feat4_d: "உங்கள் இடங்களின் புகைப்படங்கள் மற்றும் குறும் வீடியோக்கள், திட்டத்துடன்.",
      feat5_t: "PDF ஆக பதிவிறக்கவும்", feat5_d: "உங்கள் பயணத் திட்டத்தின் நகலை ஆஃப்லைனில் வையுங்கள் — வருகையின்போது சிக்னல் தேவையில்லை.",
      feat6_t: "எப்போது வேண்டுமானாலும் திருத்தவும்", feat6_d: "திட்டங்கள் மாறும். எப்போது வேண்டுமானாலும் திரும்பி வந்து எந்த நாளையும் சரிசெய்யுங்கள்.",

      contact_kicker: "தொடர்பு", contact_heading: "திட்டமிடத் தொடங்கும் முன் கேள்விகளா?", contact_sub: "எங்களைத் தொடர்பு கொள்ளுங்கள், நாங்கள் பதிலளிப்போம்.",
      contact_email_l: "மின்னஞ்சல்", contact_phone_l: "தொலைபேசி", contact_based_l: "இருப்பிடம்",
      contact_name_ph: "உங்கள் பெயர்", contact_email_ph: "உங்கள் மின்னஞ்சல்", contact_msg_ph: "உங்கள் செய்தி", contact_send: "செய்தி அனுப்பு",

      cta_heading: "உங்கள் அடுத்த பயணம் ஒரு படிவம் தொலைவில் உள்ளது.", cta_sub: "பட்ஜெட்டை அமைத்து, நாட்களைத் தேர்ந்தெடுத்து, திட்டத்தை உருவாகவிடுங்கள்.", cta_button: "இலவசமாகத் திட்டமிடத் தொடங்குங்கள் →",
      footer_note: "Java · MySQL · Gemini API கொண்டு உருவாக்கப்பட்டது",

      auth_login_title: "மீண்டும் வரவேற்கிறோம்", auth_login_sub: "உங்கள் சேமித்த பயணங்களையும் திட்டங்களையும் காண உள்நுழையவும்.",
      auth_email_label: "மின்னஞ்சல்", auth_password_label: "கடவுச்சொல்", auth_remember: "என்னை நினைவில் கொள்", auth_forgot: "கடவுச்சொல் மறந்துவிட்டதா?",
      auth_login_btn: "உள்நுழைய", auth_login_switch: "கணக்கு இல்லையா?", auth_login_switch_link: "இங்கே பதிவு செய்யவும்",

      auth_register_title: "உங்கள் கணக்கை உருவாக்குங்கள்", auth_register_sub: "ஒரு நிமிடத்திற்குள் AI உடன் பயணங்களைத் திட்டமிடத் தொடங்குங்கள்.",
      auth_name_label: "முழுப் பெயர்", auth_phone_label: "தொலைபேசி எண்", auth_confirm_label: "கடவுச்சொல்லை உறுதிப்படுத்தவும்",
      auth_register_btn: "கணக்கை உருவாக்கு", auth_register_switch: "ஏற்கனவே கணக்கு உள்ளதா?", auth_register_switch_link: "உள்நுழையவும்",

      otp_title: "உங்கள் மின்னஞ்சலைச் சரிபார்க்கவும்", otp_verify_btn: "சரிபார்க்கவும்",

      tripform_kicker: "புதிய பயணம்", tripform_heading: "உங்கள் பயணத்தின் வடிவத்தைச் சொல்லுங்கள்", tripform_sub: "நான்கு உள்ளீடுகள் — மீதமுள்ளதை நாங்கள் பார்த்துக்கொள்கிறோம்.",
      tripform_dest_label: "இடங்கள்", tripform_dest_hint: "(நீங்கள் பார்க்க விரும்பும் அனைத்து இடங்களையும் சேர்க்கவும்)",
      tripform_addstop: "+ மற்றொரு இடத்தைச் சேர்",
      tripform_budget_label: "பட்ஜெட்", tripform_budget_hint: "(பயணத்திற்கான மொத்தம்)",
      tripform_days_label: "நாட்களின் எண்ணிக்கை", tripform_style_label: "பயண பாணி", tripform_style_select: "ஒன்றைத் தேர்ந்தெடுக்கவும்",
      tripform_interests_label: "விருப்பங்கள்", tripform_interests_hint: "(குறைந்தது ஒன்றைத் தேர்ந்தெடுக்கவும்)",
      tripform_submit: "பயண விவரங்களைச் சேமிக்கவும்",
      interest_nature: "இயற்கை", interest_food: "உணவு", interest_adventure: "சாகசம்",
      interest_culture: "பண்பாடு", interest_relax: "ஓய்வு", interest_shopping: "ஷாப்பிங்",
      style_solo: "தனியாக", style_family: "குடும்பம்", style_friends: "நண்பர்கள்", style_couple: "ஜோடி",

      dashboard_heading: "உங்கள் பயணங்கள்", dashboard_sub: "நீங்கள் திட்டமிட்ட ஒவ்வொரு பயணமும், ஒரே இடத்தில்.",
      dashboard_newtrip: "+ புதிய பயணம்", dashboard_empty: "நீங்கள் இன்னும் எந்த பயணத்தையும் திட்டமிடவில்லை.",
      dashboard_empty_cta: "உங்கள் முதல் பயணத்தைத் திட்டமிடுங்கள் →", dashboard_view: "காண்க", dashboard_edit: "திருத்து", dashboard_delete: "நீக்கு",
      dashboard_shared_badge: "உங்களுடன் பகிரப்பட்டது",

      td_kicker: "பயண விவரங்கள்", td_download: "PDF ஆக பதிவிறக்கவும்", td_regenerate: "திட்டத்தை மீண்டும் உருவாக்கு",
      td_share: "பயணத்தைப் பகிரவும்", td_itinerary_heading: "நாள்வாரி பயணத் திட்டம்",
      td_generate_btn: "AI மூலம் திட்டத்தை உருவாக்கு", td_generate_wait: "இதற்கு 20-30 விநாடிகள் வரை ஆகலாம் — இந்த தாவலை மூட வேண்டாம்.",
      td_empty_p1: "இந்த பயணத்திற்கு இன்னும் AI திட்டம் உருவாக்கப்படவில்லை.", td_empty_p2: "கீழே கிளிக் செய்யவும், AI உங்கள் நாள்வாரி திட்டத்தை உருவாக்கும்.",
      td_activities: "செயல்பாடுகள்", td_food: "உணவு", td_stay: "தங்குமிடம்", td_weather: "வானிலை",
      td_forecast_badge: "முன்னறிவிப்பு", td_seasonal_badge: "பருவகால மதிப்பீடு",
      td_route_heading: "உகந்த பாதை:", td_total_distance: "மொத்த தூரம்:",
      td_budget_label: "பட்ஜெட்", td_duration_label: "காலம்", td_style_label: "பாணி", td_interests_label: "விருப்பங்கள்",
      td_current_weather: "தற்போதைய வானிலை",
      td_expenses_heading: "செலவுகள்", td_expense_add: "செலவைச் சேர்க்கவும்", td_expense_category: "வகை",
      td_expense_desc: "விளக்கம்", td_expense_amount: "தொகை", td_expense_spent: "இதுவரை செலவழித்தது",
      td_collab_heading: "கூட்டாளர்கள்", td_collab_invite: "மின்னஞ்சல் மூலம் அழைக்கவும்", td_collab_add: "அழைக்கவும்",
      td_budget_breakdown: "மதிப்பிடப்பட்ட பட்ஜெட் பிரிவு",

      edittrip_kicker: "பயணத்தைத் திருத்து", edittrip_heading: "உங்கள் பயணத்தைப் புதுப்பிக்கவும்", edittrip_sub: "கீழே உள்ள எந்த விவரத்தையும் மாற்றி சேமிக்கவும்.", edittrip_save: "மாற்றங்களைச் சேமி"
    },

    hi: {
      nav_home: "होम", nav_about: "हमारे बारे में", nav_how: "यह कैसे काम करता है", nav_features: "विशेषताएं",
      nav_contact: "संपर्क करें", nav_login: "लॉग इन करें", nav_getstarted: "शुरू करें",
      nav_dashboard: "डैशबोर्ड", nav_logout: "लॉग आउट", nav_admin: "एडमिन",

      hero_eyebrow: "AI-नियोजित, बजट-प्राथमिकता",
      hero_lead: "ज़्यादातर ट्रैवल साइट्स आपको होटल, रिव्यू और फ्लाइट्स का ढेर थमा देती हैं और योजना बनाना आप पर छोड़ देती हैं। अपना बजट, दिन और रुचियां बताइए — हम दिन-प्रतिदिन पूरी यात्रा तैयार कर देंगे।",
      hero_cta_primary: "मेरी यात्रा की योजना बनाएं →", hero_cta_secondary: "देखें यह कैसे काम करता है",
      hero_micro: "एक फॉर्म भरें, एक पूरी दिन-वार योजना पाएं",
      hero_visual_line: "आप यात्रा का ढांचा तय करते हैं। बाकी सब — ठहरना, खाना, गतिविधियां — AI हर दिन के हिसाब से भर देता है।",
      hero_output_label: "परिणाम", hero_output_value: "एक पूरी दिन-वार यात्रा योजना",
      chip_budget_t: "बजट", chip_budget_d: "कोई भी राशि",
      chip_days_t: "दिन", chip_days_d: "कोई भी अवधि",
      chip_style_t: "शैली", chip_style_d: "अकेले · परिवार",

      about_kicker: "हमारे बारे में", about_heading: "हमारा मानना है कि यात्रा की योजना मिनटों में बननी चाहिए, शामें बिताकर नहीं।",
      about_stat1: "शुरू करने के लिए ज़रूरी इनपुट", about_stat2: "AI द्वारा दिन-वार तैयार",

      how_kicker: "यह कैसे काम करता है", how_heading: "चार इनपुट। एक पूरी योजना।",
      how_sub: "होटल, खाना, गतिविधियां, मौसम — सब कुछ आपकी दी गई जानकारी से बनाया जाता है।",
      step1_t: "अपना बजट तय करें", step1_d: "यात्रा के लिए कुल खर्च। इसके बाद हर सुझाव इसी में फिट होगा।",
      step2_t: "अपने दिन चुनें", step2_d: "आप कितने समय की यात्रा कर रहे हैं — एक छोटे वीकेंड से लेकर दो हफ्ते तक।",
      step3_t: "शैली बताएं", step3_d: "अकेले, परिवार के साथ, या दोस्तों के साथ। यह गति और ठहरने की जगह तय करता है।",
      step4_t: "अपनी यात्रा योजना पाएं", step4_d: "खाना, ठहरना और गतिविधियों के साथ दिन-वार योजना — सेव या डाउनलोड करने के लिए तैयार।",

      features_kicker: "आपको क्या मिलता है", features_heading: "बुकिंग के लिए नहीं, यात्रा के लिए बनाया गया।",
      features_sub: "बाकी प्लेटफॉर्म सर्च रिजल्ट पर रुक जाते हैं। यह तब तक चलता है जब तक आपके पास पूरी योजना न हो।",
      feat1_t: "बजट के अनुसार सुझाव", feat1_d: "होटल, खाना और गतिविधियां आपके बजट में फिट होने के लिए चुनी जाती हैं।",
      feat2_t: "मौसम, अंतर्निहित", feat2_d: "बैग पैक करने से पहले अपनी यात्रा के हर दिन का पूर्वानुमान देखें।",
      feat3_t: "दिन-वार संरचना", feat3_d: "एक वास्तविक क्रम, ताकि आपको पता हो कि दूसरे दिन और चौथे दिन में क्या होगा।",
      feat4_t: "जाने से पहले देखें", feat4_d: "योजना के साथ आपके गंतव्यों की तस्वीरें और छोटे वीडियो।",
      feat5_t: "PDF के रूप में डाउनलोड करें", feat5_d: "अपनी यात्रा योजना की एक कॉपी ऑफ़लाइन रखें — पहुंचने पर सिग्नल की ज़रूरत नहीं।",
      feat6_t: "कभी भी संपादित करें", feat6_d: "योजनाएं बदलती हैं। जब भी ज़रूरत हो, वापस आएं और किसी भी दिन को समायोजित करें।",

      contact_kicker: "संपर्क", contact_heading: "योजना शुरू करने से पहले सवाल हैं?", contact_sub: "संपर्क करें, हम जवाब देंगे।",
      contact_email_l: "ईमेल", contact_phone_l: "फ़ोन", contact_based_l: "स्थान",
      contact_name_ph: "आपका नाम", contact_email_ph: "आपका ईमेल", contact_msg_ph: "आपका संदेश", contact_send: "संदेश भेजें",

      cta_heading: "आपकी अगली यात्रा सिर्फ़ एक फॉर्म दूर है।", cta_sub: "बजट तय करें, दिन चुनें, और योजना खुद बनने दें।", cta_button: "मुफ़्त में योजना शुरू करें →",
      footer_note: "Java · MySQL · Gemini API से बनाया गया",

      auth_login_title: "वापसी पर स्वागत है", auth_login_sub: "अपनी सहेजी गई यात्राएं और योजनाएं देखने के लिए लॉग इन करें।",
      auth_email_label: "ईमेल", auth_password_label: "पासवर्ड", auth_remember: "मुझे याद रखें", auth_forgot: "पासवर्ड भूल गए?",
      auth_login_btn: "लॉग इन करें", auth_login_switch: "खाता नहीं है?", auth_login_switch_link: "यहां रजिस्टर करें",

      auth_register_title: "अपना खाता बनाएं", auth_register_sub: "एक मिनट से भी कम समय में AI के साथ यात्राओं की योजना बनाना शुरू करें।",
      auth_name_label: "पूरा नाम", auth_phone_label: "फ़ोन नंबर", auth_confirm_label: "पासवर्ड की पुष्टि करें",
      auth_register_btn: "खाता बनाएं", auth_register_switch: "पहले से खाता है?", auth_register_switch_link: "लॉग इन करें",

      otp_title: "अपना ईमेल जांचें", otp_verify_btn: "सत्यापित करें",

      tripform_kicker: "नई यात्रा", tripform_heading: "अपनी यात्रा का स्वरूप बताएं", tripform_sub: "चार इनपुट — बाकी हम संभाल लेंगे।",
      tripform_dest_label: "गंतव्य", tripform_dest_hint: "(जिन सभी जगहों पर जाना चाहते हैं उन्हें जोड़ें)",
      tripform_addstop: "+ एक और स्टॉप जोड़ें",
      tripform_budget_label: "बजट", tripform_budget_hint: "(यात्रा के लिए कुल)",
      tripform_days_label: "दिनों की संख्या", tripform_style_label: "यात्रा शैली", tripform_style_select: "एक चुनें",
      tripform_interests_label: "रुचियां", tripform_interests_hint: "(कम से कम एक चुनें)",
      tripform_submit: "यात्रा विवरण सहेजें",
      interest_nature: "प्रकृति", interest_food: "खाना", interest_adventure: "साहसिक",
      interest_culture: "संस्कृति", interest_relax: "आराम", interest_shopping: "खरीदारी",
      style_solo: "अकेले", style_family: "परिवार", style_friends: "दोस्त", style_couple: "जोड़ा",

      dashboard_heading: "आपकी यात्राएं", dashboard_sub: "आपकी हर योजनाबद्ध यात्रा, एक ही जगह।",
      dashboard_newtrip: "+ नई यात्रा", dashboard_empty: "आपने अभी तक कोई यात्रा की योजना नहीं बनाई है।",
      dashboard_empty_cta: "अपनी पहली यात्रा की योजना बनाएं →", dashboard_view: "देखें", dashboard_edit: "संपादित करें", dashboard_delete: "हटाएं",
      dashboard_shared_badge: "आपके साथ साझा किया गया",

      td_kicker: "यात्रा विवरण", td_download: "PDF के रूप में डाउनलोड करें", td_regenerate: "योजना फिर से बनाएं",
      td_share: "यात्रा साझा करें", td_itinerary_heading: "दिन-वार यात्रा योजना",
      td_generate_btn: "AI से योजना बनाएं", td_generate_wait: "इसमें 20-30 सेकंड तक लग सकते हैं — कृपया यह टैब बंद न करें।",
      td_empty_p1: "इस यात्रा के लिए अभी तक कोई AI योजना नहीं बनी है।", td_empty_p2: "नीचे क्लिक करें, AI आपकी दिन-वार योजना बना देगा।",
      td_activities: "गतिविधियां", td_food: "खाना", td_stay: "ठहरना", td_weather: "मौसम",
      td_forecast_badge: "पूर्वानुमान", td_seasonal_badge: "मौसमी अनुमान",
      td_route_heading: "अनुकूलित मार्ग:", td_total_distance: "कुल दूरी:",
      td_budget_label: "बजट", td_duration_label: "अवधि", td_style_label: "शैली", td_interests_label: "रुचियां",
      td_current_weather: "वर्तमान मौसम",
      td_expenses_heading: "खर्च", td_expense_add: "खर्च जोड़ें", td_expense_category: "श्रेणी",
      td_expense_desc: "विवरण", td_expense_amount: "राशि", td_expense_spent: "अब तक खर्च हुआ",
      td_collab_heading: "सहयोगी", td_collab_invite: "ईमेल से आमंत्रित करें", td_collab_add: "आमंत्रित करें",
      td_budget_breakdown: "अनुमानित बजट विवरण",

      edittrip_kicker: "यात्रा संपादित करें", edittrip_heading: "अपनी यात्रा अपडेट करें", edittrip_sub: "नीचे कोई भी विवरण बदलें और सहेजें।", edittrip_save: "परिवर्तन सहेजें"
    },

    fr: {
      nav_home: "Accueil", nav_about: "À propos", nav_how: "Comment ça marche", nav_features: "Fonctionnalités",
      nav_contact: "Contact", nav_login: "Connexion", nav_getstarted: "Commencer",
      nav_dashboard: "Tableau de bord", nav_logout: "Déconnexion", nav_admin: "Admin",

      hero_eyebrow: "Planifié par IA, priorité au budget",
      hero_lead: "La plupart des sites de voyage vous donnent une pile d'hôtels, d'avis et de vols et vous laissent tout planifier. Indiquez-nous votre budget, vos jours et vos envies — nous organisons tout le voyage, jour par jour.",
      hero_cta_primary: "Planifier mon voyage →", hero_cta_secondary: "Voir comment ça marche",
      hero_micro: "Un formulaire, un plan complet jour par jour",
      hero_visual_line: "Vous définissez la forme du voyage. L'IA remplit le reste — hébergements, repas et activités, jour après jour.",
      hero_output_label: "Résultat", hero_output_value: "Un itinéraire complet jour par jour",
      chip_budget_t: "Budget", chip_budget_d: "N'importe quel montant",
      chip_days_t: "Jours", chip_days_d: "N'importe quelle durée",
      chip_style_t: "Style", chip_style_d: "Solo · famille",

      about_kicker: "À propos", about_heading: "Nous pensons que planifier un voyage devrait prendre des minutes, pas des soirées.",
      about_stat1: "entrées nécessaires pour commencer", about_stat2: "généré par IA, jour après jour",

      how_kicker: "Comment ça marche", how_heading: "Quatre informations. Un plan complet.",
      how_sub: "Tout le reste — hôtels, repas, activités, météo — est généré à partir de ce que vous nous indiquez.",
      step1_t: "Fixez votre budget", step1_d: "Dépense totale pour le voyage. Chaque suggestion s'y adaptera.",
      step2_t: "Choisissez vos jours", step2_d: "La durée de votre voyage — d'un week-end rapide à deux semaines.",
      step3_t: "Indiquez le style", step3_d: "Seul, en famille ou entre amis. Cela façonne le rythme et les hébergements proposés.",
      step4_t: "Recevez votre itinéraire", step4_d: "Un plan jour par jour avec repas, hébergements et activités — prêt à sauvegarder ou télécharger.",

      features_kicker: "Ce que vous obtenez", features_heading: "Conçu autour du voyage, pas de la réservation.",
      features_sub: "Les autres plateformes s'arrêtent aux résultats de recherche. Celle-ci continue jusqu'à avoir un vrai plan.",
      feat1_t: "Suggestions adaptées au budget", feat1_d: "Hôtels, repas et activités choisis pour rester dans votre budget.",
      feat2_t: "Météo intégrée", feat2_d: "Consultez les prévisions de chaque jour avant de faire vos valises.",
      feat3_t: "Structure jour par jour", feat3_d: "Un vrai déroulé, pour savoir ce qui se passe le jour 2 par rapport au jour 4.",
      feat4_t: "Voyez avant de partir", feat4_d: "Photos et courtes vidéos de vos destinations, avec le plan.",
      feat5_t: "Téléchargez en PDF", feat5_d: "Gardez une copie de votre itinéraire hors ligne — aucun réseau nécessaire à l'arrivée.",
      feat6_t: "Modifiez à tout moment", feat6_d: "Les plans changent. Revenez ajuster n'importe quel jour quand vous le souhaitez.",

      contact_kicker: "Contact", contact_heading: "Des questions avant de commencer ?", contact_sub: "Contactez-nous, nous vous répondrons.",
      contact_email_l: "E-mail", contact_phone_l: "Téléphone", contact_based_l: "Basé à",
      contact_name_ph: "Votre nom", contact_email_ph: "Votre e-mail", contact_msg_ph: "Votre message", contact_send: "Envoyer le message",

      cta_heading: "Votre prochain voyage n'est qu'à un formulaire.", cta_sub: "Fixez un budget, choisissez vos jours, et laissez le plan se construire.", cta_button: "Commencez gratuitement →",
      footer_note: "Créé avec Java · MySQL · Gemini API",

      auth_login_title: "Content de vous revoir", auth_login_sub: "Connectez-vous pour voir vos voyages et itinéraires enregistrés.",
      auth_email_label: "E-mail", auth_password_label: "Mot de passe", auth_remember: "Se souvenir de moi", auth_forgot: "Mot de passe oublié ?",
      auth_login_btn: "Connexion", auth_login_switch: "Pas de compte ?", auth_login_switch_link: "Inscrivez-vous ici",

      auth_register_title: "Créez votre compte", auth_register_sub: "Commencez à planifier vos voyages avec l'IA en moins d'une minute.",
      auth_name_label: "Nom complet", auth_phone_label: "Numéro de téléphone", auth_confirm_label: "Confirmez le mot de passe",
      auth_register_btn: "Créer un compte", auth_register_switch: "Vous avez déjà un compte ?", auth_register_switch_link: "Connexion",

      otp_title: "Vérifiez votre e-mail", otp_verify_btn: "Vérifier",

      tripform_kicker: "Nouveau voyage", tripform_heading: "Décrivez la forme de votre voyage", tripform_sub: "Quatre informations — on s'occupe du reste.",
      tripform_dest_label: "Destinations", tripform_dest_hint: "(ajoutez tous les lieux que vous voulez visiter)",
      tripform_addstop: "+ Ajouter une étape",
      tripform_budget_label: "Budget", tripform_budget_hint: "(total pour le voyage)",
      tripform_days_label: "Nombre de jours", tripform_style_label: "Style de voyage", tripform_style_select: "Choisissez",
      tripform_interests_label: "Centres d'intérêt", tripform_interests_hint: "(choisissez-en au moins un)",
      tripform_submit: "Enregistrer les détails",
      interest_nature: "Nature", interest_food: "Cuisine", interest_adventure: "Aventure",
      interest_culture: "Culture", interest_relax: "Détente", interest_shopping: "Shopping",
      style_solo: "Solo", style_family: "Famille", style_friends: "Amis", style_couple: "Couple",

      dashboard_heading: "Vos voyages", dashboard_sub: "Tous vos voyages planifiés, au même endroit.",
      dashboard_newtrip: "+ Nouveau voyage", dashboard_empty: "Vous n'avez encore planifié aucun voyage.",
      dashboard_empty_cta: "Planifiez votre premier voyage →", dashboard_view: "Voir", dashboard_edit: "Modifier", dashboard_delete: "Supprimer",
      dashboard_shared_badge: "Partagé avec vous",

      td_kicker: "Détails du voyage", td_download: "Télécharger en PDF", td_regenerate: "Régénérer l'itinéraire",
      td_share: "Partager le voyage", td_itinerary_heading: "Itinéraire jour par jour",
      td_generate_btn: "Générer l'itinéraire avec l'IA", td_generate_wait: "Cela peut prendre 20 à 30 secondes — ne fermez pas cet onglet.",
      td_empty_p1: "Aucun itinéraire IA n'a encore été généré pour ce voyage.", td_empty_p2: "Cliquez ci-dessous et l'IA créera votre plan jour par jour.",
      td_activities: "Activités", td_food: "Repas", td_stay: "Hébergement", td_weather: "Météo",
      td_forecast_badge: "Prévision", td_seasonal_badge: "Estimation saisonnière",
      td_route_heading: "Itinéraire optimisé :", td_total_distance: "Distance totale :",
      td_budget_label: "Budget", td_duration_label: "Durée", td_style_label: "Style", td_interests_label: "Centres d'intérêt",
      td_current_weather: "Météo actuelle à",
      td_expenses_heading: "Dépenses", td_expense_add: "Ajouter une dépense", td_expense_category: "Catégorie",
      td_expense_desc: "Description", td_expense_amount: "Montant", td_expense_spent: "Dépensé jusqu'à présent",
      td_collab_heading: "Collaborateurs", td_collab_invite: "Inviter par e-mail", td_collab_add: "Inviter",
      td_budget_breakdown: "Répartition estimée du budget",

      edittrip_kicker: "Modifier le voyage", edittrip_heading: "Mettez à jour votre voyage", edittrip_sub: "Modifiez n'importe quel détail ci-dessous et enregistrez.", edittrip_save: "Enregistrer"
    },

    de: {
      nav_home: "Startseite", nav_about: "Über uns", nav_how: "So funktioniert's", nav_features: "Funktionen",
      nav_contact: "Kontakt", nav_login: "Anmelden", nav_getstarted: "Loslegen",
      nav_dashboard: "Dashboard", nav_logout: "Abmelden", nav_admin: "Admin",

      hero_eyebrow: "KI-geplant, budgetorientiert",
      hero_lead: "Die meisten Reiseseiten geben Ihnen einen Haufen Hotels, Bewertungen und Flüge und überlassen die Planung Ihnen. Nennen Sie uns Ihr Budget, Ihre Tage und Ihre Interessen — wir planen die ganze Reise, Tag für Tag.",
      hero_cta_primary: "Meine Reise planen →", hero_cta_secondary: "So funktioniert's ansehen",
      hero_micro: "Ein Formular rein, ein kompletter Tagesplan raus",
      hero_visual_line: "Sie bestimmen die Form der Reise. Die KI füllt den Rest — Unterkünfte, Essen und Aktivitäten, Tag für Tag.",
      hero_output_label: "Ergebnis", hero_output_value: "Ein vollständiger Tagesplan",
      chip_budget_t: "Budget", chip_budget_d: "Beliebiger Betrag",
      chip_days_t: "Tage", chip_days_d: "Beliebige Länge",
      chip_style_t: "Stil", chip_style_d: "Solo · Familie",

      about_kicker: "Über uns", about_heading: "Wir finden, Reiseplanung sollte Minuten dauern, nicht Abende.",
      about_stat1: "Eingaben zum Starten nötig", about_stat2: "KI-generiert, Tag für Tag",

      how_kicker: "So funktioniert's", how_heading: "Vier Angaben. Ein kompletter Plan.",
      how_sub: "Alles Weitere — Hotels, Essen, Aktivitäten, Wetter — wird aus Ihren Angaben generiert.",
      step1_t: "Budget festlegen", step1_d: "Gesamtausgaben für die Reise. Jeder Vorschlag danach passt hinein.",
      step2_t: "Tage wählen", step2_d: "Wie lange Sie reisen — von einem kurzen Wochenende bis zu zwei Wochen.",
      step3_t: "Stil angeben", step3_d: "Solo, Familie oder mit Freunden. Das bestimmt Tempo und Unterkünfte.",
      step4_t: "Reiseplan erhalten", step4_d: "Ein Tagesplan mit Essen, Unterkünften und Aktivitäten — bereit zum Speichern oder Herunterladen.",

      features_kicker: "Das bekommen Sie", features_heading: "Rund um die Reise gebaut, nicht um die Buchung.",
      features_sub: "Andere Plattformen enden bei Suchergebnissen. Diese macht weiter, bis Sie einen fertigen Plan haben.",
      feat1_t: "Budgetbewusste Vorschläge", feat1_d: "Hotels, Essen und Aktivitäten werden passend zu Ihrem Budget ausgewählt.",
      feat2_t: "Wetter inklusive", feat2_d: "Sehen Sie die Vorhersage für jeden Reisetag, bevor Sie packen.",
      feat3_t: "Tag-für-Tag-Struktur", feat3_d: "Eine echte Abfolge, damit Sie wissen, was an Tag 2 gegenüber Tag 4 passiert.",
      feat4_t: "Vorher ansehen", feat4_d: "Fotos und kurze Videos Ihrer Ziele, direkt neben dem Plan.",
      feat5_t: "Als PDF herunterladen", feat5_d: "Behalten Sie eine Offline-Kopie Ihres Reiseplans — kein Empfang bei Ankunft nötig.",
      feat6_t: "Jederzeit bearbeiten", feat6_d: "Pläne ändern sich. Kommen Sie zurück und passen Sie jeden Tag an, wann immer nötig.",

      contact_kicker: "Kontakt", contact_heading: "Fragen, bevor Sie loslegen?", contact_sub: "Melden Sie sich, wir antworten Ihnen.",
      contact_email_l: "E-Mail", contact_phone_l: "Telefon", contact_based_l: "Standort",
      contact_name_ph: "Ihr Name", contact_email_ph: "Ihre E-Mail", contact_msg_ph: "Ihre Nachricht", contact_send: "Nachricht senden",

      cta_heading: "Ihre nächste Reise ist nur ein Formular entfernt.", cta_sub: "Budget festlegen, Tage wählen und den Plan sich selbst erstellen lassen.", cta_button: "Kostenlos starten →",
      footer_note: "Erstellt mit Java · MySQL · Gemini API",

      auth_login_title: "Willkommen zurück", auth_login_sub: "Melden Sie sich an, um Ihre gespeicherten Reisen und Pläne zu sehen.",
      auth_email_label: "E-Mail", auth_password_label: "Passwort", auth_remember: "Angemeldet bleiben", auth_forgot: "Passwort vergessen?",
      auth_login_btn: "Anmelden", auth_login_switch: "Noch kein Konto?", auth_login_switch_link: "Hier registrieren",

      auth_register_title: "Konto erstellen", auth_register_sub: "Beginnen Sie in unter einer Minute mit der KI-Reiseplanung.",
      auth_name_label: "Vollständiger Name", auth_phone_label: "Telefonnummer", auth_confirm_label: "Passwort bestätigen",
      auth_register_btn: "Konto erstellen", auth_register_switch: "Schon ein Konto?", auth_register_switch_link: "Anmelden",

      otp_title: "Prüfen Sie Ihre E-Mail", otp_verify_btn: "Bestätigen",

      tripform_kicker: "Neue Reise", tripform_heading: "Beschreiben Sie Ihre Reise", tripform_sub: "Vier Angaben — den Rest übernehmen wir.",
      tripform_dest_label: "Ziele", tripform_dest_hint: "(fügen Sie alle Orte hinzu, die Sie besuchen möchten)",
      tripform_addstop: "+ Weiteren Stopp hinzufügen",
      tripform_budget_label: "Budget", tripform_budget_hint: "(gesamt für die Reise)",
      tripform_days_label: "Anzahl der Tage", tripform_style_label: "Reisestil", tripform_style_select: "Auswählen",
      tripform_interests_label: "Interessen", tripform_interests_hint: "(mindestens eines auswählen)",
      tripform_submit: "Reisedetails speichern",
      interest_nature: "Natur", interest_food: "Essen", interest_adventure: "Abenteuer",
      interest_culture: "Kultur", interest_relax: "Entspannung", interest_shopping: "Einkaufen",
      style_solo: "Solo", style_family: "Familie", style_friends: "Freunde", style_couple: "Paar",

      dashboard_heading: "Ihre Reisen", dashboard_sub: "Jede geplante Reise, an einem Ort.",
      dashboard_newtrip: "+ Neue Reise", dashboard_empty: "Sie haben noch keine Reise geplant.",
      dashboard_empty_cta: "Planen Sie Ihre erste Reise →", dashboard_view: "Ansehen", dashboard_edit: "Bearbeiten", dashboard_delete: "Löschen",
      dashboard_shared_badge: "Mit Ihnen geteilt",

      td_kicker: "Reisedetails", td_download: "Als PDF herunterladen", td_regenerate: "Reiseplan neu erstellen",
      td_share: "Reise teilen", td_itinerary_heading: "Tagesplan",
      td_generate_btn: "Reiseplan mit KI erstellen", td_generate_wait: "Das kann 20-30 Sekunden dauern — bitte diesen Tab nicht schließen.",
      td_empty_p1: "Für diese Reise wurde noch kein KI-Plan erstellt.", td_empty_p2: "Klicken Sie unten, und die KI erstellt Ihren Tagesplan.",
      td_activities: "Aktivitäten", td_food: "Essen", td_stay: "Unterkunft", td_weather: "Wetter",
      td_forecast_badge: "Vorhersage", td_seasonal_badge: "Saisonale Schätzung",
      td_route_heading: "Optimierte Route:", td_total_distance: "Gesamtstrecke:",
      td_budget_label: "Budget", td_duration_label: "Dauer", td_style_label: "Stil", td_interests_label: "Interessen",
      td_current_weather: "Aktuelles Wetter in",
      td_expenses_heading: "Ausgaben", td_expense_add: "Ausgabe hinzufügen", td_expense_category: "Kategorie",
      td_expense_desc: "Beschreibung", td_expense_amount: "Betrag", td_expense_spent: "Bisher ausgegeben",
      td_collab_heading: "Mitwirkende", td_collab_invite: "Per E-Mail einladen", td_collab_add: "Einladen",
      td_budget_breakdown: "Geschätzte Budgetaufteilung",

      edittrip_kicker: "Reise bearbeiten", edittrip_heading: "Reise aktualisieren", edittrip_sub: "Ändern Sie unten beliebige Details und speichern Sie.", edittrip_save: "Änderungen speichern"
    },

    es: {
      nav_home: "Inicio", nav_about: "Sobre nosotros", nav_how: "Cómo funciona", nav_features: "Funciones",
      nav_contact: "Contacto", nav_login: "Iniciar sesión", nav_getstarted: "Empezar",
      nav_dashboard: "Panel", nav_logout: "Cerrar sesión", nav_admin: "Admin",

      hero_eyebrow: "Planificado por IA, con el presupuesto primero",
      hero_lead: "La mayoría de los sitios de viajes te dan un montón de hoteles, reseñas y vuelos y te dejan la planificación a ti. Dinos tu presupuesto, tus días y tus intereses — organizamos todo el viaje, día a día.",
      hero_cta_primary: "Planificar mi viaje →", hero_cta_secondary: "Ver cómo funciona",
      hero_micro: "Un formulario, un plan diario completo",
      hero_visual_line: "Tú defines la forma del viaje. La IA completa el resto: alojamiento, comida y actividades, día a día.",
      hero_output_label: "Resultado", hero_output_value: "Un itinerario diario completo",
      chip_budget_t: "Presupuesto", chip_budget_d: "Cualquier cantidad",
      chip_days_t: "Días", chip_days_d: "Cualquier duración",
      chip_style_t: "Estilo", chip_style_d: "Solo · familia",

      about_kicker: "Sobre nosotros", about_heading: "Creemos que planificar un viaje debería tomar minutos, no noches enteras.",
      about_stat1: "datos necesarios para empezar", about_stat2: "generado por IA, día a día",

      how_kicker: "Cómo funciona", how_heading: "Cuatro datos. Un plan completo.",
      how_sub: "Todo lo demás — hoteles, comida, actividades, clima — se genera a partir de lo que nos indiques.",
      step1_t: "Define tu presupuesto", step1_d: "Gasto total del viaje. Cada sugerencia se ajustará a él.",
      step2_t: "Elige tus días", step2_d: "Cuánto durará tu viaje — desde un fin de semana hasta dos semanas.",
      step3_t: "Indica el estilo", step3_d: "Solo, en familia o con amigos. Esto define el ritmo y el alojamiento sugerido.",
      step4_t: "Recibe tu itinerario", step4_d: "Un plan diario con comida, alojamiento y actividades — listo para guardar o descargar.",

      features_kicker: "Lo que obtienes", features_heading: "Diseñado en torno al viaje, no a la reserva.",
      features_sub: "Otras plataformas se detienen en los resultados de búsqueda. Esta sigue hasta darte un plan completo.",
      feat1_t: "Sugerencias según tu presupuesto", feat1_d: "Hoteles, comida y actividades elegidos para ajustarse a lo que definiste.",
      feat2_t: "Clima incluido", feat2_d: "Consulta el pronóstico de cada día de tu viaje antes de hacer la maleta.",
      feat3_t: "Estructura día a día", feat3_d: "Una secuencia real, para saber qué pasa el día 2 frente al día 4.",
      feat4_t: "Míralo antes de ir", feat4_d: "Fotos y videos cortos de tus destinos, junto al plan.",
      feat5_t: "Descarga en PDF", feat5_d: "Guarda una copia sin conexión de tu itinerario — sin necesidad de señal al llegar.",
      feat6_t: "Edita cuando quieras", feat6_d: "Los planes cambian. Vuelve y ajusta cualquier día cuando lo necesites.",

      contact_kicker: "Contacto", contact_heading: "¿Preguntas antes de empezar a planificar?", contact_sub: "Escríbenos y te responderemos.",
      contact_email_l: "Correo", contact_phone_l: "Teléfono", contact_based_l: "Ubicados en",
      contact_name_ph: "Tu nombre", contact_email_ph: "Tu correo", contact_msg_ph: "Tu mensaje", contact_send: "Enviar mensaje",

      cta_heading: "Tu próximo viaje está a un formulario de distancia.", cta_sub: "Define un presupuesto, elige tus días y deja que el plan se construya solo.", cta_button: "Empieza gratis →",
      footer_note: "Creado con Java · MySQL · Gemini API",

      auth_login_title: "Bienvenido de nuevo", auth_login_sub: "Inicia sesión para ver tus viajes e itinerarios guardados.",
      auth_email_label: "Correo", auth_password_label: "Contraseña", auth_remember: "Recordarme", auth_forgot: "¿Olvidaste tu contraseña?",
      auth_login_btn: "Iniciar sesión", auth_login_switch: "¿No tienes cuenta?", auth_login_switch_link: "Regístrate aquí",

      auth_register_title: "Crea tu cuenta", auth_register_sub: "Empieza a planificar viajes con IA en menos de un minuto.",
      auth_name_label: "Nombre completo", auth_phone_label: "Número de teléfono", auth_confirm_label: "Confirmar contraseña",
      auth_register_btn: "Crear cuenta", auth_register_switch: "¿Ya tienes cuenta?", auth_register_switch_link: "Iniciar sesión",

      otp_title: "Revisa tu correo", otp_verify_btn: "Verificar",

      tripform_kicker: "Nuevo viaje", tripform_heading: "Cuéntanos la forma de tu viaje", tripform_sub: "Cuatro datos — nosotros nos encargamos del resto.",
      tripform_dest_label: "Destinos", tripform_dest_hint: "(añade todos los lugares que quieras visitar)",
      tripform_addstop: "+ Añadir otra parada",
      tripform_budget_label: "Presupuesto", tripform_budget_hint: "(total del viaje)",
      tripform_days_label: "Número de días", tripform_style_label: "Estilo de viaje", tripform_style_select: "Selecciona uno",
      tripform_interests_label: "Intereses", tripform_interests_hint: "(elige al menos uno)",
      tripform_submit: "Guardar detalles del viaje",
      interest_nature: "Naturaleza", interest_food: "Comida", interest_adventure: "Aventura",
      interest_culture: "Cultura", interest_relax: "Relax", interest_shopping: "Compras",
      style_solo: "Solo", style_family: "Familia", style_friends: "Amigos", style_couple: "Pareja",

      dashboard_heading: "Tus viajes", dashboard_sub: "Cada viaje que has planificado, en un solo lugar.",
      dashboard_newtrip: "+ Nuevo viaje", dashboard_empty: "Aún no has planificado ningún viaje.",
      dashboard_empty_cta: "Planifica tu primer viaje →", dashboard_view: "Ver", dashboard_edit: "Editar", dashboard_delete: "Eliminar",
      dashboard_shared_badge: "Compartido contigo",

      td_kicker: "Detalles del viaje", td_download: "Descargar en PDF", td_regenerate: "Regenerar itinerario",
      td_share: "Compartir viaje", td_itinerary_heading: "Itinerario diario",
      td_generate_btn: "Generar itinerario con IA", td_generate_wait: "Esto puede tardar 20-30 segundos — no cierres esta pestaña.",
      td_empty_p1: "Aún no se ha generado un itinerario de IA para este viaje.", td_empty_p2: "Haz clic abajo y la IA creará tu plan diario.",
      td_activities: "Actividades", td_food: "Comida", td_stay: "Alojamiento", td_weather: "Clima",
      td_forecast_badge: "Pronóstico", td_seasonal_badge: "Estimación estacional",
      td_route_heading: "Ruta optimizada:", td_total_distance: "Distancia total:",
      td_budget_label: "Presupuesto", td_duration_label: "Duración", td_style_label: "Estilo", td_interests_label: "Intereses",
      td_current_weather: "Clima actual en",
      td_expenses_heading: "Gastos", td_expense_add: "Añadir gasto", td_expense_category: "Categoría",
      td_expense_desc: "Descripción", td_expense_amount: "Importe", td_expense_spent: "Gastado hasta ahora",
      td_collab_heading: "Colaboradores", td_collab_invite: "Invitar por correo", td_collab_add: "Invitar",
      td_budget_breakdown: "Desglose estimado del presupuesto",

      edittrip_kicker: "Editar viaje", edittrip_heading: "Actualiza tu viaje", edittrip_sub: "Cambia cualquier detalle abajo y guarda.", edittrip_save: "Guardar cambios"
    }
  };

  function currentLang() {
    try { return localStorage.getItem('voyantra_lang') || 'en'; } catch (e) { return 'en'; }
  }

  function setLang(lang) {
    try { localStorage.setItem('voyantra_lang', lang); } catch (e) {}
    applyLang(lang);
  }

  function applyLang(lang) {
    var dict = TRANSLATIONS[lang] || TRANSLATIONS.en;
    var fallback = TRANSLATIONS.en;

    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      var value = dict[key] || fallback[key];
      if (value !== undefined) el.textContent = value;
    });
    document.querySelectorAll('[data-i18n-placeholder]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-placeholder');
      var value = dict[key] || fallback[key];
      if (value !== undefined) el.setAttribute('placeholder', value);
    });

    var select = document.getElementById('voyantraLangSelect');
    if (select) select.value = lang;
    document.documentElement.setAttribute('lang', lang === 'en' ? 'en' : lang);
  }

  // The switcher UI renders only where the page provides a slot element
  // (#langSwitcherSlot) — today that's just the header on index.jsp.
  // Every other page still translates via the saved preference, it just
  // doesn't show its own picker, so the control isn't scattered/overlapping
  // across every screen.
  function injectSwitcher() {
    var slot = document.getElementById('langSwitcherSlot');
    if (!slot || document.getElementById('voyantraLangSelect')) return;

    if (!document.getElementById('voyantraLangStyle')) {
      var style = document.createElement('style');
      style.id = 'voyantraLangStyle';
      style.textContent =
        '#langSwitcherSlot { display: flex; align-items: center; margin-right: 4px; }' +
        '.voyantra-lang-select {' +
        '  appearance: none; -webkit-appearance: none; -moz-appearance: none;' +
        '  background-color: var(--ink-2, #131F38);' +
        '  background-image: url("data:image/svg+xml;utf8,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22 fill=%22none%22 stroke=%22%23E7A94C%22 stroke-width=%222%22 stroke-linecap=%22round%22 stroke-linejoin=%22round%22><polyline points=%226 9 12 15 18 9%22/></svg>");' +
        '  background-repeat: no-repeat; background-position: right 10px center; background-size: 13px;' +
        '  color: var(--paper, #F6F2E9);' +
        '  border: 1px solid var(--line-strong, rgba(246,242,233,0.28));' +
        '  border-radius: 999px;' +
        '  padding: 9px 30px 9px 15px;' +
        '  font-size: 0.82rem; font-weight: 600; font-family: Inter, sans-serif;' +
        '  cursor: pointer; line-height: 1;' +
        '  transition: border-color 0.2s ease, background-color 0.2s ease;' +
        '}' +
        '.voyantra-lang-select:hover { border-color: var(--gold, #E7A94C); }' +
        '.voyantra-lang-select:focus { outline: none; border-color: var(--gold, #E7A94C); }' +
        '.voyantra-lang-select option { background-color: #131F38; color: #F6F2E9; }';
      document.head.appendChild(style);
    }

    var select = document.createElement('select');
    select.id = 'voyantraLangSelect';
    select.className = 'voyantra-lang-select';

    LANGUAGES.forEach(function (l) {
      var opt = document.createElement('option');
      opt.value = l.code;
      opt.textContent = l.label;
      select.appendChild(opt);
    });

    select.addEventListener('change', function () { setLang(this.value); });
    slot.appendChild(select);
  }

  document.addEventListener('DOMContentLoaded', function () {
    injectSwitcher();
    applyLang(currentLang());
  });

  window.VoyantraI18n = { setLang: setLang, applyLang: applyLang, currentLang: currentLang };
})();

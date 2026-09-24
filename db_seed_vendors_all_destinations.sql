-- Seed data: local vendors across popular Indian tourist destinations.
-- Fictional-but-plausible demo listings (not real scraped businesses),
-- all owned by the "Voyantra Local Partners" demo account (user_id 3),
-- pre-approved so the trip-page recommendation panels have real content
-- to show for these destinations.

USE travel_planner_db;

INSERT INTO vendors (user_id, business_name, category, description, city, state, phone, price_range, status, latitude, longitude, diet_type, signature_dish) VALUES
-- Goa
(3, 'Palm Grove Beach Resort', 'HOTEL', 'Beachside resort with pool and sea-facing rooms.', 'Goa', 'Goa', '9500000101', 'Rs. 3500-6000/night', 'APPROVED', 15.4989, 73.8278, NULL, NULL),
(3, 'Coconut Creek Homestay', 'HOMESTAY', 'Quiet homestay near the beach, run by a local fishing family.', 'Goa', 'Goa', '9500000102', 'Rs. 1800-2800/night', 'APPROVED', 15.4860, 73.8210, NULL, NULL),
(3, 'Saraswat Bhavan', 'RESTAURANT', 'Traditional Goan vegetarian thali and coastal snacks.', 'Goa', 'Goa', '9500000103', 'Rs. 200-400', 'APPROVED', 15.4930, 73.8250, 'VEG', 'Goan Veg Thali'),
(3, 'Anchor Shack', 'RESTAURANT', 'Beach shack known for fresh catch and Goan curries.', 'Goa', 'Goa', '9500000104', 'Rs. 350-700', 'APPROVED', 15.4870, 73.8190, 'BOTH', 'Goan Fish Curry & Prawn Balchao'),
(3, 'Goa Heritage Walks', 'GUIDE', 'Guided walks through old Goan quarters and Portuguese-era churches.', 'Goa', 'Goa', '9500000105', 'Rs. 700-1200/person', 'APPROVED', 15.4989, 73.8278, NULL, NULL),
(3, 'Goa Watersports Co.', 'ACTIVITY', 'Parasailing, jet-ski and banana boat rides.', 'Goa', 'Goa', '9500000106', 'Rs. 500-1500/person', 'APPROVED', 15.4900, 73.8230, NULL, NULL),

-- Manali
(3, 'Solang Valley Hotel', 'HOTEL', 'Mountain-view hotel close to Solang Valley.', 'Manali', 'Himachal Pradesh', '9500000201', 'Rs. 2800-4500/night', 'APPROVED', 32.2432, 77.1892, NULL, NULL),
(3, 'Apple Orchard Homestay', 'HOMESTAY', 'Family homestay set inside an apple orchard.', 'Manali', 'Himachal Pradesh', '9500000202', 'Rs. 1600-2400/night', 'APPROVED', 32.2500, 77.1800, NULL, NULL),
(3, 'Himachali Rasoi', 'RESTAURANT', 'Home-style Himachali vegetarian thali and dham.', 'Manali', 'Himachal Pradesh', '9500000203', 'Rs. 200-400', 'APPROVED', 32.2450, 77.1850, 'VEG', 'Himachali Dham Thali'),
(3, 'Mountain Grill House', 'RESTAURANT', 'Local and Tibetan-influenced non-vegetarian dishes.', 'Manali', 'Himachal Pradesh', '9500000204', 'Rs. 300-600', 'APPROVED', 32.2410, 77.1870, 'BOTH', 'Chicken Anardana'),
(3, 'Manali Trekking Guides', 'GUIDE', 'Guided treks to Solang Valley, Hampta Pass base and nearby trails.', 'Manali', 'Himachal Pradesh', '9500000205', 'Rs. 1000-2500/person', 'APPROVED', 32.2432, 77.1892, NULL, NULL),
(3, 'Manali Adventure Sports', 'ACTIVITY', 'Paragliding, river rafting and zorbing.', 'Manali', 'Himachal Pradesh', '9500000206', 'Rs. 800-2000/person', 'APPROVED', 32.2470, 77.1830, NULL, NULL),

-- Jaipur
(3, 'Pink City Heritage Hotel', 'HOTEL', 'Rajasthani haveli-style hotel near the old city.', 'Jaipur', 'Rajasthan', '9500000301', 'Rs. 3000-5500/night', 'APPROVED', 26.9124, 75.7873, NULL, NULL),
(3, 'Rajwada Homestay', 'HOMESTAY', 'Homestay in a traditional Rajasthani haveli.', 'Jaipur', 'Rajasthan', '9500000302', 'Rs. 1800-3000/night', 'APPROVED', 26.9200, 75.7950, NULL, NULL),
(3, 'Laxmi Misthan Bhandar', 'RESTAURANT', 'Iconic Rajasthani vegetarian thali and sweets.', 'Jaipur', 'Rajasthan', '9500000303', 'Rs. 200-450', 'APPROVED', 26.9150, 75.8250, 'VEG', 'Dal Baati Churma'),
(3, 'Rawat Mahal Kitchen', 'RESTAURANT', 'Royal Rajasthani non-vegetarian specialties.', 'Jaipur', 'Rajasthan', '9500000304', 'Rs. 350-700', 'APPROVED', 26.9100, 75.7900, 'BOTH', 'Laal Maas'),
(3, 'Jaipur Heritage Tours', 'GUIDE', 'Guided tours of Amber Fort, City Palace and old-city bazaars.', 'Jaipur', 'Rajasthan', '9500000305', 'Rs. 800-1500/person', 'APPROVED', 26.9124, 75.7873, NULL, NULL),
(3, 'Jaipur Hot Air Balloons', 'ACTIVITY', 'Sunrise hot-air balloon rides over Amber Fort.', 'Jaipur', 'Rajasthan', '9500000306', 'Rs. 8000-12000/person', 'APPROVED', 26.9850, 75.8510, NULL, NULL),

-- Udaipur
(3, 'Lake View Palace Hotel', 'HOTEL', 'Hotel overlooking Lake Pichola with rooftop dining.', 'Udaipur', 'Rajasthan', '9500000401', 'Rs. 3500-6500/night', 'APPROVED', 24.5854, 73.7125, NULL, NULL),
(3, 'Haveli Courtyard Homestay', 'HOMESTAY', 'Traditional haveli homestay near the old city gates.', 'Udaipur', 'Rajasthan', '9500000402', 'Rs. 2000-3200/night', 'APPROVED', 24.5780, 73.6830, NULL, NULL),
(3, 'Ambrai Vegetarian', 'RESTAURANT', 'Lakeside vegetarian dining with a view of the City Palace.', 'Udaipur', 'Rajasthan', '9500000403', 'Rs. 250-500', 'APPROVED', 24.5810, 73.6800, 'VEG', 'Gatte ki Sabzi Thali'),
(3, 'Mewar Kitchen', 'RESTAURANT', 'Mewar-region non-vegetarian specialties.', 'Udaipur', 'Rajasthan', '9500000404', 'Rs. 350-650', 'APPROVED', 24.5830, 73.6850, 'BOTH', 'Laal Maas'),
(3, 'Udaipur City Walks', 'GUIDE', 'Guided walks through the old city and lakeside ghats.', 'Udaipur', 'Rajasthan', '9500000405', 'Rs. 700-1300/person', 'APPROVED', 24.5854, 73.7125, NULL, NULL),
(3, 'Lake Pichola Boat Rides', 'ACTIVITY', 'Sunset boat rides on Lake Pichola.', 'Udaipur', 'Rajasthan', '9500000406', 'Rs. 400-900/person', 'APPROVED', 24.5760, 73.6790, NULL, NULL),

-- Rishikesh
(3, 'Ganga View Hotel', 'HOTEL', 'Riverside hotel with views of the Ganga and the hills.', 'Rishikesh', 'Uttarakhand', '9500000501', 'Rs. 2000-3800/night', 'APPROVED', 30.0869, 78.2676, NULL, NULL),
(3, 'Beatles Ashram Homestay', 'HOMESTAY', 'Peaceful homestay near Laxman Jhula, popular with yoga travellers.', 'Rishikesh', 'Uttarakhand', '9500000502', 'Rs. 1200-2000/night', 'APPROVED', 30.1000, 78.2900, NULL, NULL),
(3, 'Satvik Kitchen', 'RESTAURANT', 'Purely vegetarian, no onion-garlic satvik meals.', 'Rishikesh', 'Uttarakhand', '9500000503', 'Rs. 150-300', 'APPROVED', 30.0900, 78.2750, 'VEG', 'Rajma Chawal Thali'),
(3, 'Ganga Beach Cafe', 'RESTAURANT', 'Riverside cafe with wood-fired pizza and Israeli dishes (vegetarian, alcohol-free town).', 'Rishikesh', 'Uttarakhand', '9500000504', 'Rs. 250-500', 'APPROVED', 30.0950, 78.2800, 'VEG', 'Wood-fired Pizza & Hummus Platter'),
(3, 'Rishikesh River Guides', 'GUIDE', 'Certified guides for Himalayan foothill treks.', 'Rishikesh', 'Uttarakhand', '9500000505', 'Rs. 800-1500/person', 'APPROVED', 30.0869, 78.2676, NULL, NULL),
(3, 'Rishikesh White Water Rafting', 'ACTIVITY', 'Grade II-III rafting on the Ganga.', 'Rishikesh', 'Uttarakhand', '9500000506', 'Rs. 500-1200/person', 'APPROVED', 30.1200, 78.3100, NULL, NULL),

-- Coorg
(3, 'Coffee Estate Resort', 'HOTEL', 'Resort set inside a working coffee estate.', 'Coorg', 'Karnataka', '9500000601', 'Rs. 3000-5000/night', 'APPROVED', 12.4244, 75.7382, NULL, NULL),
(3, 'Kodava Heritage Homestay', 'HOMESTAY', 'Traditional Kodava family homestay with estate walks.', 'Coorg', 'Karnataka', '9500000602', 'Rs. 1800-2800/night', 'APPROVED', 12.4300, 75.7300, NULL, NULL),
(3, 'Coorg Coffee House', 'RESTAURANT', 'Local filter coffee and vegetarian breakfast specialties.', 'Coorg', 'Karnataka', '9500000603', 'Rs. 150-350', 'APPROVED', 12.4260, 75.7400, 'VEG', 'Akki Roti & Filter Coffee'),
(3, 'Kodava Kitchen', 'RESTAURANT', 'Authentic Kodava-style pork and chicken curries.', 'Coorg', 'Karnataka', '9500000604', 'Rs. 300-600', 'APPROVED', 12.4220, 75.7350, 'BOTH', 'Coorg Pandi Curry'),
(3, 'Coorg Plantation Trails', 'GUIDE', 'Guided coffee and spice plantation walks.', 'Coorg', 'Karnataka', '9500000605', 'Rs. 500-1000/person', 'APPROVED', 12.4244, 75.7382, NULL, NULL),
(3, 'Coorg River Rafting', 'ACTIVITY', 'White-water rafting on the Barapole river.', 'Coorg', 'Karnataka', '9500000606', 'Rs. 700-1500/person', 'APPROVED', 12.3900, 75.9500, NULL, NULL),

-- Kodaikanal
(3, 'Lake View Kodai Hotel', 'HOTEL', 'Hotel near Kodaikanal Lake with valley views.', 'Kodaikanal', 'Tamil Nadu', '9500000701', 'Rs. 2500-4200/night', 'APPROVED', 10.2381, 77.4892, NULL, NULL),
(3, 'Pine Forest Homestay', 'HOMESTAY', 'Cottage-style homestay near the pine forest trail.', 'Kodaikanal', 'Tamil Nadu', '9500000702', 'Rs. 1600-2500/night', 'APPROVED', 10.2450, 77.4950, NULL, NULL),
(3, 'Hill Station Tiffin Centre', 'RESTAURANT', 'South Indian vegetarian breakfast and meals.', 'Kodaikanal', 'Tamil Nadu', '9500000703', 'Rs. 150-300', 'APPROVED', 10.2400, 77.4900, 'VEG', 'Idiyappam & Kurma'),
(3, 'Kodai Chettinad Kitchen', 'RESTAURANT', 'Chettinad-style spicy non-vegetarian dishes.', 'Kodaikanal', 'Tamil Nadu', '9500000704', 'Rs. 300-550', 'APPROVED', 10.2360, 77.4870, 'BOTH', 'Chettinad Chicken'),
(3, 'Kodai Nature Trails', 'GUIDE', 'Guided walks around Coakers Walk and Pillar Rocks.', 'Kodaikanal', 'Tamil Nadu', '9500000705', 'Rs. 500-1000/person', 'APPROVED', 10.2381, 77.4892, NULL, NULL),
(3, 'Kodai Lake Boating', 'ACTIVITY', 'Pedal boats and rowboats on Kodaikanal Lake.', 'Kodaikanal', 'Tamil Nadu', '9500000706', 'Rs. 150-350/person', 'APPROVED', 10.2380, 77.4880, NULL, NULL),

-- Shimla
(3, 'Mall Road Heritage Hotel', 'HOTEL', 'Colonial-era hotel near Shimla Mall Road.', 'Shimla', 'Himachal Pradesh', '9500000801', 'Rs. 2800-4800/night', 'APPROVED', 31.1048, 77.1734, NULL, NULL),
(3, 'Ridge View Homestay', 'HOMESTAY', 'Family homestay with a view of the Ridge.', 'Shimla', 'Himachal Pradesh', '9500000802', 'Rs. 1700-2600/night', 'APPROVED', 31.1030, 77.1720, NULL, NULL),
(3, 'Himachali Thali House', 'RESTAURANT', 'Traditional Himachali vegetarian thali.', 'Shimla', 'Himachal Pradesh', '9500000803', 'Rs. 200-400', 'APPROVED', 31.1040, 77.1740, 'VEG', 'Himachali Siddu'),
(3, 'Shimla Grill', 'RESTAURANT', 'North Indian and Tibetan-style non-vegetarian food.', 'Shimla', 'Himachal Pradesh', '9500000804', 'Rs. 300-600', 'APPROVED', 31.1020, 77.1700, 'BOTH', 'Chicken Chha Gosht'),
(3, 'Shimla Heritage Walks', 'GUIDE', 'Guided walks through colonial-era Shimla.', 'Shimla', 'Himachal Pradesh', '9500000805', 'Rs. 600-1200/person', 'APPROVED', 31.1048, 77.1734, NULL, NULL),
(3, 'Kufri Adventure Sports', 'ACTIVITY', 'Skiing (winter) and horse riding near Kufri.', 'Shimla', 'Himachal Pradesh', '9500000806', 'Rs. 500-1500/person', 'APPROVED', 31.0980, 77.2680, NULL, NULL),

-- Darjeeling
(3, 'Tea Garden View Hotel', 'HOTEL', 'Hotel overlooking Darjeeling tea gardens and Kanchenjunga.', 'Darjeeling', 'West Bengal', '9500000901', 'Rs. 2800-4500/night', 'APPROVED', 27.0410, 88.2663, NULL, NULL),
(3, 'Himalayan Homestay', 'HOMESTAY', 'Family homestay with mountain-view rooms.', 'Darjeeling', 'West Bengal', '9500000902', 'Rs. 1600-2400/night', 'APPROVED', 27.0450, 88.2700, NULL, NULL),
(3, 'Darjeeling Momo House', 'RESTAURANT', 'Vegetarian momos, thukpa and local Nepali dishes.', 'Darjeeling', 'West Bengal', '9500000903', 'Rs. 150-300', 'APPROVED', 27.0400, 88.2650, 'VEG', 'Veg Momos & Thukpa'),
(3, 'Kanchenjunga Kitchen', 'RESTAURANT', 'Nepali and Tibetan-style non-vegetarian dishes.', 'Darjeeling', 'West Bengal', '9500000904', 'Rs. 250-450', 'APPROVED', 27.0420, 88.2670, 'BOTH', 'Chicken Momos & Gundruk'),
(3, 'Darjeeling Tea Trails', 'GUIDE', 'Guided tea garden and monastery tours.', 'Darjeeling', 'West Bengal', '9500000905', 'Rs. 500-1000/person', 'APPROVED', 27.0410, 88.2663, NULL, NULL),
(3, 'Tiger Hill Sunrise Tours', 'ACTIVITY', 'Early morning sunrise viewing at Tiger Hill.', 'Darjeeling', 'West Bengal', '9500000906', 'Rs. 300-600/person', 'APPROVED', 27.0000, 88.2600, NULL, NULL),

-- Pondicherry
(3, 'French Quarter Hotel', 'HOTEL', 'Boutique hotel in the French Quarter near the promenade.', 'Pondicherry', 'Puducherry', '9500001001', 'Rs. 3200-5500/night', 'APPROVED', 11.9330, 79.8300, NULL, NULL),
(3, 'Auroville Homestay', 'HOMESTAY', 'Homestay near Auroville with a peaceful garden.', 'Pondicherry', 'Puducherry', '9500001002', 'Rs. 1800-2800/night', 'APPROVED', 11.9990, 79.8100, NULL, NULL),
(3, 'Sri Krishna Bhavan', 'RESTAURANT', 'South Indian vegetarian meals and tiffin.', 'Pondicherry', 'Puducherry', '9500001003', 'Rs. 150-300', 'APPROVED', 11.9420, 79.8080, 'VEG', 'South Indian Thali'),
(3, 'Promenade Fish Kitchen', 'RESTAURANT', 'French-Tamil fusion seafood along the promenade.', 'Pondicherry', 'Puducherry', '9500001004', 'Rs. 350-700', 'APPROVED', 11.9330, 79.8340, 'BOTH', 'Fish Curry Fusion'),
(3, 'Pondicherry Heritage Walks', 'GUIDE', 'Guided walks through the French Quarter.', 'Pondicherry', 'Puducherry', '9500001005', 'Rs. 500-1000/person', 'APPROVED', 11.9416, 79.8083, NULL, NULL),
(3, 'Auroville Cycling Tours', 'ACTIVITY', 'Guided cycling tours around Auroville.', 'Pondicherry', 'Puducherry', '9500001006', 'Rs. 400-800/person', 'APPROVED', 11.9990, 79.8100, NULL, NULL),

-- Agra
(3, 'Taj View Hotel', 'HOTEL', 'Hotel with rooftop views of the Taj Mahal.', 'Agra', 'Uttar Pradesh', '9500001101', 'Rs. 3000-5500/night', 'APPROVED', 27.1767, 78.0081, NULL, NULL),
(3, 'Mughal Heritage Homestay', 'HOMESTAY', 'Homestay near Taj Mahal East Gate.', 'Agra', 'Uttar Pradesh', '9500001102', 'Rs. 1800-2800/night', 'APPROVED', 27.1730, 78.0430, NULL, NULL),
(3, 'Deviram Sweets', 'RESTAURANT', 'Classic Agra vegetarian breakfast and sweets.', 'Agra', 'Uttar Pradesh', '9500001103', 'Rs. 150-300', 'APPROVED', 27.1900, 78.0100, 'VEG', 'Bedai & Jalebi'),
(3, 'Mughlai Dastarkhwan', 'RESTAURANT', 'Mughlai-style non-vegetarian specialties.', 'Agra', 'Uttar Pradesh', '9500001104', 'Rs. 350-700', 'APPROVED', 27.1800, 78.0200, 'BOTH', 'Mughlai Mutton Korma'),
(3, 'Agra Monument Tours', 'GUIDE', 'Guided tours of the Taj Mahal, Agra Fort and Fatehpur Sikri.', 'Agra', 'Uttar Pradesh', '9500001105', 'Rs. 800-1500/person', 'APPROVED', 27.1767, 78.0081, NULL, NULL),
(3, 'Agra Sunrise Photography Tours', 'ACTIVITY', 'Early morning photography tour of the Taj Mahal.', 'Agra', 'Uttar Pradesh', '9500001106', 'Rs. 500-1000/person', 'APPROVED', 27.1750, 78.0420, NULL, NULL),

-- Varanasi
(3, 'Ganga Ghat Hotel', 'HOTEL', 'Hotel overlooking the ghats and the Ganga.', 'Varanasi', 'Uttar Pradesh', '9500001201', 'Rs. 2500-4200/night', 'APPROVED', 25.3176, 82.9739, NULL, NULL),
(3, 'Old City Homestay', 'HOMESTAY', 'Homestay in the narrow lanes near Kashi Vishwanath.', 'Varanasi', 'Uttar Pradesh', '9500001202', 'Rs. 1500-2400/night', 'APPROVED', 25.3100, 83.0100, NULL, NULL),
(3, 'Kashi Chat Bhandar', 'RESTAURANT', 'Classic Banarasi vegetarian snacks and thali.', 'Varanasi', 'Uttar Pradesh', '9500001203', 'Rs. 100-250', 'APPROVED', 25.3130, 83.0080, 'VEG', 'Kachori Sabzi & Banarasi Thali'),
(3, 'Awadhi Zaika', 'RESTAURANT', 'North Indian non-vegetarian specialties.', 'Varanasi', 'Uttar Pradesh', '9500001204', 'Rs. 250-500', 'APPROVED', 25.3200, 82.9800, 'BOTH', 'Awadhi Mutton Curry'),
(3, 'Varanasi Ghat Walks', 'GUIDE', 'Guided walks and boat tours of the ghats at dawn.', 'Varanasi', 'Uttar Pradesh', '9500001205', 'Rs. 500-1000/person', 'APPROVED', 25.3176, 82.9739, NULL, NULL),
(3, 'Ganga Aarti Boat Tours', 'ACTIVITY', 'Evening boat rides during the Ganga Aarti ceremony.', 'Varanasi', 'Uttar Pradesh', '9500001206', 'Rs. 200-500/person', 'APPROVED', 25.3080, 83.0110, NULL, NULL),

-- Mysore
(3, 'Palace View Hotel', 'HOTEL', 'Hotel near Mysore Palace with heritage decor.', 'Mysore', 'Karnataka', '9500001301', 'Rs. 2500-4200/night', 'APPROVED', 12.2958, 76.6394, NULL, NULL),
(3, 'Royal Mysore Homestay', 'HOMESTAY', 'Homestay in a traditional Mysore-style house.', 'Mysore', 'Karnataka', '9500001302', 'Rs. 1500-2500/night', 'APPROVED', 12.3000, 76.6450, NULL, NULL),
(3, 'Vinayaka Mylari', 'RESTAURANT', 'Famous for soft Mysore-style dosa.', 'Mysore', 'Karnataka', '9500001303', 'Rs. 100-250', 'APPROVED', 12.3050, 76.6500, 'VEG', 'Mysore Masala Dosa'),
(3, 'Mysuru Non-Veg Kitchen', 'RESTAURANT', 'Traditional Mysore-style non-vegetarian curries.', 'Mysore', 'Karnataka', '9500001304', 'Rs. 250-500', 'APPROVED', 12.2900, 76.6350, 'BOTH', 'Mysore Mutton Curry'),
(3, 'Mysore Heritage Tours', 'GUIDE', 'Guided tours of Mysore Palace and Chamundi Hills.', 'Mysore', 'Karnataka', '9500001305', 'Rs. 600-1200/person', 'APPROVED', 12.2958, 76.6394, NULL, NULL),
(3, 'Mysore Palace Light Show Tours', 'ACTIVITY', 'Evening light show viewing and palace grounds tour.', 'Mysore', 'Karnataka', '9500001306', 'Rs. 200-400/person', 'APPROVED', 12.3052, 76.6551, NULL, NULL),

-- Alleppey (Alappuzha)
(3, 'Backwater View Resort', 'HOTEL', 'Resort on the banks of the Alleppey backwaters.', 'Alleppey', 'Kerala', '9500001401', 'Rs. 3000-5500/night', 'APPROVED', 9.4981, 76.3388, NULL, NULL),
(3, 'Houseboat Homestay', 'HOMESTAY', 'Family homestay with backwater canoe rides included.', 'Alleppey', 'Kerala', '9500001402', 'Rs. 1800-2800/night', 'APPROVED', 9.4900, 76.3300, NULL, NULL),
(3, 'Kerala Sadya House', 'RESTAURANT', 'Traditional Kerala vegetarian meals on banana leaf.', 'Alleppey', 'Kerala', '9500001403', 'Rs. 150-300', 'APPROVED', 9.4950, 76.3350, 'VEG', 'Kerala Sadya'),
(3, 'Backwater Seafood Kitchen', 'RESTAURANT', 'Fresh backwater fish and prawn specialties.', 'Alleppey', 'Kerala', '9500001404', 'Rs. 300-600', 'APPROVED', 9.5000, 76.3400, 'BOTH', 'Karimeen Fish Fry'),
(3, 'Alleppey Backwater Guides', 'GUIDE', 'Guided canoe tours through the backwater villages.', 'Alleppey', 'Kerala', '9500001405', 'Rs. 500-1000/person', 'APPROVED', 9.4981, 76.3388, NULL, NULL),
(3, 'Alleppey Houseboat Cruises', 'ACTIVITY', 'Day and overnight houseboat cruises.', 'Alleppey', 'Kerala', '9500001406', 'Rs. 3000-8000/boat', 'APPROVED', 9.4930, 76.3320, NULL, NULL),

-- Leh
(3, 'Himalayan View Hotel', 'HOTEL', 'Hotel with views of the Leh palace and mountains.', 'Leh', 'Ladakh', '9500001501', 'Rs. 2800-4500/night', 'APPROVED', 34.1526, 77.5770, NULL, NULL),
(3, 'Ladakhi Homestay', 'HOMESTAY', 'Traditional Ladakhi family homestay.', 'Leh', 'Ladakh', '9500001502', 'Rs. 1500-2500/night', 'APPROVED', 34.1600, 77.5850, NULL, NULL),
(3, 'Ladakhi Kitchen Veg', 'RESTAURANT', 'Vegetarian Tibetan and Ladakhi dishes.', 'Leh', 'Ladakh', '9500001503', 'Rs. 200-400', 'APPROVED', 34.1550, 77.5800, 'VEG', 'Veg Thukpa & Momos'),
(3, 'Snow Leopard Kitchen', 'RESTAURANT', 'Tibetan and Ladakhi non-vegetarian specialties.', 'Leh', 'Ladakh', '9500001504', 'Rs. 300-550', 'APPROVED', 34.1500, 77.5730, 'BOTH', 'Chicken Momos & Skyu'),
(3, 'Leh Monastery Tours', 'GUIDE', 'Guided tours of Thiksey, Hemis and Shey monasteries.', 'Leh', 'Ladakh', '9500001505', 'Rs. 1000-2000/person', 'APPROVED', 34.1526, 77.5770, NULL, NULL),
(3, 'Ladakh Motorbike Tours', 'ACTIVITY', 'Guided motorbike trips to Khardung La and Pangong Lake.', 'Leh', 'Ladakh', '9500001506', 'Rs. 3000-6000/person', 'APPROVED', 34.1650, 77.5900, NULL, NULL),

-- Jodhpur
(3, 'Blue City Heritage Hotel', 'HOTEL', 'Hotel with views of Mehrangarh Fort and the Blue City.', 'Jodhpur', 'Rajasthan', '9500001601', 'Rs. 3000-5000/night', 'APPROVED', 26.2389, 73.0243, NULL, NULL),
(3, 'Mehrangarh Homestay', 'HOMESTAY', 'Homestay in the old Blue City near the fort.', 'Jodhpur', 'Rajasthan', '9500001602', 'Rs. 1700-2600/night', 'APPROVED', 26.2980, 73.0180, NULL, NULL),
(3, 'Jodhpuri Sweets & Snacks', 'RESTAURANT', 'Classic Jodhpuri vegetarian snacks.', 'Jodhpur', 'Rajasthan', '9500001603', 'Rs. 150-300', 'APPROVED', 26.2900, 73.0280, 'VEG', 'Mirchi Bada & Makhaniya Lassi'),
(3, 'Marwar Kitchen', 'RESTAURANT', 'Traditional Marwari non-vegetarian specialties.', 'Jodhpur', 'Rajasthan', '9500001604', 'Rs. 300-600', 'APPROVED', 26.2400, 73.0300, 'BOTH', 'Laal Maas'),
(3, 'Jodhpur Fort Walks', 'GUIDE', 'Guided tours of Mehrangarh Fort and the old city.', 'Jodhpur', 'Rajasthan', '9500001605', 'Rs. 700-1300/person', 'APPROVED', 26.2389, 73.0243, NULL, NULL),
(3, 'Jodhpur Desert Safari', 'ACTIVITY', 'Jeep safaris into the Thar Desert near Jodhpur.', 'Jodhpur', 'Rajasthan', '9500001606', 'Rs. 1500-3000/person', 'APPROVED', 26.2500, 73.0000, NULL, NULL),

-- Hampi
(3, 'Riverside Heritage Hotel', 'HOTEL', 'Hotel near the Tungabhadra river and ruins.', 'Hampi', 'Karnataka', '9500001701', 'Rs. 2200-3800/night', 'APPROVED', 15.3350, 76.4600, NULL, NULL),
(3, 'Boulder View Homestay', 'HOMESTAY', 'Homestay amid Hampi granite boulders.', 'Hampi', 'Karnataka', '9500001702', 'Rs. 1200-2000/night', 'APPROVED', 15.3400, 76.4650, NULL, NULL),
(3, 'Mango Tree Restaurant', 'RESTAURANT', 'Popular vegetarian riverside cafe, banana pancakes to thali.', 'Hampi', 'Karnataka', '9500001703', 'Rs. 150-300', 'APPROVED', 15.3320, 76.4580, 'VEG', 'Banana Pancakes & Veg Thali'),
(3, 'Hampi Grill Kitchen', 'RESTAURANT', 'Multi-cuisine kitchen with vegetarian and non-vegetarian options.', 'Hampi', 'Karnataka', '9500001704', 'Rs. 250-500', 'APPROVED', 15.3370, 76.4620, 'BOTH', 'Grilled Chicken Platter'),
(3, 'Hampi Ruins Guides', 'GUIDE', 'Guided tours of the Vijayanagara ruins.', 'Hampi', 'Karnataka', '9500001705', 'Rs. 600-1200/person', 'APPROVED', 15.3350, 76.4600, NULL, NULL),
(3, 'Hampi Boulder Climbing', 'ACTIVITY', 'Guided bouldering and rock climbing sessions.', 'Hampi', 'Karnataka', '9500001706', 'Rs. 800-1500/person', 'APPROVED', 15.3450, 76.4700, NULL, NULL),

-- Port Blair (Andaman)
(3, 'Andaman Seaview Hotel', 'HOTEL', 'Hotel with sea views near Corbyns Cove.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001801', 'Rs. 3500-6000/night', 'APPROVED', 11.6234, 92.7265, NULL, NULL),
(3, 'Island Homestay', 'HOMESTAY', 'Local island family homestay.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001802', 'Rs. 2000-3200/night', 'APPROVED', 11.6300, 92.7300, NULL, NULL),
(3, 'South Indian Tiffin Andaman', 'RESTAURANT', 'South Indian vegetarian breakfast and meals.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001803', 'Rs. 150-300', 'APPROVED', 11.6250, 92.7250, 'VEG', 'South Indian Thali'),
(3, 'Island Seafood Grill', 'RESTAURANT', 'Fresh seafood platters and grilled fish.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001804', 'Rs. 400-800', 'APPROVED', 11.6220, 92.7280, 'BOTH', 'Fresh Seafood Platter'),
(3, 'Andaman Island Tours', 'GUIDE', 'Guided tours of Cellular Jail and nearby islands.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001805', 'Rs. 800-1500/person', 'APPROVED', 11.6234, 92.7265, NULL, NULL),
(3, 'Andaman Scuba Diving', 'ACTIVITY', 'Scuba diving and snorkeling trips near Havelock.', 'Port Blair', 'Andaman and Nicobar Islands', '9500001806', 'Rs. 3000-6000/person', 'APPROVED', 11.9700, 92.9800, NULL, NULL);

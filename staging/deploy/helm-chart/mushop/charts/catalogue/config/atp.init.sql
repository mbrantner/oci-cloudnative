-- Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
-- Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.

SET SERVEROUTPUT ON;
SET VERIFY OFF;
BEGIN
	-- Schema User Creation
	DECLARE
		schemaUserExists INTEGER;
	BEGIN
		SELECT COUNT(*) 
		INTO schemaUserExists 
		FROM ALL_USERS 
		WHERE username = '&1';
		DBMS_OUTPUT.PUT_LINE ('** Schema creationg steps - &_DATE');
		IF schemaUserExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating schema = &1 ...');
			EXECUTE IMMEDIATE 'CREATE USER &1 IDENTIFIED BY &2';
			EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO &1';
			EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO &1';
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Schema User = &1 exists, steps ignored');
		END IF;
	END;

	-- products Table Creation
	DECLARE
		tableExists INTEGER;
		tableName VARCHAR2 (20) := 'PRODUCTS';
	BEGIN
		SELECT COUNT(*) 
		INTO tableExists 
		FROM DBA_TABLES 
		WHERE owner = '&1'
		AND table_name = tableName;
		DBMS_OUTPUT.PUT_LINE ('** Table creationg steps - &_DATE');
		IF tableExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating Table ' || tableName || '...' );
			EXECUTE IMMEDIATE 'CREATE TABLE &1..' || tableName || ' (
				sku VARCHAR2(20) NOT NULL,
				brand VARCHAR2(20),
				title VARCHAR2(40),
				description VARCHAR2(500),
				weight VARCHAR2(10),
				product_size VARCHAR2(25),
				colors VARCHAR2(20),
				qty NUMBER(10, 0),
				price FLOAT, 
				image_url_1 VARCHAR2(50),
				image_url_2 VARCHAR2(50),
				PRIMARY KEY(sku)
			)';
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Table '|| tableName ||' exists, steps ignored');
		END IF;
	END;

	-- categories Table Creation
	DECLARE
		tableExists INTEGER;
		tableName VARCHAR2 (20) := 'CATEGORIES';
	BEGIN
		SELECT COUNT(*) 
		INTO tableExists 
		FROM DBA_TABLES 
		WHERE owner = '&1'
		AND table_name = tableName;
		DBMS_OUTPUT.PUT_LINE ('** Table creationg steps - &_DATE');
		IF tableExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating Table ' || tableName || '...' );
			EXECUTE IMMEDIATE 'CREATE TABLE &1..' || tableName || ' (
				category_id NUMBER(7,0) GENERATED BY DEFAULT ON NULL AS IDENTITY, 
				name VARCHAR2(30), 
				PRIMARY KEY(category_id)
			)';
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Table '|| tableName ||' exists, steps ignored');
		END IF;
	END;

	-- product_category Table Creation
	DECLARE
		tableExists INTEGER;
		tableName VARCHAR2 (20) := 'PRODUCT_CATEGORY';
	BEGIN
		SELECT COUNT(*) 
		INTO tableExists 
		FROM DBA_TABLES 
		WHERE owner = '&1'
		AND table_name = tableName;
		DBMS_OUTPUT.PUT_LINE ('** Table creationg steps - &_DATE');
		IF tableExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating Table ' || tableName || '...' );
			EXECUTE IMMEDIATE 'CREATE TABLE &1..' || tableName || ' (
				product_category_id NUMBER(7,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
				sku VARCHAR2(40), 
				category_id NUMBER(7,0) NOT NULL, 
				FOREIGN KEY (sku) 
					REFERENCES &1..PRODUCTS(sku), 
				FOREIGN KEY(category_id)
					REFERENCES &1..CATEGORIES(category_id),
				PRIMARY KEY(product_category_id)
			)';
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Table '|| tableName ||' exists, steps ignored');
		END IF;
	END;

	-- Role Creation
	DECLARE
		roleExists INTEGER;
		roleName VARCHAR2 (100);
	BEGIN
		roleName := '&1' || '_ROLE';
		SELECT COUNT(*) 
		INTO roleExists 
		FROM DBA_ROLES 
		WHERE role = roleName;
		DBMS_OUTPUT.PUT_LINE ('** Role creationg steps - &_DATE');
		IF roleExists = 0 THEN
			DBMS_OUTPUT.PUT_LINE ('Creating Role ' || roleName || '...' );
			EXECUTE IMMEDIATE 'CREATE ROLE ' || roleName;
			EXECUTE IMMEDIATE 'GRANT ' || roleName || ' TO &1';
			EXECUTE IMMEDIATE 'GRANT SELECT ON &1..PRODUCTS TO ' || roleName;
			EXECUTE IMMEDIATE 'GRANT SELECT ON &1..CATEGORIES TO ' || roleName;
			EXECUTE IMMEDIATE 'GRANT SELECT ON &1..PRODUCT_CATEGORY TO ' || roleName;
		ELSE
			DBMS_OUTPUT.PUT_LINE ('Role '|| roleName ||' exists, steps ignored');
		END IF;
	END;
END;
/

-- Populate Data
BEGIN
	DBMS_OUTPUT.PUT_LINE ('** Populating Data... - &_DATE');
	BEGIN
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-001', 'Original', 'Original Unscented Litter Trapper', 'Provide effective cat litter odor control in your cat''s litter box area with Original Texture cat litter. This formula absorbs three times the moisture by volume when compared to clay-based litter, keeping her litter box fresh and welcoming.','151lbs','0','0', 99, 18.50, 'MU-US-001.png', 'MU-US-001_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-002', 'Tidy Cats', 'Instant Action Mu BroomKit', 'Put an end to overpowering odors in your home with Purina Tidy Cats Instant Action clumping litter for multiple cats. We know you have no time to waste, and that is no problem with this unique formula. This clumping cat litter is designed to trap odors from the start.','20lbs','0','0', 99, 28.99 , 'MU-US-002.png', 'MU-US-002_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-003', 'Choco Spring', 'Mu DeoSpray Deodorizer', 'With Choco Spring scents lingering in the air, your cat''s time in the bathroom doesn''t have to be so smelly anymore! This deodorizer perfumes the air and helps make the litter last longer so you and your cat can enjoy a breath of sweetly-scented air.','26Oz','0','0', 99, 7.99, 'MU-US-003.png', 'MU-US-003_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-004', 'Arm ' || chr(38) || ' Hammer', 'Mu O-DeoSpray Deodorizer', 'Add an extra boost of freshness to your litter box. ARM ' || chr(38) || ' HAMMER' || chr(153) ||' baking soda destroys odors instantly in all types of litter - so your box stays first-day fresh longer. ','20Oz','0','0', 99, 4.99, 'MU-US-004.png', 'MU-US-004_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-005', 'Petmate', 'Cat Litter Mu LitterBox', 'Stay Fresh litter pans are created with Microban antimicrobial product, which inhibits the growth of stain- and odor-causing bacteria. Made in the USA.','0','18.7" x 15.5" x 10.6"','0', 99, 9.50, 'MU-US-005.png', 'MU-US-005_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-006', 'Tidy Cats', 'Mu X-DeoSpray Deodorizer', 'Change the way you think about cleaning your cat''s litter box with the Purina Tidy Cats BREEZE With Ammonia Blocker Litter System starter kit. This system features powerful odor control to keep your house smelling fresh and clean, and the specially designed, cat-friendly litter pellets minimize your pets from tracking litter throughout your home.','0','18.7" x 15.5" x 10.6"','0', 99, 39.25, 'MU-US-006.png', 'MU-US-006_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-007', 'Petsafe', 'Original MuMate Bowl', 'Original Pet Fountain with Bonus Reservoir provides 50 oz of fresh, filtered water to your pet, with an additional Bonus 50 Ounce Reservoir. A patented free-falling stream of water entices your pet to drink more and continually aerates the water with healthful oxygen.','0','0','0', 99, 43.95, 'MU-US-007.png', 'MU-US-007_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-008', 'Petsafe', 'Drinkwell BrandX Feeder', 'The Pagoda fountain continuously recirculates 70 ounces of fresh, filtered water. Best of all, the stylish ceramic design is easy to clean and looks great in your home. The upper and lower dishes provide two drinking areas for pets, and the patented dual free-falling streams aerate the water for freshness, which encourages your pet to drink more.','0','0','red, white', 99, 79.95, 'MU-US-008.png', 'MU-US-008_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-009', 'Petmate', 'Crock Small Coastal FishBowl', 'Standard crock small animal dish is uses a heavy weight design that eliminates movement and spillage.','0','3"','0', 99, 4.75, 'MU-US-009.png', 'MU-US-009_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-010', 'Loving Pet', 'Mu Fusion Bowl', 'Functional and beautiful, Bella Bowls are truly the perfect pet dish. Loving Pets brings new life to veterinarian-recommended stainless steel dog bowls and pet feeding dishes by combining a stainless interior with an attractive poly-resin exterior. A removable rubber base prevents spills, eliminates noise, and makes Bella Bowls fully dishwasher safe.','0','S,M,L,XL','0', 99, 5.99, 'MU-US-010.png', 'MU-US-010_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-011', 'Petsafe', 'Mu Mat Green Placemat', 'Petrageous Designs pet placemats are the perfect way to keep your pets'' feeding area clean and classy! This ultra-durable Food/Water Placemat keeps nasty spills and stray kibble off your clean floors, while adding playful character to your home''s decor. Easy to clean.','0','0','0', 99, 4.99, 'MU-US-011.png', 'MU-US-011_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-012', 'Loving Pet', 'Mu Mat Blue Placemat', 'Clean, clean, clean! Your little feline can be a messy eater too, and when they''re done you have to clean their dining area. Keep the feeding area around your pet mess free with the Meow Meow Bowl Mat. This fun mat with fish bones and cat sayings is a design you and your pet are sure to love.','0','0','0', 99, 11.95, 'MU-US-012.png', 'MU-US-012_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-013', 'Petsafe', 'Mu Storage Container', 'Pet Food Storage Container features a tight seal to ensure your pet''s food will stay fresh longer, reducing spoilage due to pests and moisture. Made from FDS food contact approved plastic.','15lbs','0','0', 99, 9.99, 'MU-US-013.png', 'MU-US-013_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-014', 'Pet Food', 'Chicken ' || chr(38) || ' Pomegranate Mu Cat Food', 'Your cats deserve the best scientifically proven food to maintain a healthy weight. Natural and Delicious Grain Free Chicken ' || chr(38) || ' Pomegranate Recipe Dry Cat Food does not contain any cereal or grains of any kind and is completely replaced with the highest quality protein. ','10lbs','0','0', 99, 38.95, 'MU-US-014.png', 'MU-US-014_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-015', 'Pet Food', 'Cat and Kitten BlueHill MagiK', 'Cat and Kitten recipe is a grain-free, region-inspired formula that your cat will thrive on. An excellent choice for cats of all breed and ages, this biologically appropriate recipe contains an unmatched variety of fresh regional ingredients delivered daily from local Kentucky farms. Packed with over 75% meat, the recipe features free-fun Cobb chicken, nest-laid eggs, Tom turkey, Blue catfish and Rainbow trout in wholeprey ratios in order to mimic the diet mother nature intended.','12lbs','0','0', 99, 49.95, 'MU-US-015.png', 'MU-US-015_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-016', 'Weruva', 'Go Cat Variety Pouches Pack', 'Let''s show our cats that they are truly our best friends, with the new Weruva Grain-Free BFF OMG Pouches Variety Pack. Made with white breast chicken, real, sustainably caught tuna, fresh wild caught salmon, and other real, deboned meats, Weruva has created the perfect meal for our furry, purring best friends. ','3Oz','0','0', 99, 12.99, 'MU-US-016.png', 'MU-US-016_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-017', 'Weruva', 'Love Me Variety Pack Green', 'Full of duck, tuna, and white breast, skinless, and boneless chicken, this wholesome food is full of protein and free of any grains, GMOs, MSG, and carrageenan for a balanced meal in each can. Weruva Cats In the Kitchen Love Me Tender Pouches Wet Cat Food will fill your cat with love, tenderly with every meal.','3Oz','0','0', 99, 15.99, 'MU-US-017.png', 'MU-US-017_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-018', 'Royal Canin', 'SO Dry Cat Food', 'Whether this is your cat’s first urinary issue or they need ongoing urinary care, your vet recommended Royal Canin Urinary SO for a reason. This veterinary-exclusive dry cat food was developed to nutritionally support your adult cat’s urinary tract and bladder health. It increases the amount of urine your cat produces to help dilute excess minerals that can cause crystals and stones.','15lbs','0','0', 99, 68.74, 'MU-US-018.png', 'MU-US-018_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-019', 'Royal Canin', 'Care with Chicken BlueHill MagiK', 'A healthy bladder starts with the right balance of vital nutrients. Excess minerals can encourage the formation of crystals in the urine, which may lead to the creation of bladder stones. They can cause discomfort and lead to more serious problems that require the care of a veterinarian. ','15lbs','0','0', 99, 72.75, 'MU-US-019.png', 'MU-US-019_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-020', 'Wellness', 'Wet Canned Mu Dry Food', 'Wellness Complete Health Natural Grain Free Chicken Recipe Canned Cat Food is made with 100% Human Grade Ingredients and uses delicious fruits and vegetables which contain vitamins and antioxidants to help maintain your cats healthy immune system. ','12Oz','0','0', 99, 49.75, 'MU-US-020.png', 'MU-US-020_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-021', 'Wellness', 'Green Pea Formula Mu Cat Food', 'Designed with a limited number of premium protein and carbohydrate sources, this Grain-free cat food is an excellent choice when seeking alternative ingredients for your cat. Natural Balance L.I.D. Limited Ingredient Diets Duck and Green Pea Formula Canned Cat Food is designed to support healthy digestion and to maintain skin and coat health—all while providing complete, balanced nutrition for all life stages!','12Oz','0','0', 99, 39.99, 'MU-US-021.png', 'MU-US-021_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-022', 'Amazing Paw', 'Wire Cat KittyBrush', 'For a well groomed appearance, cats and kittens need to be brushed regularly. The Magic Coat® Slicker Wire Brushes are designed to easily remove mats while pulling out dead hair. Brushing helps stimulate the skin to promote healthy circulation and increase shine.','0','0','0', 99, 6.99, 'MU-US-022.png', 'MU-US-022_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-023', 'Amazing Paw', 'Groom Genie KittyBrush', 'The Groom Genie evolved from a brush designed for humans - the Knot Genie. Rikki Mor, a mom of three, was frustrated with the huge cost and lack of effectiveness of other detangling brushes on the market. So she took matters into her own hands and invented what is now known as The World''s Best Detangling Brush.','0','0','0', 99, 4.75, 'MU-US-023.png', 'MU-US-023_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-024', 'Amazing Paw', 'Oatmeal and Aloe 2-in-1 Shampoo', 'Earthbath specially formulated this Oatmeal ' || chr(38) || ' Aloe itch relief shampoo to address the needs of beloved pets with dry, itchy skin. Oatmeal and aloe vera are recommended by veterinarians to effectively combat skin irritation, promote healing, and re-moisturize sensitive, dry skin.','15Oz','0','0', 99, 12.49, 'MU-US-024.png', 'MU-US-024_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-025', 'Amazing Paw', 'Oatmeal and Aloe Protein Shampoo', 'The addition of 3% colloidal oatmeal and aloe vera helps re-moisturize and soothe skin, too. Our sumptuous Shampoo will leave your best friend’s coat soft and plush while bringing out its natural luster and brilliance.','15Oz','0','0', 99, 13.49, 'MU-US-025.png', 'MU-US-025_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-026', 'Amazing Paw', 'Grooming Mitt for Cats', 'Cleans and softens cat’s coat, removes loose hair and gently massages. Made with lightweight neoprene material with adjustable closer and soft rubber nubs, the Love Glove® mitt is also great for removing loose cat hair from furniture and clothing.','0','0','0', 99, 6.99, 'MU-US-026.png', 'MU-US-026_1.png');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCTS(SKU)) */ INTO &1..PRODUCTS VALUES ('MU-US-027', 'Amazing Paw', 'Motion Lithium Ion Clipper', 'Powerful motor up to 5,500 SPM''s with integrated rapid power. The ''5 in 1'' Pro Blade for less breakage and optimal usage. Blade and clipper are ALWAYS cool running. Lithium Ion battery technology gives optimal performance. 90 minutes of cordless runtime with 45 minute quick full charge. Higher performance, longer usage times and consistent reliability. ','0','0','0', 99, 199.99, 'MU-US-027.png', 'MU-US-027_1.png');

		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('1','Cleaning Supplies');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('2','Deodorizers');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('3','Litter Accessories');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('4','Litter Boxes');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('5','Auto Feeders');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('6','Bowls');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('7','Placemats');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('8','Storage');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('9','Dry Food');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('10','Food Pouches');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('11','Limited Diet');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('12','Wet Food');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('13','Brushes');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('14','Grooming Tools');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(CATEGORIES(CATEGORY_ID)) */ INTO &1..CATEGORIES VALUES ('15','Shampoos and Conditioners');

		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('1','MU-US-001', '3');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('2','MU-US-002', '3');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('3','MU-US-003', '2');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('4','MU-US-004', '2');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('5','MU-US-005', '4');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('6','MU-US-006', '4');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('7','MU-US-007', '5');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('8','MU-US-008', '5');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('9','MU-US-009', '6');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('10','MU-US-010', '6');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('11','MU-US-011', '7');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('12','MU-US-012', '7');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('13','MU-US-013', '8');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('14','MU-US-014', '9');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('15','MU-US-015', '9');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('16','MU-US-016', '10');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('17','MU-US-017', '10');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('18','MU-US-018', '11');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('19','MU-US-019', '11');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('20','MU-US-020', '12');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('21','MU-US-021', '12');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('22','MU-US-022', '13');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('23','MU-US-023', '13');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('24','MU-US-024', '15');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('25','MU-US-025', '15');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('26','MU-US-026', '14');
		INSERT /*+ IGNORE_ROW_ON_DUPKEY_INDEX(PRODUCT_CATEGORY(PRODUCT_CATEGORY_ID)) */ INTO &1..PRODUCT_CATEGORY VALUES ('27','MU-US-027', '14');

		COMMIT;
	END;
END;
/

quit;
/


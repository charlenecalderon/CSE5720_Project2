-- CSE 5720 | Project 1 | Case 6: Local Food Rescue and Distribution Network
-- 04_verification.sql: constraint checks, client scenarios, expected results.
-- Run AFTER 01_schema.sql and 02_data.sql. Safe to rerun; no permanent changes.
-- This script uses PostgreSQL DO blocks to catch EXPECTED errors and continue.
-- Do not execute it inside an already-failed transaction.

-- =============================================================
-- PART A. Verify the seed data loaded (read-only)
-- Expected with the group's current 02_data.sql:
-- donor=5, food_category=6, partner_site=5, driver=5,
-- food_offer=15, allocation=23, pickup=10, delivery=20.
-- =============================================================
SELECT 'donor' AS table_name, COUNT(*) AS row_count FROM donor
UNION ALL SELECT 'food_category', COUNT(*) FROM food_category
UNION ALL SELECT 'partner_site', COUNT(*) FROM partner_site
UNION ALL SELECT 'driver', COUNT(*) FROM driver
UNION ALL SELECT 'food_offer', COUNT(*) FROM food_offer
UNION ALL SELECT 'allocation', COUNT(*) FROM allocation
UNION ALL SELECT 'pickup', COUNT(*) FROM pickup
UNION ALL SELECT 'delivery', COUNT(*) FROM delivery
ORDER BY table_name;

-- =============================================================
-- PART B. Integrity tests: each invalid INSERT MUST be rejected.
-- BEGIN/ROLLBACK ensures all verification changes are discarded.
-- The nested BEGIN...EXCEPTION blocks act like savepoints so one
-- expected error does not stop the remaining tests.
-- =============================================================
BEGIN;

DO $verify$
DECLARE
    v_offer_id integer;
    v_site_id integer;
    v_food_id integer;
    v_donor_id integer;
BEGIN
    SELECT food_id INTO STRICT v_food_id FROM food_category ORDER BY food_id LIMIT 1;
    SELECT donor_id INTO STRICT v_donor_id FROM donor ORDER BY donor_id LIMIT 1;
    SELECT site_id INTO STRICT v_site_id FROM partner_site ORDER BY site_id LIMIT 1;
    SELECT food_offer_id INTO STRICT v_offer_id FROM food_offer ORDER BY food_offer_id LIMIT 1;

    -- Test B1: CHECK offer_quantity > 0.
    -- Expected: REJECTED (check_violation, SQLSTATE 23514).
    BEGIN
        INSERT INTO food_offer (food_id, donor_id, donation_date, use_by_date, offer_quantity)
        VALUES (v_food_id, v_donor_id, CURRENT_DATE, CURRENT_DATE + 2, 0);
        RAISE EXCEPTION 'TEST B1 FAILED: zero offer quantity was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'TEST B1 PASSED: zero offer quantity rejected (CHECK)';
    END;

    -- Test B2: FOREIGN KEY allocation.food_offer_id.
    -- Expected: REJECTED (foreign_key_violation, SQLSTATE 23503).
    BEGIN
        INSERT INTO allocation (food_offer_id, site_id, allocate_quantity)
        VALUES (-999999, v_site_id, 1);
        RAISE EXCEPTION 'TEST B2 FAILED: nonexistent food offer was accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'TEST B2 PASSED: nonexistent food offer rejected (FK)';
    END;

    -- Test B3: UNIQUE(food_offer_id, site_id).
    -- Expected: REJECTED (unique_violation, SQLSTATE 23505).
    BEGIN
        INSERT INTO allocation (food_offer_id, site_id, allocate_quantity)
        SELECT food_offer_id, site_id, 1 FROM allocation ORDER BY allocation_id LIMIT 1;
        RAISE EXCEPTION 'TEST B3 FAILED: duplicate offer/site allocation was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'TEST B3 PASSED: duplicate offer/site allocation rejected (UNIQUE)';
    END;

    -- Test B4: pickup_status approved values only.
    -- Expected: REJECTED (check_violation).
    BEGIN
        INSERT INTO pickup (pickup_date, food_offer_id, driver_id, pickup_status)
        SELECT CURRENT_DATE, v_offer_id, driver_id, 'unknown'
        FROM driver ORDER BY driver_id LIMIT 1;
        RAISE EXCEPTION 'TEST B4 FAILED: invalid pickup status was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'TEST B4 PASSED: invalid pickup status rejected (CHECK)';
    END;

    -- Test B5: use_by_date cannot precede donation_date.
    -- Expected: REJECTED (check_violation).
    BEGIN
        INSERT INTO food_offer (food_id, donor_id, donation_date, use_by_date, offer_quantity)
        VALUES (v_food_id, v_donor_id, CURRENT_DATE, CURRENT_DATE - 1, 10);
        RAISE EXCEPTION 'TEST B5 FAILED: invalid date order was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'TEST B5 PASSED: use-by date before donation rejected (CHECK)';
    END;

    -- Test B6: delivered_quantity cannot be negative.
    -- Expected: REJECTED (check_violation).
    BEGIN
        INSERT INTO delivery (driver_id, allocation_id, delivered_quantity, delivery_status)
        SELECT d.driver_id, a.allocation_id, -1, 'delivered'
        FROM driver d CROSS JOIN allocation a
        ORDER BY d.driver_id, a.allocation_id LIMIT 1;
        RAISE EXCEPTION 'TEST B6 FAILED: negative delivered quantity was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'TEST B6 PASSED: negative delivery quantity rejected (CHECK)';
    END;
END;
$verify$;

ROLLBACK;
-- Expected: six PASSED notices and ROLLBACK; row counts remain unchanged.

-- =============================================================
-- PART C. Client scenario 1: Find food offers still available.
-- Actor: coordinator. Trigger: planning allocation of available food.
-- Tables: food_offer, donor, food_category, allocation.
-- Expected: remaining_quantity > 0 for each returned offer.
-- Decision: which food offers can be allocated to partner sites?
-- =============================================================
SELECT fo.food_offer_id, d.donor_name, fc.food_name,
       fo.offer_quantity,
       COALESCE(SUM(a.allocate_quantity), 0) AS allocated_quantity,
       fo.offer_quantity - COALESCE(SUM(a.allocate_quantity), 0) AS remaining_quantity,
       fo.use_by_date
FROM food_offer fo
JOIN donor d ON d.donor_id = fo.donor_id
JOIN food_category fc ON fc.food_id = fo.food_id
LEFT JOIN allocation a ON a.food_offer_id = fo.food_offer_id
WHERE fo.use_by_date >= CURRENT_DATE
GROUP BY fo.food_offer_id, d.donor_name, fc.food_name
HAVING fo.offer_quantity > COALESCE(SUM(a.allocate_quantity), 0)
ORDER BY fo.use_by_date, fo.food_offer_id;
-- Seed-data examples: offer 5 has 75 remaining (unclaimed); offer 8 has 25.
-- This is a scenario check, not a replacement for the team's Q1/Q5.

-- =============================================================
-- PART D. Client scenario 2: Distribution report for partner sites.
-- Actor: coordinator. Trigger: reporting completed deliveries.
-- Tables: partner_site, allocation, delivery.
-- Expected: one row per site, including sites with zero deliveries.
-- Decision: which sites received the most food?
-- =============================================================
SELECT ps.site_id, ps.site_name,
       COALESCE(SUM(de.delivered_quantity), 0) AS units_delivered
FROM partner_site ps
LEFT JOIN allocation a ON a.site_id = ps.site_id
LEFT JOIN delivery de ON de.allocation_id = a.allocation_id
                     AND de.delivery_status = 'delivered'
GROUP BY ps.site_id, ps.site_name
ORDER BY units_delivered DESC, ps.site_id;
-- Expected: 5 site rows with the current seed data.
-- Pending deliveries do not contribute to delivered totals.

-- =============================================================
-- PART E. Client scenario 3: Exception/edge-case checks.
-- Actor: coordinator. Trigger: audit for unclaimed/expired food.
-- Expected: offer 5 has no allocation; offer 3 and 10 are expired.
-- Decision: follow up on unclaimed offers and prevent late use.
-- =============================================================
SELECT fo.food_offer_id, fo.use_by_date,
       CASE WHEN fo.use_by_date < CURRENT_DATE THEN 'expired'
            ELSE 'not expired' END AS expiry_state,
       CASE WHEN EXISTS (SELECT 1 FROM allocation a
                        WHERE a.food_offer_id = fo.food_offer_id)
            THEN 'allocated' ELSE 'unclaimed' END AS allocation_state
FROM food_offer fo
WHERE fo.use_by_date < CURRENT_DATE
   OR NOT EXISTS (SELECT 1 FROM allocation a
                  WHERE a.food_offer_id = fo.food_offer_id)
ORDER BY fo.food_offer_id;

-- =============================================================
-- PART F. Additional allocation and delivery audits.
-- This read-only query confirms that the current seed data contains
-- no offer whose allocated total exceeds its offered quantity.
-- Expected with the provided seed data: no over-allocated offers.
-- =============================================================
SELECT fo.food_offer_id, fo.offer_quantity,
       COALESCE(SUM(a.allocate_quantity), 0) AS allocated_quantity
FROM food_offer fo
LEFT JOIN allocation a ON a.food_offer_id = fo.food_offer_id
GROUP BY fo.food_offer_id
HAVING COALESCE(SUM(a.allocate_quantity), 0) > fo.offer_quantity;


-- Detect delivered quantities larger than their allocation.
-- Expected with current data: 0 rows (per individual delivery row).
SELECT de.delivery_id, de.allocation_id, de.delivered_quantity,
       a.allocate_quantity
FROM delivery de
JOIN allocation a ON a.allocation_id = de.allocation_id
WHERE de.delivered_quantity > a.allocate_quantity;
-- Note: aggregate delivered totals per allocation are also not
-- constrained by the current schema; document as a limitation.

-- =============================================================
-- PART G. Confirm no permanent changes from tests.
-- Expected counts are identical to Part A.
-- =============================================================
SELECT 'food_offer' AS table_name, COUNT(*) AS row_count FROM food_offer
UNION ALL SELECT 'allocation', COUNT(*) FROM allocation
UNION ALL SELECT 'pickup', COUNT(*) FROM pickup
UNION ALL SELECT 'delivery', COUNT(*) FROM delivery
ORDER BY table_name;

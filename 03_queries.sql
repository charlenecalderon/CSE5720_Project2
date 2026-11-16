-- Q1. List unclaimed, unexpired offers with donor, category, quantity, and use-by date.
SELECT
    fo.food_offer_id,
    d.donor_name,
    fc.food_name,
    fo.offer_quantity,
    fo.use_by_date
FROM food_offer AS fo
JOIN donor AS d
    ON fo.donor_id = d.donor_id
JOIN food_category AS fc
    ON fo.food_id = fc.food_id
WHERE fo.use_by_date >= CURRENT_DATE
  AND NOT EXISTS (
      SELECT 1
       FROM allocation AS a
      WHERE a.food_offer_id = fo.food_offer_id
  )
ORDER BY fo.use_by_date;

-- Q2. Show deliveries with donor, food category, driver, partner site, and delivered quantity.
SELECT
    de.delivery_id,
    d.donor_name,
    fc.food_name,
    dr.driver_name,
    ps.site_name,
    de.delivered_quantity,
    de.delivery_status
FROM delivery AS de
JOIN allocation AS a
    ON de.allocation_id = a.allocation_id
JOIN food_offer AS fo
    ON a.food_offer_id = fo.food_offer_id
JOIN donor AS d
    ON fo.donor_id = d.donor_id
JOIN food_category AS fc
    ON fo.food_id = fc.food_id
JOIN driver AS dr
    ON de.driver_id = dr.driver_id
JOIN partner_site AS ps
    ON a.site_id = ps.site_id
ORDER BY de.delivery_id;

-- Q3. Calculate total delivered quantity for each partner site.
SELECT
    ps.site_id,
    ps.site_name,
    COALESCE(SUM(de.delivered_quantity), 0)
        AS total_delivered_quantity
FROM partner_site AS ps
LEFT JOIN allocation AS a
    ON ps.site_id = a.site_id
LEFT JOIN delivery AS de
    ON a.allocation_id = de.allocation_id
   AND de.delivery_status = 'delivered'
GROUP BY
    ps.site_id,
    ps.site_name
ORDER BY total_delivered_quantity DESC;


-- Q4. Show donors whose delivered quantity exceeds 100 units.
SELECT
    d.donor_id,
    d.donor_name,
    SUM(de.delivered_quantity)
        AS total_delivered_quantity
FROM donor AS d
JOIN food_offer AS fo
    ON d.donor_id = fo.donor_id
JOIN allocation AS a
    ON fo.food_offer_id = a.food_offer_id
JOIN delivery AS de
    ON a.allocation_id = de.allocation_id
WHERE de.delivery_status = 'delivered'
GROUP BY
    d.donor_id,
    d.donor_name
HAVING SUM(de.delivered_quantity) > 100
ORDER BY total_delivered_quantity DESC;


-- Q5. Find offers whose allocated quantity is less than the offered quantity. Use a correlated subquery or CTE.
WITH AllocationTotals AS (
    SELECT 
        food_offer_id, 
        SUM(allocate_quantity) AS total_allocated_quantity
    FROM allocation
    GROUP BY food_offer_id
)
SELECT 
    fo.food_offer_id,
    d.donor_name,
    fc.food_name,
    fo.offer_quantity,
    COALESCE(at.total_allocated_quantity, 0) AS total_allocated_quantity,
    fo.offer_quantity - COALESCE(at.total_allocated_quantity, 0) AS remaining_quantity
FROM food_offer AS fo
JOIN donor AS d 
    ON fo.donor_id = d.donor_id
JOIN food_category AS fc 
    ON fo.food_id = fc.food_id
LEFT JOIN AllocationTotals AS at 
    ON fo.food_offer_id = at.food_offer_id
WHERE COALESCE(at.total_allocated_quantity, 0) < fo.offer_quantity
ORDER BY remaining_quantity DESC;



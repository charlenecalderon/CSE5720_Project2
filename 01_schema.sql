-- Edit start -Alex
DROP VIEW IF EXISTS allocation_summary;
-- Edit end -Alex

-- drop any tbale that exists to create new
DROP TABLE IF EXISTS delivery, pickup, allocation, food_offer,
                     driver, partner_site, food_category, donor;

CREATE TABLE donor(
    donor_id    serial PRIMARY KEY,
    donor_name  VARCHAR(100) NOT NULL unique
    
    
);

CREATE TABLE food_category(
    food_id    serial PRIMARY KEY,
    food_name  VARCHAR(50) NOT NULL UNIQUE,
    food_type  VARCHAR(50) NOT NULL
);

CREATE TABLE partner_site(
    site_id  serial PRIMARY KEY,
    site_name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE driver(
    driver_id    serial PRIMARY KEY,
    driver_name  VARCHAR(100) NOT NULL
);

CREATE TABLE food_offer(
    food_offer_id   serial PRIMARY KEY,
    food_id         INT NOT NULL REFERENCES food_category(food_id),
    donor_id        INT NOT NULL REFERENCES donor(donor_id),
    use_by_date     DATE NOT NULL,
    donation_date  DATE NOT NULL,
    offer_quantity  INT NOT NULL CHECK (offer_quantity > 0),
    CHECK (use_by_date >= donation_date)
);




CREATE TABLE allocation(
    allocation_id	serial PRIMARY KEY,
    food_offer_id 	INT NOT NULL REFERENCES food_offer(food_offer_id),
    site_id			INT NOT NULL REFERENCES partner_site(site_id),
    allocate_quantity  INT NOT NULL CHECK (allocate_quantity > 0),
    UNIQUE (food_offer_id, site_id)
);

CREATE TABLE pickup(
    pickup_id    serial PRIMARY KEY,
    pickup_date  DATE NOT NULL,
    food_offer_id  INT NOT NULL REFERENCES food_offer(food_offer_id),
    driver_id      INT NOT NULL REFERENCES driver(driver_id),
    pickup_status  VARCHAR(20) NOT NULL
        CHECK (pickup_status IN ('scheduled', 'completed', 'cancelled'))
);

CREATE TABLE delivery(
    delivery_id		serial PRIMARY KEY,
    driver_id       INT NOT NULL REFERENCES driver(driver_id),
    allocation_id   INT NOT NULL REFERENCES allocation(allocation_id),
    delivered_quantity  INT NOT NULL CHECK (delivered_quantity >= 0),
    delivery_status     VARCHAR(20) NOT NULL
        CHECK (delivery_status IN ('pending', 'delivered', 'rejected'))
);
-- Edit Start -Alex
CREATE VIEW allocation_summary AS
    SELECT fo.food_offer_id,
    fo.offer_quantity,
    COALESCE(SUM(al.allocate_quantity), 0) AS total_allocated

    FROM food_offer AS fo
    LEFT JOIN allocation AS al
        ON fo.food_offer_id = al.food_offer_id
    GROUP BY fo.food_offer_id;
-- Edit end -Alex


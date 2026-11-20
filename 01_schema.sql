DROP VIEW IF EXISTS allocation_summary;

DROP TABLE IF EXISTS delivery, pickup, allocation, food_offer,
                     driver, partner_site, food_category, donor;

CREATE TABLE donor (
    donor_id    SERIAL PRIMARY KEY,
    donor_name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE food_category (
    food_id    SERIAL PRIMARY KEY,
    food_name  VARCHAR(50) NOT NULL UNIQUE,
    food_type  VARCHAR(50) NOT NULL
);

CREATE TABLE partner_site (
    site_id    SERIAL PRIMARY KEY,
    site_name  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE driver (
    driver_id    SERIAL PRIMARY KEY,
    driver_name  VARCHAR(100) NOT NULL
);

CREATE TABLE food_offer (
    food_offer_id  SERIAL PRIMARY KEY,
    food_id        INT NOT NULL
        REFERENCES food_category(food_id),
    donor_id       INT NOT NULL
        REFERENCES donor(donor_id),
    use_by_date   DATE NOT NULL,
    donation_date DATE NOT NULL,
    offer_quantity INT NOT NULL
        CHECK (offer_quantity > 0),

    CHECK (use_by_date >= donation_date)
);

CREATE TABLE allocation (
    allocation_id     SERIAL PRIMARY KEY,
    food_offer_id     INT NOT NULL
        REFERENCES food_offer(food_offer_id),
    site_id           INT NOT NULL
        REFERENCES partner_site(site_id),
    allocate_quantity INT NOT NULL
        CHECK (allocate_quantity > 0),

    UNIQUE (food_offer_id, site_id)
);

CREATE TABLE pickup (
    pickup_id      SERIAL PRIMARY KEY,
    pickup_date    DATE NOT NULL,
    food_offer_id  INT NOT NULL
        REFERENCES food_offer(food_offer_id),
    driver_id      INT NOT NULL
        REFERENCES driver(driver_id),
    pickup_status  VARCHAR(20) NOT NULL
        CHECK (
            pickup_status IN
            ('scheduled', 'completed', 'cancelled')
        )
);

CREATE TABLE delivery (
    delivery_id        SERIAL PRIMARY KEY,
    driver_id          INT NOT NULL
        REFERENCES driver(driver_id),
    allocation_id      INT NOT NULL
        REFERENCES allocation(allocation_id),
    delivered_quantity INT NOT NULL
        CHECK (delivered_quantity >= 0),
    delivery_status    VARCHAR(20) NOT NULL
        CHECK (
            delivery_status IN
            ('pending', 'delivered', 'rejected')
        )
);


CREATE VIEW allocation_summary AS
SELECT
    fo.food_offer_id,
    d.donor_name,
    fc.food_name,
    fo.offer_quantity,
    COALESCE(SUM(a.allocate_quantity), 0)
        AS total_allocated,
    fo.offer_quantity
        - COALESCE(SUM(a.allocate_quantity), 0)
        AS remaining_quantity
FROM food_offer AS fo
JOIN donor AS d
    ON fo.donor_id = d.donor_id
JOIN food_category AS fc
    ON fo.food_id = fc.food_id
LEFT JOIN allocation AS a
    ON fo.food_offer_id = a.food_offer_id
GROUP BY
    fo.food_offer_id,
    d.donor_name,
    fc.food_name,
    fo.offer_quantity;

CREATE INDEX idx_food_offer_donor
    ON food_offer(donor_id);

CREATE INDEX idx_food_offer_use_by_date
    ON food_offer(use_by_date);

CREATE INDEX idx_pickup_status
    ON pickup(pickup_status);

CREATE INDEX idx_delivery_status
    ON delivery(delivery_status);

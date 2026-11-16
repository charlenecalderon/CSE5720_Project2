INSERT INTO donor (donor_name) values 
('Fresh Market'),
('Green Valley Farms'),
('City Bakery'),
('Harvest Grocery'),
('Community Kitchen');

INSERT INTO food_category (food_name, food_type) VALUES
('Apples', 'Produce'),
('Bread', 'Bakery'),
('Canned Beans', 'Canned Goods'),
('Milk', 'Dairy'),
('Rice', 'Grains'),
('Chicken', 'Meat');

INSERT INTO partner_site (site_name) VALUES
('Hope Shelter'),
('Community Center'),
('Food Bank'),
('Senior Support Center'),
('Youth Outreach Center');

INSERT INTO driver (driver_name) VALUES
('David Brown'),
('Maria Garcia'),
('James Wilson'),
('Linda Davis'),
('Robert Miller');


INSERT INTO food_offer
(food_id, donor_id, use_by_date, donation_date, offer_quantity)
VALUES
(1, 1, CURRENT_DATE + 5,  CURRENT_DATE,     80),
(2, 1, CURRENT_DATE + 10, CURRENT_DATE,     50),
(3, 2, CURRENT_DATE - 3,  CURRENT_DATE - 8, 60),
(4, 2, CURRENT_DATE + 2,  CURRENT_DATE - 1, 200),
(5, 3, CURRENT_DATE + 20, CURRENT_DATE,     75),
(6, 3, CURRENT_DATE + 7,  CURRENT_DATE - 1, 120),
(1, 4, CURRENT_DATE + 14, CURRENT_DATE,     40),
(5, 4, CURRENT_DATE + 30, CURRENT_DATE,     150),
(6, 5, CURRENT_DATE + 1,  CURRENT_DATE - 1, 90),
(4, 5, CURRENT_DATE - 1, CURRENT_DATE - 5, 110),
(2, 1, CURRENT_DATE + 6,  CURRENT_DATE,     45),
(3, 2, CURRENT_DATE + 9,  CURRENT_DATE,     130),
(5, 3, CURRENT_DATE + 25, CURRENT_DATE,     70),
(6, 2, CURRENT_DATE + 3,  CURRENT_DATE,     300),
(4, 4, CURRENT_DATE + 12, CURRENT_DATE,     55);


INSERT INTO allocation
(food_offer_id, site_id, allocate_quantity)
VALUES
(1, 1, 50),
(1, 2, 20),
(2, 3, 50),
(3, 1, 30),
(3, 2, 20),
(4, 1, 100),
(4, 2, 50),
(4, 3, 50),
(6, 1, 60),
(6, 4, 40),
(7, 2, 40),
(8, 3, 75),
(8, 5, 50),
(9, 4, 90),
(10, 1, 60),
(10, 2, 30),
(11, 5, 20),
(12, 1, 70),
(12, 3, 60),
(13, 4, 40),
(14, 1, 150),
(14, 2, 100),
(15, 5, 55);

INSERT INTO pickup
(pickup_date, food_offer_id, driver_id, pickup_status)
VALUES
(CURRENT_DATE - 2,  1, 1, 'completed'),
(CURRENT_DATE - 1,  2, 2, 'completed'),
(CURRENT_DATE - 5,  3, 3, 'completed'),
(CURRENT_DATE - 1,  4, 1, 'completed'),
(CURRENT_DATE,      6, 4, 'completed'),
(CURRENT_DATE - 3,  7, 5, 'completed'),
(CURRENT_DATE - 1,  9, 2, 'completed'),
(CURRENT_DATE - 2, 10, 3, 'completed'),
(CURRENT_DATE,     12, 4, 'completed'),
(CURRENT_DATE,     14, 5, 'scheduled');

INSERT INTO delivery
(driver_id, allocation_id, delivered_quantity, delivery_status)
VALUES
(1,  1, 45, 'delivered'),
(2,  2, 15, 'delivered'),
(2,  3, 50, 'delivered'),
(3,  4, 30, 'delivered'),
(3,  5, 20, 'delivered'),
(1,  6, 90, 'delivered'),
(1,  7, 45, 'delivered'),
(1,  8, 45, 'delivered'),
(4,  9, 50, 'delivered'),
(4, 10, 30, 'delivered'),
(5, 11, 40, 'delivered'),
(2, 14, 80, 'delivered'),
(3, 15, 50, 'delivered'),
(3, 16, 25, 'delivered'),
(4, 17, 20, 'delivered'),
(3, 19, 60, 'delivered'),
(4, 20, 40, 'delivered'),
(5, 21, 120,'delivered'),
(5, 22, 80, 'delivered'),
(5, 23, 55, 'pending');


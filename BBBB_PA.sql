
-- 1. account 
CREATE TABLE `account` (
    `account_id` INT AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` ENUM('manager', 'staff', 'customer') NOT NULL,
    PRIMARY KEY (`account_id`)
)AUTO_INCREMENT=1;

-- 2. coustomer
CREATE TABLE `customer` (
    `customer_id` INT AUTO_INCREMENT,
    `account_id` INT,
    `first_name` VARCHAR(100),
    `last_name` VARCHAR(100),
    `phone_number` VARCHAR(20),
    `date_of_birth` DATE,
    `gender` ENUM('male', 'female', 'other'),
    `id_num` VARCHAR(20),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `profile_image` VARCHAR(500) DEFAULT '123.jpg',
    `status` ENUM ('active', 'inactive') NOT NULL DEFAULT 'active',
    PRIMARY KEY (`customer_id`),
    FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`)
)AUTO_INCREMENT=1000;

-- 3. staff
CREATE TABLE `staff` (
	`staff_id` INT AUTO_INCREMENT,
    `account_id` INT,
    `first_name` VARCHAR(100),
    `last_name` VARCHAR(100),
    `phone_number` VARCHAR(20),
    `date_of_birth` DATE,
    `gender` ENUM('male', 'female', 'other'),
    `position` VARCHAR(255),
    `profile_image` VARCHAR(500) DEFAULT '123.jpg',
    `status` ENUM ('active', 'inactive') NOT NULL DEFAULT 'active',
	PRIMARY KEY (`staff_id`),
    FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`)
)AUTO_INCREMENT=1;

-- 4. manager
CREATE TABLE `manager` (
	`manager_id` INT AUTO_INCREMENT,
    `account_id` INT,
    `first_name` VARCHAR(100),
    `last_name` VARCHAR(100),
    `phone_number` VARCHAR(20),
    `date_of_birth` DATE,
    `gender` ENUM('male', 'female', 'other'),
    `position` VARCHAR(255),
    `profile_image` VARCHAR(500) DEFAULT '123.jpg',
    `status` ENUM ('active', 'inactive') NOT NULL DEFAULT 'active',
	PRIMARY KEY (`manager_id`),
    FOREIGN KEY (`account_id`) REFERENCES `account` (`account_id`)
)AUTO_INCREMENT=1;

-- 5 . product_category
CREATE TABLE `product_category` (
    `category_id` INT AUTO_INCREMENT,
    `name` VARCHAR(225) NOT NULL,
    `description` VARCHAR(500),
    PRIMARY KEY (`category_id`)
)AUTO_INCREMENT=1;

-- 6. product
CREATE TABLE `product` (
    `product_id` INT AUTO_INCREMENT,
    `category_id` INT,
    `name` VARCHAR(255),
    `description` TEXT,
    `unit_price` DECIMAL(10,2),
    `is_available` BOOLEAN,
    `image` VARCHAR(500),
    PRIMARY KEY (`product_id`),
    FOREIGN KEY (`category_id`) REFERENCES `product_category` (`category_id`)
)AUTO_INCREMENT=1;

-- 7. product option type
CREATE TABLE `product_option` (
    `option_id` INT AUTO_INCREMENT,
    `product_id` INT,
    `option_type` VARCHAR(255),
    `option_name` VARCHAR(255),
    `additional_cost` DECIMAL(10,2),
    PRIMARY KEY (`option_id`),
    FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`)
) AUTO_INCREMENT=1;


CREATE TABLE `inventory` (
	`inventory_id` INT AUTO_INCREMENT,
    `staff_id` INT,
    `manager_id` INT,
    `product_id` INT,
    `option_id` INT DEFAULT NULL,
    `quantity` INT,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`inventory_id`),
    FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager` (`manager_id`)
)AUTO_INCREMENT=1;

-- 9. promotion
CREATE TABLE `promotion` (
    `promotion_id` INT AUTO_INCREMENT,
    `code` VARCHAR(255),
    `description` TEXT,
    `discount_value` DECIMAL(10,2),
    `valid_from` DATE,
    `valid_until` DATE,
    `usage_limit` INT,
    `minimum_amount` DECIMAL(10,2) NOT NULL,
    `is_active` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (`promotion_id`)
)AUTO_INCREMENT=1;

-- 10. orders
CREATE TABLE `orders` (
    `order_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `total_price` DECIMAL(10,2),
    `special_requests` TEXT,
    `scheduled_pickup_time` DATETIME,
    `status` ENUM('ordered', 'preparing', 'ready for collection', 'collected', 'cancelled') NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `promotion_id` INT DEFAULT NULL,
    PRIMARY KEY (`order_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`promotion_id`) REFERENCES `promotion` (`promotion_id`)
)AUTO_INCREMENT=1;

-- 11. order_item
CREATE TABLE `order_item` (
    `order_item_id` INT AUTO_INCREMENT,
    `order_id` INT,
    `product_id` INT,
    `quantity` INT,
    `options` VARCHAR(255),
    PRIMARY KEY (`order_item_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
    FOREIGN KEY (`product_id`) REFERENCES `product`(`product_id`)
)AUTO_INCREMENT=1;

-- 13. accommodation
CREATE TABLE `accommodation` (
    `accommodation_id` INT AUTO_INCREMENT,
    `type` ENUM('Dorm', 'Twin', 'Queen') NOT NULL,
    `description` TEXT,
    `capacity` INT,
    `space` INT,
    `price_per_night` DECIMAL(10,2),
    `is_available` BOOLEAN DEFAULT TRUE,
    `image` VARCHAR(500),
    `room_status` ENUM('Open', 'Closed') DEFAULT 'Open',	
    PRIMARY KEY (`accommodation_id`)
)AUTO_INCREMENT=1;

-- 14. blocked dates
CREATE TABLE `blocked_dates` (
    `block_id` INT AUTO_INCREMENT,
    `accommodation_id` INT,
    `start_date` DATE,
    `end_date` DATE,
    `is_active` BOOLEAN DEFAULT TRUE,
    `manager_id` INT,
    PRIMARY KEY (`block_id`),
    FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`accommodation_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager` (`manager_id`)
)AUTO_INCREMENT=1;

-- 15. booking
CREATE TABLE `booking` (
    `booking_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `payment_id` INT,
    `accommodation_id` INT,
    `start_date` DATE, 
    `end_date` DATE,
    `adults` INT,               
    `children` INT,              
    `rooms` INT DEFAULT 1,
    `is_paid` BOOLEAN,
    `status` ENUM('confirmed', 'cancelled', 'checked in', 'checked out') NOT NULL,
    `booking_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`booking_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`accommodation_id`) REFERENCES `accommodation` (`accommodation_id`)
)AUTO_INCREMENT=1;


-- 16. message
CREATE TABLE `message` (
    `message_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `manager_id` INT,
    `staff_id` INT,
    `sender_type` ENUM('customer', 'staff', 'manager') NOT NULL,
    `content` TEXT,
    `sent_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `time_responded` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `is_read` BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (`message_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager` (`manager_id`),
    FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`)
) AUTO_INCREMENT=1;

-- 17. loyalty_point
CREATE TABLE `loyalty_point` (
	`loyalty_point_id`INT AUTO_INCREMENT,
    `order_id` INT,
    `customer_id` INT,
    `points_earned` INT NOT NULL,
    `points_redeemed` INT NOT NULL,
    `points_balance` INT,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`loyalty_point_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`)
);

-- 18. payment_type
CREATE TABLE `payment_type` (
    `payment_type_id` INT AUTO_INCREMENT,
    `payment_type` VARCHAR(50),
    PRIMARY KEY (`payment_type_id`)
)AUTO_INCREMENT=1;

-- 19. bank_card
CREATE TABLE `bank_card` (
    `bank_card_id` INT AUTO_INCREMENT,
    `card_num` VARCHAR(20),
    `expire_Date` DATE,
	`payment_type_id` INT,
    PRIMARY KEY (`bank_card_id`),
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`payment_type_id`)
)AUTO_INCREMENT=1;

-- 20. gift_card
CREATE TABLE `gift_card` (
    `gift_card_id` INT AUTO_INCREMENT,
    `code` VARCHAR(255),
    `balance` DECIMAL(10,2),
    `expiration_date` DATE,
    `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
    `purchase_amount` DECIMAL(10,2) NOT NULL, 
    `payment_type_id` INT,
    PRIMARY KEY (`gift_card_id`),
	FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`payment_type_id`)
)AUTO_INCREMENT=1;

-- 22. payment
CREATE TABLE `payment` (
    `payment_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `payment_type_id` INT,
    `order_id` INT DEFAULT NULL,
    `booking_id` INT DEFAULT NULL,
    `paid_amount` DECIMAL(10,2),
    `promotion_id` INT DEFAULT NULL,
    PRIMARY KEY (`payment_id`),
    FOREIGN KEY (`payment_type_id`) REFERENCES `payment_type` (`payment_type_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
    FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`promotion_id`) REFERENCES `promotion` (`promotion_id`)
)AUTO_INCREMENT=1;

-- 23. news
CREATE TABLE `news` (
    `news_id` INT AUTO_INCREMENT,
    `manager_id` INT,
    `description` TEXT,
    `published_date` DATE,
    `image` VARCHAR(500),
    `is_active` BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (`news_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager` (`manager_id`)
)AUTO_INCREMENT=1;

-- 24. order_feedback
CREATE TABLE `order_feedback` (
    `order_item_id` INT,
    `customer_id` INT,
    `manager_id` INT,
    `rate` INT,
    `description` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` DATE DEFAULT (CURRENT_DATE), 
    PRIMARY KEY (`order_item_id`, `customer_id`),
    FOREIGN KEY (`order_item_id`) REFERENCES `order_item`(`order_item_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager`(`manager_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`)
);

-- 25. room_feedback
CREATE TABLE `room_feedback` (
    `booking_id` INT,
    `customer_id` INT,
    `manager_id` INT,
    `rate` INT,
    `description` TEXT,
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (`booking_id`, `customer_id`),
    FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`),
    FOREIGN KEY (`manager_id`) REFERENCES `manager`(`manager_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`)
);


-- 26. cart_item
CREATE TABLE `cart_item` (
    `cart_item_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `product_id` INT,
    `quantity` INT,
    PRIMARY KEY (`cart_item_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`)
) AUTO_INCREMENT=1;

-- 27. cart_item_option
CREATE TABLE `cart_item_option` (
    `cart_item_id` INT,
    `option_id` INT,
    PRIMARY KEY (`cart_item_id`, `option_id`),
    FOREIGN KEY (`cart_item_id`) REFERENCES `cart_item` (`cart_item_id`),
    FOREIGN KEY (`option_id`) REFERENCES `product_option` (`option_id`)
)AUTO_INCREMENT=1;

-- 28. paid_item
CREATE TABLE `paid_item` (
    `paid_item_id` INT AUTO_INCREMENT,
    `customer_id` INT,
    `product_id` INT,
    `quantity` INT,
    `price` DECIMAL(10,2),
    `order_id` INT,
    PRIMARY KEY (`paid_item_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`),
    FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`)
) AUTO_INCREMENT=1;


-- 1. Insert into account
INSERT INTO `account` (`account_id`, `email`, `password`, `role`) VALUES 
(1, 'aa@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'manager'),
(2, 'bb@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'staff'),

(3, 'cc@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(4, 'Emma@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(5, 'Dasiy@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(6, 'robin@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),

(7, 'bob@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'staff'),
(8, 'alice@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'staff'),
(9, 'bob1@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'staff'),

(10, 'Charlie9@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(11, 'David10@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(12, 'Emma11@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(13, 'Frank@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(14, 'Grace@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(15, 'Hannah@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(16, 'Ivan@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(17, 'Jack@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(18, 'Kelly@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(19, 'Liam@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(20, 'Mia@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(21, 'Noah@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(22, 'Olivia@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(23, 'Paul@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(24, 'Quincy@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(25, 'Rita@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(26, 'Sam@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer'),
(27, 'Tina@gmail.com', '031874e6cc56e1edd42eb19c75e62783b745b58811a4d247cc0c370b2f315fe6', 'customer');

-- 2. Insert into customer
INSERT INTO `customer` (`customer_id`, `account_id`, `first_name`, `last_name`, `phone_number`, `date_of_birth`, `gender`, `id_num`, `created_at`, `profile_image`, `status`) 
VALUES  
(1000, 3, 'Charlie', 'Collins', '1234567890', '1985-10-25', 'Male', 'AB1234567', CURRENT_TIMESTAMP, 'cc.jpg', 'active'),
(1001, 4, 'Emma', 'Anderson', '1234567891', '1991-02-14', 'Female', 'AB1234568', CURRENT_TIMESTAMP, 'cc.jpg', 'active'),
(1002, 5, 'Daisy', 'Adams', '1234567892', '1987-08-22', 'Male', 'AB1234569', CURRENT_TIMESTAMP, 'cc.jpg', 'active'),
(1003, 6, 'Robin', 'Smith', '1234567894', '1987-01-22', 'Male', 'AB1234561', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1004, 10, 'Charlie', 'Lee', '123456784', '1985-10-25', 'Male', 'AB1234567', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1005, 11, 'David', 'Anderson', '1234567855', '1990-02-02', 'Male', 'AB1234562', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1006, 12, 'Emma', 'Brown', '123456782', '1991-02-14', 'Female', 'AB1234563', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1007, 13, 'Frank', 'Collins', '123456722', '1992-01-01', 'Male', 'AB1234564', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1008, 14, 'Grace', 'Davis', '123456723', '1993-02-02', 'Female', 'AB1234565', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1009, 15, 'Hannah', 'Evans', '123456712', '1994-03-01', 'Female', 'AB1234566', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1010, 16, 'Ivan', 'Fisher', '123456713', '1995-04-02', 'Male', 'AB1234567', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1011, 17, 'Jack', 'Garcia', '123456714', '1990-01-01', 'Male', 'AB1234568', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1012, 18, 'Kelly', 'Harris', '123456715', '1998-03-02', 'Female', 'AB1234569', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1013, 19, 'Liam', 'Irwin', '123456716', '1994-09-07', 'Male', 'AB1234561', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1014, 20, 'Mia', 'Johnson', '123456717', '1997-01-02', 'Female', 'AB1234562', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1015, 21, 'Noah', 'Khan', '123456718', '1996-02-02', 'Male', 'AB1234563', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1016, 22, 'Olivia', 'Lee', '123456719', '1995-03-11', 'Female', 'AB1234564', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1017, 23, 'Paul', 'Morgan', '123456720', '1995-04-02', 'Male', 'AB1234565', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1018, 24, 'Quincy', 'Nelson', '123456721', '1994-05-02', 'Male', 'AB1234566', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1019, 25, 'Rita', 'Owen', '123456722', '2005-06-01', 'Female', 'AB1234567', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1020, 26, 'Sam', 'Parker', '123456723', '2001-07-02', 'Male', 'AB1234568', CURRENT_TIMESTAMP, '123.jpg', 'active'),
(1021, 27, 'Tina', 'Quinn', '123456724', '2005-08-02', 'Female', 'AB1234569', CURRENT_TIMESTAMP, '123.jpg', 'active');

-- 3. Insert into manager
INSERT INTO `manager` (`manager_id`, `account_id`, `first_name`, `last_name`, `phone_number`, `date_of_birth`, `gender`, `position`, `profile_image`, `status`) 
VALUES (1, 1, 'Ava', 'Anderson', '5551234567', '1975-08-30', 'Female', 'General Manager', 'default.jpg', 'active');

-- 4. Insert into staff
INSERT INTO `staff` (`staff_id`, `account_id`, `first_name`, `last_name`, `phone_number`, `date_of_birth`, `gender`, `position`, `profile_image`, `status`) 
VALUES
(1, 2, 'Bob', 'Brown', '9876543210', '1990-05-15', 'Male', 'Reception', 'bb.jpg', 'active'),
(2, 7, 'Bobbie', 'Kaye', '9876543210', '1990-05-15', 'Male', 'Staff', 'bb.jpg', 'inactive'),
(3, 8, 'Alice', 'Johnson', '9876543211', '1985-07-20', 'Female', 'Staff', 'alice.jpg', 'active'),
(4, 9, 'Bobo', 'Smith', '9876543212', '1982-12-05', 'Male', 'Staff', 'bob.jpg', 'inactive');

-- 5. Insert into product_category
INSERT INTO `product_category` (`name`, `description`)
VALUES
('Coffee', 'A variety of coffee drinks including espresso, latte, cappuccino, and more'),
('Hot Drinks', 'A variety of warm beverages including hot chocolate, tea, and more'),
('Soft Drinks', 'A variety of refreshing carbonated beverages.'),
('Milkshakes', 'Creamy and thick milkshakes with a variety of flavors.'),
('Iced Teas', 'Refreshing and chilled teas available in several flavors.'),
('Fast Food', 'A variety of quick and delicious meals including hotdogs, crepes, and more'),
('Frozen Treats', 'Delicious and refreshing frozen desserts, perfect for cooling down on a hot day'),
('Travel Essentials & Souvenirs', 'A curated collection of essential items and unique souvenirs, perfect for travelers seeking convenience and memorable keepsakes.');
-- 6. Insert into product
INSERT INTO `product` (`category_id`, `name`, `description`, `unit_price`, `is_available`, `image`)
VALUES 
-- Coffee
(1, 'Espresso', 'Strong black coffee made by forcing steam through ground coffee beans.', 4.50, TRUE, 'espresso.jpg'), -- 1
(1, 'Latte', 'Coffee drink made with espresso and steamed milk.', 6.00, TRUE, 'latte.jpg'), -- 2
(1, 'Cappuccino', 'Coffee-based drink made with equal parts of espresso, steamed milk, and frothed milk.', 6.00, TRUE, 'cappuccino.jpg'), -- 3
(1, 'Flat White', 'Smooth and velvety coffee made with espresso and steamed milk.', 6.00, TRUE, 'flatwhite.jpg'), -- 4
(1, 'Mocha', 'Espresso with steamed milk and chocolate syrup, topped with whipped cream.', 6.50, TRUE, 'mocha.jpg'), -- 5

-- Hot Drinks
(2, 'Hot Chocolate', 'Rich and creamy hot chocolate made with real cocoa.', 5.00, TRUE, 'hotchocolate.jpg'), -- 6
(2, 'Herbal Tea', 'A soothing blend of herbal ingredients steeped to perfection.', 6.50, TRUE, 'herbaltea.jpg'), -- 7
(2, 'Chai Latte', 'Spiced tea beverage made with aromatic spices and steamed milk.', 5.00, TRUE, 'chai.jpg'), -- 8

-- Soft Drinks
(3, 'Coca-Cola', 'Classic cola-flavored soft drink.', 3.00, TRUE, 'cola.jpg'), -- 9
(3, 'Sprite', 'Crisp, refreshing lemon-lime flavored soda.', 3.00, TRUE, 'sprite.jpg'), -- 10
(3, 'Fanta', 'Bright, bubbly and instantly refreshing orange soda.', 3.00, TRUE, 'fanta.jpg'), -- 11
(3, 'Pepsi', 'Bold, refreshing cola drink with a rich flavor.', 3.00, TRUE, 'pepsi.jpg'), -- 12
(3, 'Ginger Ale', 'Gently carbonated, soothing ginger-flavored soda.', 5.00, TRUE, 'ginger.jpg'), -- 13

-- Milkshakes
(4, 'Classic Vanilla', 'Smooth and creamy vanilla milkshake.', 7.00, TRUE, 'vanilla.jpg'), -- 14
(4, 'Rich Chocolate', 'Decadent chocolate milkshake made from real cocoa.', 7.00, TRUE, 'chocolate.jpg'), -- 15
(4, 'Strawberry Delight', 'Fresh and fruity strawberry milkshake.', 7.00, TRUE, 'strawberry.jpg'), -- 16
(4, 'Caramel Swirl', 'Creamy milkshake with rich caramel swirls.', 7.00, TRUE, 'caramel.jpg'), -- 17
(4, 'Banana Bliss', 'Creamy milkshake blended with ripe bananas.', 7.00, TRUE, 'banana.jpg'), -- 18
(4, 'Cookies and Cream', 'Crushed cookies mixed into a creamy milkshake.', 7.00, TRUE, 'cookie.jpg'), -- 19
(4, 'Seasonal Berry', 'Blend of seasonal berries in a refreshing milkshake.', 7.00, TRUE, 'berry.jpg'), -- 20

-- Iced Teas
(5, 'Classic Lemon Iced Tea', 'Iced tea flavored with a twist of lemon.', 4.50, TRUE, 'lemontea.jpg'), -- 21
(5, 'Peach Iced Tea', 'Refreshing iced tea infused with peach flavors.', 4.50, TRUE, 'peachtea.jpg'), -- 22
(5, 'Raspberry Iced Tea', 'Iced tea infused with the essence of raspberries.', 4.50, TRUE, 'rasberrytea.jpg'), -- 23
(5, 'Green Iced Tea', 'Smooth and mellow green tea served chilled.', 4.50, TRUE, 'greentea.jpg'), -- 24
(5, 'Hibiscus Iced Tea', 'Tangy and refreshing hibiscus-flavored iced tea.', 4.50, TRUE, 'hibiscuctea.jpg'), -- 25
(5, 'Mint Iced Tea', 'Cooling mint-flavored iced tea.', 4.50, TRUE, 'minttea.jpg'), -- 26

-- Fast Food
(6, 'American Hotdogs', 'Classic grilled hotdogs with a selection of toppings.', 8.00, TRUE, 'hotdog.jpg'), -- 27
(6, 'Sweetcorn & Kumara Patties', 'Delicious patties made from sweetcorn and kumara.', 8.50, TRUE, 'pattie.jpg'), -- 28
(6, 'Crepes', 'Thin pancakes served with various toppings.', 8.00, TRUE, 'crepes.jpg'), -- 29
(6, 'Smokey BBQ Pulled Pork in a Bun', 'Slow-cooked pulled pork smothered in Smokey BBQ sauce, served in a soft bun.', 10.00, TRUE, 'bun.jpg'), -- 30
(6, 'Muffins', 'Freshly baked muffins available in several flavors.', 4.50, TRUE, 'muffins.jpg'), -- 31
(6, 'Slices', 'Assorted homemade slices.', 3.00, TRUE, 'slice.jpg'), -- 32
(6, 'Chicken Tenders', 'Crispy on the outside, juicy on the inside, our chicken tenders are served with your choice of dipping sauces.', 7.50, TRUE, 'chicken_tenders.jpg'), -- 33
(6, 'Veggie Burger', 'A hearty, meat-free patty served on a toasted bun with lettuce, tomato, and your choice of sauce.', 9.00, TRUE, 'veggie_burger.jpg'), -- 34
(6, 'Fish Tacos', 'Soft tacos filled with lightly seasoned grilled fish, fresh slaw, and a creamy cilantro sauce.', 9.50, TRUE, 'fish_tacos.jpg'), -- 35
(6, 'Loaded Fries', 'Crispy fries topped with melted cheese, bacon bits, and green onions, served with a side of sour cream.', 4.50, TRUE, 'loaded_fries.jpg'), -- 36
(6, 'Falafel Wrap', 'Crunchy falafel balls wrapped in a soft tortilla with lettuce, tomato, and a drizzle of tahini.', 9.00, TRUE, 'falafel_wrap.jpg'), -- 37
(6, 'Cheese Nachos', 'Corn tortilla chips covered with a generous layer of melted cheese, jalapeños, and a side of salsa.', 7.00, TRUE, 'nachos.jpg'), -- 38
(6, 'Spicy Ramen', 'Authentic Spicy Ramen noodles served in a rich, fiery broth, topped with sliced pork, boiled eggs, and fresh green onions.', 8.50, TRUE, 'spicy_ramen.jpg'), -- 39
(6, 'Stinky Tofu', 'Deep-fried Stinky Tofu, renowned for its pungent aroma and crisp exterior, served with pickled cabbage and chili sauce.', 6.50, TRUE, 'stinky_tofu.jpg'), -- 40
(6, 'Grilled Cold Noodles', 'Chilled noodles with a sesame and soy sauce dressing, grilled to perfection and topped with cucumber, peanuts, and coriander.', 7.00, TRUE, 'grilled_cold_noodles.jpg'), -- 41

-- Frozen Treats
(7, 'Strawberry Ice Blocks', 'Refreshing flavored ice blocks with strawberry flavor.', 3.50, TRUE, 'iceblock.jpg'),
(7, 'Banana Ice Blocks', 'Refreshing flavored ice blocks with banana flavor.', 3.50, TRUE, 'iceblock.jpg'),
(7, 'Mixed Berry Ice Blocks', 'Refreshing flavored ice blocks with mixed berry flavor.', 3.50, TRUE, 'iceblock.jpg'),
(7, 'Mango Ice Blocks', 'Refreshing flavored ice blocks with mango flavor.', 3.50, TRUE, 'iceblock.jpg'),
(7, 'Peach Ice Blocks', 'Refreshing flavored ice blocks with peach flavor.', 3.50, TRUE, 'iceblock.jpg'),
(7, 'Blackberry Ice Blocks', 'Refreshing flavored ice blocks with blackberry flavor.', 3.50, TRUE, 'iceblock.jpg'),

(7, 'Strawberry Real Fruit Ice Creams', 'Ice cream made with real strawberries blended on the spot.', 7.50, TRUE, 'icecream.jpg'),
(7, 'Banana Real Fruit Ice Creams', 'Ice cream made with real bananas blended on the spot.', 7.50, TRUE, 'icecream.jpg'),
(7, 'Mixed Berry Real Fruit Ice Creams', 'Ice cream made with mixed berries blended on the spot.', 7.50, TRUE, 'icecream.jpg'),
(7, 'Mango Real Fruit Ice Creams', 'Ice cream made with real mangoes blended on the spot.', 7.50, TRUE, 'icecream.jpg'),
(7, 'Peach Real Fruit Ice Creams', 'Ice cream made with real peaches blended on the spot.', 7.50, TRUE, 'icecream.jpg'),
(7, 'Blackberry Real Fruit Ice Creams', 'Ice cream made with real blackberries blended on the spot.', 7.50, TRUE, 'icecream.jpg'),

-- Travel Essentials & Souvenirs
(8, 'Sandfly Spray', 'Effective protection against sandflies and other biting insects, essential for enjoying the outdoors in comfort.', 12.00, TRUE, 'sandflyspray.jpg'),
(8, 'Sunscreen', 'The UV levels can be quite high, so sunscreen is a must to protect your skin.', 15.00, TRUE, 'sunscreen.jpg'),
(8, 'Rain Gear', 'The region is known for its rainfall, so a waterproof jacket or umbrella is advisable.', 50.00, TRUE, 'raingear.jpg'),
(8, 'Greenstone Jewelry', 'A significant cultural icon in New Zealand, sourced mainly from the West Coast.', 120.00, TRUE, 'greenstone.jpg');



INSERT INTO `product_option` (`product_id`, `option_type`, `option_name`, `additional_cost`)
VALUES
-- Coffee Options (Milk Type, Size, Syrup Type)
(1, 'Milk Type', 'Standard Milk', 0.00), (1, 'Milk Type', 'Light Milk', 0.00), (1, 'Milk Type', 'Soy Milk', 0.50), (1, 'Milk Type', 'Almond Milk', 0.50), (1, 'Milk Type', 'Oat Milk', 0.50), 
(1, 'Size', 'Small', 0.00), (1, 'Size', 'Medium', 0.50), (1, 'Size', 'Large', 0.80), (1, 'Size', 'Extra Large', 1.00),
(1, 'Syrup Type', 'Vanilla Syrup', 0.50), (1, 'Syrup Type', 'Caramel Syrup', 0.50), (1, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(2, 'Milk Type', 'Standard Milk', 0.00), (2, 'Milk Type', 'Light Milk', 0.00), (2, 'Milk Type', 'Soy Milk', 0.50), (2, 'Milk Type', 'Almond Milk', 0.50), (2, 'Milk Type', 'Oat Milk', 0.50), 
(2, 'Size', 'Small', 0.00), (2, 'Size', 'Medium', 0.50), (2, 'Size', 'Large', 0.80), (2, 'Size', 'Extra Large', 1.00),
(2, 'Syrup Type', 'Vanilla Syrup', 0.50), (2, 'Syrup Type', 'Caramel Syrup', 0.50), (2, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(3, 'Milk Type', 'Standard Milk', 0.00), (3, 'Milk Type', 'Light Milk', 0.00), (3, 'Milk Type', 'Soy Milk', 0.50), (3, 'Milk Type', 'Almond Milk', 0.50), (3, 'Milk Type', 'Oat Milk', 0.50), 
(3, 'Size', 'Small', 0.00), (3, 'Size', 'Medium', 0.50), (3, 'Size', 'Large', 0.80), (3, 'Size', 'Extra Large', 1.00),
(3, 'Syrup Type', 'Vanilla Syrup', 0.50), (3, 'Syrup Type', 'Caramel Syrup', 0.50), (3, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(4, 'Milk Type', 'Standard Milk', 0.00), (4, 'Milk Type', 'Light Milk', 0.00), (4, 'Milk Type', 'Soy Milk', 0.50), (4, 'Milk Type', 'Almond Milk', 0.50), (4, 'Milk Type', 'Oat Milk', 0.50), 
(4, 'Size', 'Small', 0.00), (4, 'Size', 'Medium', 0.50), (4, 'Size', 'Large', 0.80), (4, 'Size', 'Extra Large', 1.00),
(4, 'Syrup Type', 'Vanilla Syrup', 0.50), (4, 'Syrup Type', 'Caramel Syrup', 0.50), (4, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(5, 'Milk Type', 'Standard Milk', 0.00), (5, 'Milk Type', 'Light Milk', 0.00), (5, 'Milk Type', 'Soy Milk', 0.50), (5, 'Milk Type', 'Almond Milk', 0.50), (5, 'Milk Type', 'Oat Milk', 0.50), 
(5, 'Size', 'Small', 0.00), (5, 'Size', 'Medium', 0.50), (5, 'Size', 'Large', 0.80), (5, 'Size', 'Extra Large', 1.00),
(5, 'Syrup Type', 'Vanilla Syrup', 0.50), (5, 'Syrup Type', 'Caramel Syrup', 0.50), (5, 'Syrup Type', 'Hazelnut Syrup', 0.50),


-- Hot Drinks Options (Syrup Type)
(6, 'Syrup Type', 'Vanilla Syrup', 0.50), (6, 'Syrup Type', 'Caramel Syrup', 0.50), (6, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(7, 'Syrup Type', 'Vanilla Syrup', 0.50), (7, 'Syrup Type', 'Caramel Syrup', 0.50), (7, 'Syrup Type', 'Hazelnut Syrup', 0.50),
(8, 'Syrup Type', 'Vanilla Syrup', 0.50), (8, 'Syrup Type', 'Caramel Syrup', 0.50), (8, 'Syrup Type', 'Hazelnut Syrup', 0.50),

-- Milkshakes Options (Ice Level)
(9, 'Ice Level', 'Light Ice', 0.00), 
(9, 'Ice Level', 'No Ice', 0.00),
(10, 'Ice Level', 'Light Ice', 0.00), 
(10, 'Ice Level', 'No Ice', 0.00),
(11, 'Ice Level', 'Light Ice', 0.00), 
(11, 'Ice Level', 'No Ice', 0.00),
(12, 'Ice Level', 'Light Ice', 0.00), 
(12, 'Ice Level', 'No Ice', 0.00),
(13, 'Ice Level', 'Light Ice', 0.00), 
(13, 'Ice Level', 'No Ice', 0.00),
(14, 'Ice Level', 'Light Ice', 0.00), 
(14, 'Ice Level', 'No Ice', 0.00),
(15, 'Ice Level', 'Light Ice', 0.00), 
(15, 'Ice Level', 'No Ice', 0.00),

-- Iced Teas Options (Ice Level)
(16, 'Ice Level', 'Light Ice', 0.00), 
(16, 'Ice Level', 'No Ice', 0.00),
(17, 'Ice Level', 'Light Ice', 0.00), 
(17, 'Ice Level', 'No Ice', 0.00),
(18, 'Ice Level', 'Light Ice', 0.00), 
(18, 'Ice Level', 'No Ice', 0.00),
(19, 'Ice Level', 'Light Ice', 0.00), 
(19, 'Ice Level', 'No Ice', 0.00),
(20, 'Ice Level', 'Light Ice', 0.00), 
(20, 'Ice Level', 'No Ice', 0.00),
(21, 'Ice Level', 'Light Ice', 0.00), 
(21, 'Ice Level', 'No Ice', 0.00),

-- Fast Food Options (Bun Type, Toppings, Sauce Type)
-- American Hotdogs (22)
(22, 'Add on', 'Gluten-Free Bun', 0.50),
(22, 'Add on', 'Sesame Bun', 0.20),
(22, 'Add on', 'Extra Cheese', 0.50),
(22, 'Add on', 'Bacon', 0.75),
(22, 'Add on', 'Grilled Onions', 0.25),
(22, 'Add on', 'BBQ Sauce', 0.00),
(22, 'Add on', 'Mustard', 0.00),
(22, 'Add on', 'Mayo', 0.00),

-- Sweetcorn & Kumara Patties (23)
(23, 'Add on', 'Gluten-Free Bun', 0.50),
(23, 'Add on', 'Sesame Bun', 0.20),
(23, 'Add on', 'Extra Cheese', 0.50),
(23, 'Add on', 'Bacon', 0.75),
(23, 'Add on', 'Grilled Onions', 0.25),
(23, 'Add on', 'BBQ Sauce', 0.00),
(23, 'Add on', 'Mustard', 0.00),
(23, 'Add on', 'Mayo', 0.00),

-- Crepes (24)
(24, 'Add on', 'Gluten-Free Bun', 0.50),
(24, 'Add on', 'Sesame Bun', 0.20),
(24, 'Add on', 'Extra Cheese', 0.50),
(24, 'Add on', 'Bacon', 0.75),
(24, 'Add on', 'Grilled Onions', 0.25),
(24, 'Add on', 'BBQ Sauce', 0.00),
(24, 'Add on', 'Mustard', 0.00),
(24, 'Add on', 'Mayo', 0.00),

-- Smokey BBQ Pulled Pork in a Bun (25)
(25, 'Add on', 'Gluten-Free Bun', 0.50),
(25, 'Add on', 'Sesame Bun', 0.20),
(25, 'Add on', 'Extra Cheese', 0.50),
(25, 'Add on', 'Bacon', 0.75),
(25, 'Add on', 'Grilled Onions', 0.25),
(25, 'Add on', 'BBQ Sauce', 0.00),
(25, 'Add on', 'Mustard', 0.00),
(25, 'Add on', 'Mayo', 0.00),

-- Muffins (26)
(26, 'Add on', 'Gluten-Free Bun', 0.50),
(26, 'Add on', 'Sesame Bun', 0.20),
(26, 'Add on', 'Extra Cheese', 0.50),
(26, 'Add on', 'Bacon', 0.75),
(26, 'Add on', 'Grilled Onions', 0.25),
(26, 'Add on', 'BBQ Sauce', 0.00),
(26, 'Add on', 'Mustard', 0.00),
(26, 'Add on', 'Mayo', 0.00),

-- Slices (27)
(27, 'Add on', 'Gluten-Free Bun', 0.50),
(27, 'Add on', 'Sesame Bun', 0.20),
(27, 'Add on', 'Extra Cheese', 0.50),
(27, 'Add on', 'Bacon', 0.75),
(27, 'Add on', 'Grilled Onions', 0.25),
(27, 'Add on', 'BBQ Sauce', 0.00),
(27, 'Add on', 'Mustard', 0.00),
(27, 'Add on', 'Mayo', 0.00),

-- Chicken Tenders (28)
(28, 'Add on', 'Gluten-Free Bun', 0.50),
(28, 'Add on', 'Sesame Bun', 0.20),
(28, 'Add on', 'Extra Cheese', 0.50),
(28, 'Add on', 'Bacon', 0.75),
(28, 'Add on', 'Grilled Onions', 0.25),
(28, 'Add on', 'BBQ Sauce', 0.00),
(28, 'Add on', 'Mustard', 0.00),
(28, 'Add on', 'Mayo', 0.00),

-- Veggie Burger (29)
(29, 'Add on', 'Gluten-Free Bun', 0.50),
(29, 'Add on', 'Sesame Bun', 0.20),
(29, 'Add on', 'Extra Cheese', 0.50),
(29, 'Add on', 'Bacon', 0.75),
(29, 'Add on', 'Grilled Onions', 0.25),
(29, 'Add on', 'BBQ Sauce', 0.00),
(29, 'Add on', 'Mustard', 0.00),
(29, 'Add on', 'Mayo', 0.00),

-- Fish Tacos (30)
(30, 'Add on', 'Gluten-Free Bun', 0.50),
(30, 'Add on', 'Sesame Bun', 0.20),
(30, 'Add on', 'Extra Cheese', 0.50),
(30, 'Add on', 'Bacon', 0.75),
(30, 'Add on', 'Grilled Onions', 0.25),
(30, 'Add on', 'BBQ Sauce', 0.00),
(30, 'Add on', 'Mustard', 0.00),
(30, 'Add on', 'Mayo', 0.00),

-- Loaded Fries (31)
(31, 'Add on', 'Gluten-Free Bun', 0.50),
(31, 'Add on', 'Sesame Bun', 0.20),
(31, 'Add on', 'Extra Cheese', 0.50),
(31, 'Add on', 'Bacon', 0.75),
(31, 'Add on', 'Grilled Onions', 0.25),
(31, 'Add on', 'BBQ Sauce', 0.00),
(31, 'Add on', 'Mustard', 0.00),
(31, 'Add on', 'Mayo', 0.00),

-- Falafel Wrap (32)
(32, 'Add on', 'Gluten-Free Bun', 0.50),
(32, 'Add on', 'Sesame Bun', 0.20),
(32, 'Add on', 'Extra Cheese', 0.50),
(32, 'Add on', 'Bacon', 0.75),
(32, 'Add on', 'Grilled Onions', 0.25),
(32, 'Add on', 'BBQ Sauce', 0.00),
(32, 'Add on', 'Mustard', 0.00),
(32, 'Add on', 'Mayo', 0.00),

-- Cheese Nachos (33)
(33, 'Add on', 'Gluten-Free Bun', 0.50),
(33, 'Add on', 'Sesame Bun', 0.20),
(33, 'Add on', 'Extra Cheese', 0.50),
(33, 'Add on', 'Bacon', 0.75),
(33, 'Add on', 'Grilled Onions', 0.25),
(33, 'Add on', 'BBQ Sauce', 0.00),
(33, 'Add on', 'Mustard', 0.00),
(33, 'Add on', 'Mayo', 0.00),

-- Spicy Ramen (34)
(34, 'Add on', 'Gluten-Free Bun', 0.50),
(34, 'Add on', 'Sesame Bun', 0.20),
(34, 'Add on', 'Extra Cheese', 0.50),
(34, 'Add on', 'Bacon', 0.75),
(34, 'Add on', 'Grilled Onions', 0.25),
(34, 'Add on', 'BBQ Sauce', 0.00),
(34, 'Add on', 'Mustard', 0.00),
(34, 'Add on', 'Mayo', 0.00),

-- Stinky Tofu (35)
(35, 'Add on', 'Gluten-Free Bun', 0.50),
(35, 'Add on', 'Sesame Bun', 0.20),
(35, 'Add on', 'Extra Cheese', 0.50),
(35, 'Add on', 'Bacon', 0.75),
(35, 'Add on', 'Grilled Onions', 0.25),
(35, 'Add on', 'BBQ Sauce', 0.00),
(35, 'Add on', 'Mustard', 0.00),
(35, 'Add on', 'Mayo', 0.00),

-- Grilled Cold Noodles (36)
(36, 'Add on', 'Gluten-Free Bun', 0.50),
(36, 'Add on', 'Sesame Bun', 0.20),
(36, 'Add on', 'Extra Cheese', 0.50),
(36, 'Add on', 'Bacon', 0.75),
(36, 'Add on', 'Grilled Onions', 0.25),
(36, 'Add on', 'BBQ Sauce', 0.00),
(36, 'Add on', 'Mustard', 0.00),
(36, 'Add on', 'Mayo', 0.00);




INSERT INTO `inventory` (`staff_id`, `manager_id`, `product_id`, `quantity`)
VALUES
-- Ice Blocks (new products)
(1, 1, 42, 50), -- Strawberry Ice Blocks
(1, 1, 43, 50), -- Banana Ice Blocks
(1, 1, 44, 50), -- Mixed Berry Ice Blocks
(1, 1, 45, 50), -- Mango Ice Blocks
(1, 1, 46, 50), -- Peach Ice Blocks
(1, 1, 47, 50), -- Blackberry Ice Blocks

-- Real Fruit Ice Creams (new products)
(1, 1, 48, 50), -- Strawberry Real Fruit Ice Creams
(1, 1, 49, 50), -- Banana Real Fruit Ice Creams
(1, 1, 50, 50), -- Mixed Berry Real Fruit Ice Creams
(1, 1, 51, 50), -- Mango Real Fruit Ice Creams
(1, 1, 52, 50), -- Peach Real Fruit Ice Creams
(1, 1, 53, 50), -- Blackberry Real Fruit Ice Creams

-- Soft Drinks (only product inventory)
(1, 1, 9, 50), -- Coca-Cola
(1, 1, 10, 50), -- Sprite
(1, 1, 11, 50), -- Fanta
(1, 1, 12, 50), -- Pepsi
(1, 1, 13, 50), -- Ginger Ale

-- Milkshakes (only product inventory)
(1, 1, 14, 50), -- Classic Vanilla
(1, 1, 15, 50), -- Rich Chocolate
(1, 1, 16, 50), -- Strawberry Delight
(1, 1, 17, 50), -- Caramel Swirl
(1, 1, 18, 50), -- Banana Bliss
(1, 1, 19, 50), -- Cookies and Cream
(1, 1, 20, 50), -- Seasonal Berry

-- Iced Teas (only product inventory)
(1, 1, 21, 50), -- Classic Lemon Iced Tea
(1, 1, 22, 50), -- Peach Iced Tea
(1, 1, 23, 50), -- Raspberry Iced Tea
(1, 1, 24, 50), -- Green Iced Tea
(1, 1, 25, 50), -- Hibiscus Iced Tea
(1, 1, 26, 50), -- Mint Iced Tea

-- Fast Food (only product inventory)
(1, 1, 27, 50), -- American Hotdogs
(1, 1, 28, 50), -- Sweetcorn & Kumara Patties
(1, 1, 29, 50), -- Crepes
(1, 1, 30, 50), -- Smokey BBQ Pulled Pork in a Bun
(1, 1, 31, 50), -- Muffins
(1, 1, 32, 50), -- Slices
(1, 1, 33, 50), -- Chicken Tenders
(1, 1, 34, 50), -- Veggie Burger
(1, 1, 35, 50), -- Fish Tacos
(1, 1, 36, 50), -- Loaded Fries
(1, 1, 37, 50), -- Falafel Wrap
(1, 1, 38, 50), -- Cheese Nachos
(1, 1, 39, 50), -- Spicy Ramen
(1, 1, 40, 50), -- Stinky Tofu
(1, 1, 41, 50), -- Grilled Cold Noodles

-- Travel Essentials & Souvenirs (only product inventory)
(1, 1, 54, 50), -- Sandfly Spray
(1, 1, 55, 50), -- Sunscreen
(1, 1, 56, 50), -- Rain Gear
(1, 1, 57, 50); -- Greenstone Jewelry

-- 9. promotion
INSERT INTO `promotion` (`code`, `description`, `discount_value`,  `valid_from`, `valid_until`, `usage_limit`, `is_active`, `minimum_amount`)
VALUES ('WINTER2024', 'Winter 2024 discount - 10% off', 10.00, '2024-06-01', '2024-08-31', 100, TRUE, 20.00);

-- 11. Insert into orders
INSERT INTO `orders` (`customer_id`, `total_price`, `special_requests`, `scheduled_pickup_time`, `status`, `created_at`) VALUES 
(1000, 25.00, 'Add whipped cream to the coffee.', '2024-06-01 10:00', 'collected', '2024-06-01 09:00'), -- Order 1
(1000, 18.50, 'Less ice, please.', '2024-06-01 12:00', 'cancelled', '2024-06-01 11:00'), -- Order 2
(1000, 15.00, 'Less ice, please.', '2024-06-13 14:00', 'ordered', '2024-06-12 13:00'), -- Order 3
(1000, 22.50, 'Add extra napkins.', '2024-06-13 10:00', 'ordered', '2024-06-13 07:00'), -- Order 4
(1000, 30.00, 'Add extra napkins.', '2024-06-04 20:00', 'collected', '2024-06-04 16:00'), -- Order 5

(1001, 20.00, 'Extra hot, please.', '2024-05-28 10:00', 'collected', '2024-05-28 09:00'), -- Order 6
(1001, 15.00, 'No sugar in the coffee.', '2024-05-27 12:00', 'collected', '2024-05-27 11:00'), -- Order 7
(1001, 12.50, 'Add extra cream.', '2024-06-13 10:00', 'ordered', '2024-06-13 07:00'), -- Order 8

(1002, 18.00, 'Less ice.', '2024-05-25 10:00', 'collected', '2024-05-25 09:00'), -- Order 9
(1002, 22.00, 'Extra spicy.', '2024-06-13 20:00', 'cancelled', '2024-06-03 11:00'), -- Order 10
(1002, 19.50, 'No dairy.', '2024-06-13 14:00', 'ordered', '2024-06-12 12:00'), -- Order 11

(1003, 20.00, 'Add extra sugar.', '2024-06-06 09:00', 'collected', '2024-06-03 10:00'), -- Order 12
(1003, 22.50, 'No cream.', '2024-06-13 09:30', 'ordered', '2024-06-13 08:00'), -- Order 13

(1004, 18.00, 'Extra hot, please.', '2024-06-06 10:00', 'cancelled', '2024-06-03 12:00'), -- Order 14
(1004, 25.00, 'Extra hot for my coffee, please.', '2024-06-13 09:30', 'ordered', '2024-06-13 07:00'), -- Order 15

(1005, 19.00, 'More napkins.', '2024-06-13 11:00', 'ordered', '2024-06-13 7:00'), -- Order 16
(1005, 21.50, 'Extra hot, please.', '2024-06-06 16:00', 'cancelled', '2024-06-03 15:00'), -- Order 17

(1006, 6.00, 'Extra hot, please.', '2024-06-13 15:00', 'ordered', '2024-06-12 10:00'), -- Order 18

(1007, 6.00, 'Extra hot, please.', '2024-06-13 18:00', 'ordered', '2024-06-13 14:00'), -- Order 19

(1008, 12.00, 'Extra hot, please.', '2024-06-13 16:00', 'ordered', '2024-06-13 14:00'), -- Order 20

(1009, 06.00, 'Extra hot, please.', '2024-06-13 17:00', 'ordered', '2024-06-13 15:00'), -- Order 21

(1010, 06.00, 'Extra hot, please.', '2024-06-13 19:00', 'ordered', '2024-06-13 17:00'); -- Order 22


-- 11. Insert into order_item
-- Insert into order_item
INSERT INTO `order_item` (`order_id`, `product_id`, `quantity`) VALUES 
-- Order 1 items
(1, 1, 1), -- Espresso
(1, 6, 1), -- Hot Chocolate
(1, 9, 2), -- Coca-Cola
-- Add-ons for Order 1
(1, 22, 1), -- Peach Iced Tea
(1, 23, 1), -- Raspberry Iced Tea

-- Order 2 items
(2, 4, 1), -- Flat White
(2, 10, 1), -- Sprite
(2, 11, 1), -- Fanta
-- Add-ons for Order 2
(2, 24, 1), -- Green Iced Tea
(2, 25, 1), -- Hibiscus Iced Tea

-- Order 3 items
(3, 2, 1), -- Latte
(3, 12, 1), -- Pepsi
(3, 13, 2), -- Ginger Ale
-- Add-ons for Order 3
(3, 26, 1), -- Grilled Onions
(3, 27, 1), -- BBQ Sauce

-- Order 4 items
(4, 3, 1), -- Cappuccino
(4, 14, 1), -- Classic Vanilla Milkshake
(4, 15, 1), -- Rich Chocolate Milkshake
-- Add-ons for Order 4
(4, 28, 1), -- Mustard
(4, 29, 1), -- Mayo

-- Order 5 items
(5, 5, 1), -- Mocha
(5, 16, 1), -- Strawberry Delight Milkshake
(5, 17, 1), -- Caramel Swirl Milkshake
-- Add-ons for Order 5
(5, 30, 1), -- Light Ice
(5, 31, 1), -- No Ice

-- Order 6 items
(6, 1, 1), -- Espresso
(6, 2, 1), -- Latte
(6, 3, 1), -- Cappuccino
-- Add-ons for Order 6
(6, 22, 1), -- Gluten-Free Bun

-- Order 7 items
(7, 4, 1), -- Flat White
(7, 5, 1), -- Mocha
-- Add-ons for Order 7
(7, 23, 1), -- Sesame Bun
(7, 24, 1), -- Extra Cheese

-- Order 8 items
(8, 6, 1), -- Hot Chocolate
(8, 7, 1), -- Herbal Tea
(8, 8, 1), -- Chai Latte
-- Add-ons for Order 8
(8, 25, 1), -- Bacon
(8, 26, 1), -- Grilled Onions

-- Order 9 items
(9, 9, 1), -- Coca-Cola
(9, 10, 1), -- Sprite
(9, 11, 1), -- Fanta
-- Add-ons for Order 9
(9, 27, 1), -- BBQ Sauce

-- Order 10 items
(10, 12, 1), -- Pepsi
(10, 13, 1), -- Ginger Ale
(10, 14, 1), -- Classic Vanilla Milkshake
-- Add-ons for Order 10
(10, 28, 1), -- Mustard

-- Order 11 items
(11, 15, 1), -- Rich Chocolate Milkshake
(11, 16, 1), -- Strawberry Delight Milkshake
(11, 17, 1), -- Caramel Swirl Milkshake
-- Add-ons for Order 11
(11, 29, 1), -- Mayo
(11, 30, 1), -- Light Ice

(12, 1, 1), -- Espresso
(12, 15, 1), -- Rich Chocolate Milkshake
(13, 2, 1), -- Latte
(13, 16, 1), -- Strawberry Delight Milkshake
(14, 3, 1), -- Cappuccino
(14, 17, 1), -- Caramel Swirl Milkshake
(15, 4, 1), -- Flat White
(15, 18, 1), -- Banana Bliss Milkshake
(16, 5, 1), -- Mocha
(16, 19, 1), -- Cookies and Cream Milkshake
(17, 6, 1), -- Hot Chocolate
(17, 20, 1), -- Seasonal Berry Milkshake
(18, 3, 1), -- Cappuccino
(19, 3, 1), -- Cappuccino
(20, 17, 1), -- Caramel Swirl Milkshake
(20, 3, 1), -- Cappuccino
(21, 17, 1), -- Caramel Swirl Milkshake
(22, 3, 1); -- Cappuccino

-- 13. insert accommodation
INSERT INTO accommodation (accommodation_id, type, description, capacity, space, price_per_night, is_available, image)
VALUES
(1, 'Dorm', 'Our dorm features four comfortable single bunks, perfect for family or friends eager to stay together. Ideal for groups of four, you can book the entire room to enjoy a private experience. Alternatively, book just one bunk and embrace the opportunity to meet and share the space with three new friends. Whether you are a solo traveler or planning a group adventure, our dorm offers a fun and affordable accommodation option.', 4, 4, 55, TRUE, 'dorm.jpg'),
(2, 'Twin', 'Our twin bed room is thoughtfully designed for comfort and privacy, featuring two single beds for friends traveling together or solo travelers seeking extra space. Guests have convenient access to modern shared bathroom and kitchen facilities, which are maintained to the highest standards. Whether you’re in town for business or leisure, our twin bed room offers a comfortable base for your adventures.', 2, 1, 155, TRUE, 'twin.jpg'),
(3, 'Queen', 'Perfect for couples or families, our Queen bed room features a luxurious queen-sized bed and a convenient pull-out sofa, making it ideal for up to three guests. Guests have convenient access to modern shared bathroom and kitchen facilities, which are cleaned and maintained to the highest standards. It’s more than just a place to sleep—it’s a home away from home to live, laugh, and create memories.', 3, 1, 205, TRUE, 'queen.jpg');

-- 15. insert booking table--
INSERT INTO booking 
VALUES
(1, 1000, 1, 1, '2024-06-04', '2024-06-05', 1, 0, 1, 1, 'confirmed', '2024-05-11'),
(2, 1000, 2, 2, '2024-06-13', '2024-06-14', 2, 0, 1, 1, 'confirmed', '2024-05-12'),
(3, 1000, 3, 3, '2024-06-22', '2024-06-25', 2, 1, 1, 1, 'confirmed', '2024-04-12'),
(4, 1000, 4, 3, '2024-02-25', '2024-02-26', 2, 1, 1, 1, 'checked out', '2024-01-20'),
(5, 1001, 5, 1, '2024-06-13', '2024-06-14', 1, 0, 1, 1, 'confirmed', '2024-01-12'),
(6, 1001, 6, 2, '2024-02-25', '2024-02-26', 1, 1, 1, 1, 'confirmed', '2024-01-13'),
(7, 1001, 7, 1, '2024-02-25', '2024-02-27', 2, 0, 1, 1, 'checked out', '2024-01-14'),
(8, 1002, 8, 1, '2024-06-25', '2024-06-26', 1, 0, 1, 1, 'confirmed', '2024-01-15'),
(9, 1002, 9, 2, '2024-06-12', '2024-06-13', 1, 1, 1, 1, 'checked in', '2024-01-16'),
(10, 1002, 10, 3, '2024-06-12', '2024-06-14', 2, 0, 1, 1, 'confirmed', '2024-01-17');

-- 16. insert message table--
INSERT INTO `message` (`message_id`, `customer_id`, `manager_id`, `staff_id`, `sender_type`, `content`)
VALUES 
(1, 1000, 1, NULL, 'manager',
'Hi, You have received a seaonal promotion! This promotion can be used during the winter season between 01/06/2024 and 31/08/2024. When you spend over $20 on our food, drinks, and products, you will get 10% off. Please use our code:Winter2024'),
(2, 1001, 1, 1, 'customer', 'Hi, Can you please confirm my booking for the 13th of June?'),
(3, 1001, 1, NULL, 'manager', 'Hi, I am Ava, hope you are doing well. I have check that you have been booked for the 13th of June'),
(4, 1001, NULL, Null, 'customer', 'Hi, This function(socket) can not run in Pythonanywhere'),
(5, 1001, 1, NULL, 'staff', 'This is just a example'),
(6, 1000, NULL, Null, 'customer', 'Hi, This function(socket) can not run in Pythonanywhere'),
(7, 1000, 1, NULL, 'staff', 'This is just a example');

-- 18. insert into payment_type
INSERT INTO `payment_type` (`payment_type_id`, `payment_type`)VALUES
(1, 'gift_card'),
(2, 'bank_card');

-- 19. insert into bank_card
INSERT INTO `bank_card` (`bank_card_id`, `card_num`, `expire_Date`, `payment_type_id`) VALUES
(1, 1234567812345678, '2025-12-31', 2),
(2, 8765432187655555, '2025-06-18', 2),
(3, 8765432187654221, '2025-06-30', 2),
(4, 8764542187657821, '2026-05-30', 2),
(5, 5425432187654321, '2024-09-30', 2),
(6, 5454345687654397, '2027-06-30', 2),
(7, 8034594387655551, '2028-04-30', 2),
(8, 1343432187654464, '2027-02-25', 2),
(9, 7843218734654321, '2026-09-25', 2),
(10, 1111222233334444, '2026-01-15', 2);

-- 20. insert into gift_Card
INSERT INTO `gift_card` (`gift_card_id`, `code`, `balance`, `expiration_date`, `is_active`, `purchase_amount`, `payment_type_id`)
VALUES (1, 'GFT123456', 100.00, '2025-01-31', TRUE, 100.00, 1);

-- 22. insert payment table--
INSERT INTO `payment` (`customer_id`, `payment_type_id`, `order_id`, `booking_id`, `paid_amount`)
VALUES
(1000, 1, NULL, 1, 55.00),
(1000, 2, NULL, 2, 155.00),
(1000, 2, NULL, 3, 615.00),
(1000, 2, NULL, 4, 205.00),
(1001, 2, NULL, 5, 55.00),
(1001, 2, NULL, 6, 155.00),
(1001, 2, NULL, 7, 110.00),
(1002, 2, NULL, 8, 55.00),
(1002, 2, NULL, 9, 155.00),
(1002, 2, NULL, 10, 410.00);




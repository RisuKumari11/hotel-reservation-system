-- Drop existing database if it exists
DROP DATABASE IF EXISTS Hotel_Management_System;
CREATE DATABASE Hotel_Management_System;
USE Hotel_Management_System;

-- Create Tables
CREATE TABLE Guest (
    g_id INT PRIMARY KEY AUTO_INCREMENT,
    g_name VARCHAR(50),
    g_email VARCHAR(100) UNIQUE,
    g_number VARCHAR(15),
    g_city VARCHAR(50),
    g_state VARCHAR(50)
);

CREATE TABLE Hotel (
    h_id INT PRIMARY KEY AUTO_INCREMENT,
    h_name VARCHAR(100),
    h_street VARCHAR(100),
    h_city VARCHAR(50),
    h_state VARCHAR(50)
);

CREATE TABLE Room_Type (
    room_type_id INT PRIMARY KEY AUTO_INCREMENT,
    room_name VARCHAR(50),
    room_price DECIMAL(10,2),
    total_rooms INT,
    max_guests INT,
    admin_user_id INT
);

CREATE TABLE Room (
    r_id INT PRIMARY KEY AUTO_INCREMENT,
    r_number VARCHAR(10),
    r_price DECIMAL(10,2),
    r_status VARCHAR(20),
    hotel_id INT,
    r_type_id INT,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(h_id),
    FOREIGN KEY (r_type_id) REFERENCES Room_Type(room_type_id)
);

CREATE TABLE Reservation (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    guest_id INT,
    check_in_date DATE,
    check_out_date DATE,
    booking_date DATE,
    reservation_status VARCHAR(20),
    FOREIGN KEY (guest_id) REFERENCES Guest(g_id)
);

CREATE TABLE Administrator (
    a_user_id INT PRIMARY KEY AUTO_INCREMENT,
    a_username VARCHAR(50) UNIQUE,
    a_email VARCHAR(100),
    a_pwd VARCHAR(50),
    res_id INT,
    FOREIGN KEY (res_id) REFERENCES Reservation(reservation_id)
);

CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    g_id INT,
    reservation_id INT,
    payment_amount DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_date DATE,
    FOREIGN KEY (g_id) REFERENCES Guest(g_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
);

CREATE TABLE Reserved_By (
    r_id INT,
    reservation_id INT,
    PRIMARY KEY (r_id, reservation_id),
    FOREIGN KEY (r_id) REFERENCES Room(r_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
);

CREATE TABLE Hotel_Phone (
    h_id INT,
    h_phone VARCHAR(15),
    PRIMARY KEY (h_id, h_phone),
    FOREIGN KEY (h_id) REFERENCES Hotel(h_id)
);

CREATE TABLE Payment_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    log_message VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INSERT HOTELS
-- ============================================

INSERT INTO Hotel (h_name, h_street, h_city, h_state) VALUES
('Taj Palace', 'MG Road', 'Delhi', 'Delhi'),
('Oberoi Grand', 'Park Street', 'Kolkata', 'West Bengal'),
('The Leela Palace', 'Bhikaji Cama Place', 'New Delhi', 'Delhi'),
('ITC Maurya', 'Sardar Patel Marg', 'New Delhi', 'Delhi'),
('Radisson Blu', 'Mahipalpur', 'New Delhi', 'Delhi'),
('Hilton Mumbai', 'Nariman Point', 'Mumbai', 'Maharashtra'),
('Marriott Bangalore', 'Whitefield', 'Bangalore', 'Karnataka'),
('Hyatt Bangalore', 'Koramangala', 'Bangalore', 'Karnataka');

-- ============================================
-- INSERT ROOM TYPES
-- ============================================

INSERT INTO Room_Type (room_name, room_price, total_rooms, max_guests, admin_user_id) VALUES
('Single Room', 2500, 30, 1, NULL),
('Deluxe', 4000, 40, 2, NULL),
('Double Bed', 4500, 35, 2, NULL),
('Suite', 7000, 20, 4, NULL),
('Presidential Suite', 15000, 5, 6, NULL),
('Twin Bed', 3500, 25, 2, NULL),
('Family Room', 6000, 15, 4, NULL);

-- ============================================
-- INSERT ROOMS FOR TAJ PALACE (h_id = 1)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 2500, 'Available', 1, 1),
('S102', 2500, 'Available', 1, 1),
('S103', 2500, 'Available', 1, 1),
('S104', 2500, 'Available', 1, 1),
('S105', 2500, 'Available', 1, 1),

-- Deluxe Rooms
('D201', 4000, 'Available', 1, 2),
('D202', 4000, 'Available', 1, 2),
('D203', 4000, 'Available', 1, 2),
('D204', 4000, 'Available', 1, 2),
('D205', 4000, 'Available', 1, 2),

-- Double Bed
('DB301', 4500, 'Available', 1, 3),
('DB302', 4500, 'Available', 1, 3),
('DB303', 4500, 'Available', 1, 3),

-- Suites
('SU401', 7000, 'Available', 1, 4),
('SU402', 7000, 'Available', 1, 4),

-- Presidential Suite
('PS501', 15000, 'Available', 1, 5);

-- ============================================
-- INSERT ROOMS FOR OBEROI GRAND (h_id = 2)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 2800, 'Available', 2, 1),
('S102', 2800, 'Available', 2, 1),
('S103', 2800, 'Available', 2, 1),
('S104', 2800, 'Available', 2, 1),

-- Deluxe Rooms
('D201', 4500, 'Available', 2, 2),
('D202', 4500, 'Available', 2, 2),
('D203', 4500, 'Available', 2, 2),
('D204', 4500, 'Available', 2, 2),

-- Twin Bed
('T301', 3800, 'Available', 2, 6),
('T302', 3800, 'Available', 2, 6),

-- Family Room
('F401', 6500, 'Available', 2, 7),
('F402', 6500, 'Available', 2, 7);

-- ============================================
-- INSERT ROOMS FOR THE LEELA PALACE (h_id = 3)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 3200, 'Available', 3, 1),
('S102', 3200, 'Available', 3, 1),
('S103', 3200, 'Available', 3, 1),

-- Deluxe Rooms
('D201', 5500, 'Available', 3, 2),
('D202', 5500, 'Available', 3, 2),
('D203', 5500, 'Available', 3, 2),
('D204', 5500, 'Available', 3, 2),
('D205', 5500, 'Available', 3, 2),

-- Double Bed
('DB301', 5200, 'Available', 3, 3),
('DB302', 5200, 'Available', 3, 3),

-- Suites
('SU401', 8500, 'Available', 3, 4),
('SU402', 8500, 'Available', 3, 4),
('SU403', 8500, 'Available', 3, 4);

-- ============================================
-- INSERT ROOMS FOR ITC MAURYA (h_id = 4)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 3000, 'Available', 4, 1),
('S102', 3000, 'Available', 4, 1),
('S103', 3000, 'Available', 4, 1),
('S104', 3000, 'Available', 4, 1),

-- Deluxe Rooms
('D201', 5000, 'Available', 4, 2),
('D202', 5000, 'Available', 4, 2),
('D203', 5000, 'Available', 4, 2),
('D204', 5000, 'Available', 4, 2),

-- Double Bed
('DB301', 4800, 'Available', 4, 3),
('DB302', 4800, 'Available', 4, 3),
('DB303', 4800, 'Available', 4, 3),

-- Family Room
('F401', 7200, 'Available', 4, 7),
('F402', 7200, 'Available', 4, 7);

-- ============================================
-- INSERT ROOMS FOR RADISSON BLU (h_id = 5)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 2200, 'Available', 5, 1),
('S102', 2200, 'Available', 5, 1),
('S103', 2200, 'Available', 5, 1),
('S104', 2200, 'Available', 5, 1),
('S105', 2200, 'Available', 5, 1),

-- Deluxe Rooms
('D201', 3500, 'Available', 5, 2),
('D202', 3500, 'Available', 5, 2),
('D203', 3500, 'Available', 5, 2),
('D204', 3500, 'Available', 5, 2),

-- Twin Bed
('T301', 3200, 'Available', 5, 6),
('T302', 3200, 'Available', 5, 6),
('T303', 3200, 'Available', 5, 6);

-- ============================================
-- INSERT ROOMS FOR HILTON MUMBAI (h_id = 6)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 3500, 'Available', 6, 1),
('S102', 3500, 'Available', 6, 1),
('S103', 3500, 'Available', 6, 1),

-- Deluxe Rooms
('D201', 5500, 'Available', 6, 2),
('D202', 5500, 'Available', 6, 2),
('D203', 5500, 'Available', 6, 2),
('D204', 5500, 'Available', 6, 2),

-- Double Bed
('DB301', 5200, 'Available', 6, 3),
('DB302', 5200, 'Available', 6, 3),

-- Suites
('SU401', 9000, 'Available', 6, 4),
('SU402', 9000, 'Available', 6, 4);

-- ============================================
-- INSERT ROOMS FOR MARRIOTT BANGALORE (h_id = 7)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 2800, 'Available', 7, 1),
('S102', 2800, 'Available', 7, 1),
('S103', 2800, 'Available', 7, 1),

-- Deluxe Rooms
('D201', 4200, 'Available', 7, 2),
('D202', 4200, 'Available', 7, 2),
('D203', 4200, 'Available', 7, 2),
('D204', 4200, 'Available', 7, 2),
('D205', 4200, 'Available', 7, 2),

-- Twin Bed
('T301', 3800, 'Available', 7, 6),
('T302', 3800, 'Available', 7, 6),

-- Family Room
('F401', 6200, 'Available', 7, 7);

-- ============================================
-- INSERT ROOMS FOR HYATT BANGALORE (h_id = 8)
-- ============================================

INSERT INTO Room (r_number, r_price, r_status, hotel_id, r_type_id) VALUES
-- Single Rooms
('S101', 3000, 'Available', 8, 1),
('S102', 3000, 'Available', 8, 1),

-- Deluxe Rooms
('D201', 4800, 'Available', 8, 2),
('D202', 4800, 'Available', 8, 2),
('D203', 4800, 'Available', 8, 2),
('D204', 4800, 'Available', 8, 2),

-- Double Bed
('DB301', 5000, 'Available', 8, 3),
('DB302', 5000, 'Available', 8, 3),

-- Suites
('SU401', 8200, 'Available', 8, 4),
('SU402', 8200, 'Available', 8, 4),

-- Family Room
('F401', 6800, 'Available', 8, 7);

-- ============================================
-- INSERT HOTEL PHONE NUMBERS
-- ============================================

INSERT INTO Hotel_Phone (h_id, h_phone) VALUES
(1, '011-23456789'),
(1, '011-23456790'),
(2, '033-22876543'),
(2, '033-22876544'),
(3, '011-41234567'),
(3, '011-41234568'),
(4, '011-26117777'),
(4, '011-26117778'),
(5, '011-41657777'),
(5, '011-41657778'),
(6, '022-61322323'),
(6, '022-61322324'),
(7, '080-41234567'),
(7, '080-41234568'),
(8, '080-41515151'),
(8, '080-41515152');

-- ============================================
-- INSERT ADMIN USERS
-- ============================================

INSERT INTO Administrator (a_username, a_email, a_pwd, res_id) VALUES
('admin_taj', 'admin@tajpalace.com', 'admin123', NULL),
('admin_oberoi', 'admin@oberoi.com', 'admin123', NULL),
('admin_leela', 'admin@leela.com', 'admin123', NULL),
('admin_itc', 'admin@itc.com', 'admin123', NULL),
('admin_radisson', 'admin@radisson.com', 'admin123', NULL),
('admin_hilton', 'admin@hilton.com', 'admin123', NULL),
('admin_marriott', 'admin@marriott.com', 'admin123', NULL),
('admin_hyatt', 'admin@hyatt.com', 'admin123', NULL);

SELECT 'Hotels Inserted:' AS Info, COUNT(*) AS Count FROM Hotel;
SELECT 'Room Types Inserted:' AS Info, COUNT(*) AS Count FROM Room_Type;
SELECT 'Rooms Inserted:' AS Info, COUNT(*) AS Count FROM Room;
SELECT 'Admins Inserted:' AS Info, COUNT(*) AS Count FROM Administrator;

-- Show room breakdown by hotel
SELECT h.h_name, COUNT(r.r_id) as total_rooms 
FROM Hotel h 
LEFT JOIN Room r ON h.h_id = r.hotel_id 
GROUP BY h.h_id, h.h_name;

-- PROCEDURE 1: Book Room
DELIMITER $$
CREATE PROCEDURE sp_BookRoom(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_checkin DATE,
    IN p_checkout DATE
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Reservation (reservation_id, guest_id, check_in_date, check_out_date, booking_date, reservation_status)
    VALUES (FLOOR(RAND()*100000), p_guest_id, p_checkin, p_checkout, CURDATE(), 'Booked');

    UPDATE Room SET r_status = 'Booked' WHERE r_id = p_room_id;

    COMMIT;
END$$
DELIMITER ;

-- PROCEDURE 2: Cancel Reservation
DELIMITER $$
CREATE PROCEDURE sp_CancelReservation(IN p_reservation_id INT)
BEGIN
    DECLARE v_room_id INT;

    START TRANSACTION;

    SELECT r_id INTO v_room_id FROM Reserved_By WHERE reservation_id = p_reservation_id;
    UPDATE Room SET r_status = 'Available' WHERE r_id = v_room_id;
    UPDATE Reservation SET reservation_status = 'Cancelled' WHERE reservation_id = p_reservation_id;

    COMMIT;
END$$
DELIMITER ;

-- ============================================
-- 2 FUNCTIONS
-- ============================================

-- FUNCTION 1: Calculate Stay Duration (in nights)
DELIMITER $$
CREATE FUNCTION fn_StayDuration(p_checkin DATE, p_checkout DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(p_checkout, p_checkin);
END$$
DELIMITER ;

-- ============================================
-- 2 TRIGGERS
-- ============================================

-- TRIGGER 1: Update Room Status When Booked
DELIMITER $$
CREATE TRIGGER trg_update_room_status
AFTER INSERT ON Reserved_By
FOR EACH ROW
BEGIN
    UPDATE Room
    SET r_status = 'Booked'
    WHERE r_id = NEW.r_id;
END$$
DELIMITER ;

-- TRIGGER 2: Log Payment Transaction
DELIMITER $$
CREATE TRIGGER trg_payment_logging
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    INSERT INTO Payment_Log (payment_id, log_message)
    VALUES (NEW.payment_id, CONCAT('Payment of ₹', NEW.payment_amount, ' received via ', NEW.payment_method));
END$$
DELIMITER ;

SELECT fn_StayDuration('2025-11-10', '2025-11-15') AS nights_stayed;

-- View All Payment Logs
SELECT * FROM Payment_Log ORDER BY log_time DESC LIMIT 10;

-- View All Reservations
SELECT * FROM Reservation LIMIT 10;

-- View Room Status
SELECT r.r_id, r.r_number, h.h_name, r.r_status FROM Room r 
JOIN Hotel h ON r.hotel_id = h.h_id LIMIT 10;
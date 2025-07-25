-- Airline Reservation System: Complete Project SQL File

-- ================================
-- 1. SCHEMA DESIGN
-- ================================

-- Flights table
CREATE TABLE Flights (
    FlightID INT AUTO_INCREMENT PRIMARY KEY,
    FlightNumber VARCHAR(10) NOT NULL,
    Origin VARCHAR(50) NOT NULL,
    Destination VARCHAR(50) NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    UNIQUE (FlightNumber, DepartureTime)
);

-- Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20)
);

-- Seats table
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    FlightID INT NOT NULL,
    SeatNumber VARCHAR(5) NOT NULL,
    IsBooked BOOLEAN DEFAULT FALSE,
    CONSTRAINT FK_Seats_Flight FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    UNIQUE (FlightID, SeatNumber)
);

-- Bookings table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    FlightID INT NOT NULL,
    SeatID INT NOT NULL,
    BookingTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('CONFIRMED','CANCELLED') DEFAULT 'CONFIRMED',
    CONSTRAINT FK_Bookings_Customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Bookings_Flight FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    CONSTRAINT FK_Bookings_Seat FOREIGN KEY (SeatID) REFERENCES Seats(SeatID),
    UNIQUE (FlightID, SeatID)
);

-- ================================
-- 2. SAMPLE DATA
-- ================================

-- Flights
INSERT INTO Flights (FlightNumber, Origin, Destination, DepartureTime, ArrivalTime) VALUES
('AI101', 'New York', 'London', '2025-08-01 09:00:00', '2025-08-01 21:00:00'),
('AI102', 'London', 'Paris', '2025-08-02 10:00:00', '2025-08-02 12:00:00');

-- Customers
INSERT INTO Customers (FullName, Email, Phone) VALUES
('Alice Smith', 'alice@example.com', '1234567890'),
('Bob Jones', 'bob@example.com', '0987654321');

-- Seats for Flight 1
INSERT INTO Seats (FlightID, SeatNumber) VALUES
(1, '1A'), (1, '1B'), (1, '2A'), (1, '2B');

-- Seats for Flight 2
INSERT INTO Seats (FlightID, SeatNumber) VALUES
(2, '1A'), (2, '1B');

-- Bookings (Alice books 1A on AI101, Bob books 1B on AI101)
INSERT INTO Bookings (CustomerID, FlightID, SeatID, Status) VALUES
(1, 1, 1, 'CONFIRMED'),
(2, 1, 2, 'CONFIRMED');

-- Update seat booking status
UPDATE Seats SET IsBooked = TRUE WHERE SeatID IN (1,2);

-- ================================
-- 3. USEFUL QUERIES
-- ================================

-- 1. Find all available seats for a given flight
-- Example: For FlightNumber 'AI101'
SELECT f.FlightNumber, s.SeatNumber
FROM Flights f
JOIN Seats s ON f.FlightID = s.FlightID
WHERE f.FlightNumber = 'AI101' AND s.IsBooked = FALSE;

-- 2. Find flights between two cities on a particular date
SELECT * FROM Flights
WHERE Origin = 'New York' AND Destination = 'London'
  AND DATE(DepartureTime) = '2025-08-01';

-- 3. Booking summary for a customer (CustomerID = 1)
SELECT b.BookingID, f.FlightNumber, s.SeatNumber, b.Status, b.BookingTime
FROM Bookings b
JOIN Flights f ON b.FlightID = f.FlightID
JOIN Seats s ON b.SeatID = s.SeatID
WHERE b.CustomerID = 1;

-- 4. Booking summary for a flight (FlightID = 1)
SELECT b.BookingID, c.FullName, s.SeatNumber, b.Status, b.BookingTime
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Seats s ON b.SeatID = s.SeatID
WHERE b.FlightID = 1;

-- ================================
-- 4. TRIGGERS
-- ================================

-- On booking CONFIRMED, set seat as booked
DELIMITER $$
CREATE TRIGGER trg_set_seat_booked
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'CONFIRMED' THEN
        UPDATE Seats SET IsBooked = TRUE WHERE SeatID = NEW.SeatID;
    END IF;
END$$
DELIMITER ;

-- On booking cancellation, set seat as not booked
DELIMITER $$
CREATE TRIGGER trg_set_seat_unbooked
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'CANCELLED' THEN
        UPDATE Seats SET IsBooked = FALSE WHERE SeatID = NEW.SeatID;
    END IF;
END$$
DELIMITER ;

-- ================================
-- 5. VIEWS & REPORTS
-- ================================

-- View: Available seats per flight
CREATE OR REPLACE VIEW AvailableSeats AS
SELECT f.FlightNumber, s.SeatNumber
FROM Flights f
JOIN Seats s ON f.FlightID = s.FlightID
WHERE s.IsBooked = FALSE;

-- View: Booking summary per flight
CREATE OR REPLACE VIEW FlightBookingSummary AS
SELECT b.BookingID, f.FlightNumber, c.FullName, s.SeatNumber, b.Status, b.BookingTime
FROM Bookings b
JOIN Flights f ON b.FlightID = f.FlightID
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Seats s ON b.SeatID = s.SeatID;

-- ================================
-- END OF FILE
-- ================================
# Airline Reservation System

A robust SQL-based project for managing airline flights, bookings, customers, and seat assignments.  
Built using **MySQL Workbench**.

---

## Objective

Design and implement a normalized SQL system to efficiently manage flights, bookings, seat allocations, and customer information, with automated processes and reporting features.

---

## Tools Used

- **MySQL Workbench** (for database design, querying, and management)
- **MySQL (SQL language)** for DDL, DML, triggers, and views

---

## Project Steps

### 1. Schema Design

Tables:
- **Flights:** Flight details (number, source, destination, schedule)
- **Customers:** Passenger info
- **Bookings:** Reservations with status and timestamps
- **Seats:** Seat assignments per flight, linked to bookings

### 2. Normalization & Constraints

- All tables normalized (up to 3NF)
- Primary and foreign keys for referential integrity
- Constraints to ensure valid data (e.g., seat cannot be double-booked)

### 3. Sample Data

- Example flights, customers, bookings, and seat assignments inserted for demonstration and testing

### 4. Core Queries

- **Available seats for a flight**
- **Flight search by source, destination, and date**
- **Booking summary report**

### 5. Triggers

- Automatically release a seat when a booking is cancelled
- Update seat assignment on booking changes

### 6. Reporting & Views

- **Booking summary report** (who booked which seat on which flight)
- **Flight availability view** (real-time available and booked seats per flight)

---

## Example Schema (DDL)

```sql
CREATE TABLE Flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(10) NOT NULL,
    source VARCHAR(50) NOT NULL,
    destination VARCHAR(50) NOT NULL,
    departure DATETIME NOT NULL,
    arrival DATETIME NOT NULL
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    contact VARCHAR(100)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date DATETIME NOT NULL,
    status ENUM('Booked', 'Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

CREATE TABLE Seats (
    seat_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT NOT NULL,
    seat_number VARCHAR(5) NOT NULL,
    booking_id INT,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);
```

---

## Sample Data

```sql
INSERT INTO Flights (flight_number, source, destination, departure, arrival) VALUES
('AI101', 'New York', 'London', '2025-08-01 10:00', '2025-08-01 22:00'),
('AI202', 'London', 'Paris', '2025-08-02 09:00', '2025-08-02 11:00');

INSERT INTO Customers (name, contact) VALUES
('John Doe', 'john@example.com'),
('Alice Smith', 'alice@example.com');

INSERT INTO Bookings (customer_id, flight_id, booking_date, status) VALUES
(1, 1, NOW(), 'Booked'),
(2, 2, NOW(), 'Booked');

INSERT INTO Seats (flight_id, seat_number, booking_id) VALUES
(1, '12A', 1),
(2, '14C', 2);
```

---

## Example Queries

**Available seats for a flight:**
```sql
SELECT seat_number
FROM Seats
WHERE flight_id = ? AND booking_id IS NULL;
```

**Flight search:**
```sql
SELECT * FROM Flights
WHERE source = 'New York' AND destination = 'London' AND DATE(departure) = '2025-08-01';
```

**Booking summary report:**
```sql
SELECT b.booking_id, c.name AS customer, f.flight_number, s.seat_number, b.status
FROM Bookings b
JOIN Customers c ON b.customer_id = c.customer_id
JOIN Flights f ON b.flight_id = f.flight_id
LEFT JOIN Seats s ON b.booking_id = s.booking_id;
```

---

## Example Triggers

**Release seat on booking cancellation:**
```sql
CREATE TRIGGER trg_after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
  IF NEW.status = 'Cancelled' THEN
    UPDATE Seats SET booking_id = NULL WHERE booking_id = NEW.booking_id;
  END IF;
END;
```

---

## Example Views

**Flight availability view:**
```sql
CREATE VIEW Flight_Availability AS
SELECT f.flight_id, f.flight_number,
       COUNT(s.seat_id) AS total_seats,
       SUM(CASE WHEN s.booking_id IS NULL THEN 1 ELSE 0 END) AS available_seats
FROM Flights f
LEFT JOIN Seats s ON f.flight_id = s.flight_id
GROUP BY f.flight_id;
```

---

## Deliverables

- **SQL Schema:** Normalized tables with constraints
- **Sample Data:** Example inserts for flights, customers, bookings, seats
- **Queries:** For seat availability, flight search, and reports
- **Triggers:** For booking and seat management
- **Views:** For booking summaries and flight availability

---

## Author : 

- Ajay kumar J
---
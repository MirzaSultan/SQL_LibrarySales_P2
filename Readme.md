
## 📚 Library Management System: SQL Project Tasks

## SQL Database Project Documentation



## 🎯 Project Overview

The Library Management System represents a comprehensive database solution designed to streamline library operations and enhance the management of books, members, and staff activities. This project demonstrates practical application of database design principles and SQL programming techniques in a real-world scenario.

> **Project Scope:** This system manages the complete lifecycle of library operations, from book inventory management to member registration, book issuance tracking, and return processing. The database architecture supports multiple branches, employee management, and detailed reporting capabilities.

### Key System Components

The system is built around five core database tables that work together to provide comprehensive library management functionality. The Books table maintains our complete inventory with pricing and availability status. The Members table handles user registration and contact information. The Issued Status table tracks all book lending activities, while the Return Status table manages book returns. Finally, the Employees and Branch tables support multi-location operations with proper staff assignment and management hierarchy.

### Technology Stack

- SQL Server
- T-SQL
- Stored Procedures
- Views
- CTAS Operations
- Database Design

---

## 🎯 Project Objectives

**Database Design Mastery:** Implement a normalized database structure that eliminates redundancy while maintaining data integrity and supporting efficient queries across multiple related tables.

**CRUD Operations Excellence:** Develop proficiency in all fundamental database operations including Create, Read, Update, and Delete operations with real-world business logic and constraints.

**Advanced SQL Techniques:** Master complex SQL concepts including joins, subqueries, aggregate functions, window functions, and conditional logic to solve business problems effectively.

**Stored Procedure Development:** Create reusable database procedures that encapsulate business logic, improve performance, and maintain consistency across application operations.

**Reporting and Analytics:** Build comprehensive reporting capabilities that provide insights into library operations, member behavior, and resource utilization patterns.

**Performance Optimization:** Implement efficient query designs and database structures that can handle growing data volumes while maintaining responsive performance.

**Business Logic Implementation:** Translate real-world library management requirements into database constraints, triggers, and procedural logic that enforces business rules automatically.

---

## 💻 Project SQL Implementation
---

### 1. View All Records

```sql
SELECT * FROM books;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;
```


---

### 2. Add a New Book

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```


---

### 3. Update a Member's Address

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```


---

### 4. Delete an Issued Status Record

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS140';
```


---

### 5. Retrieve All Books Issued by a Specific Employee

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```


---

### 6. List Members Who Issued More Than One Book

```sql
SELECT issued_emp_id
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;
```


---

### 7. Create a Summary Table: Books and Issue Count (CTAS)

```sql
SELECT 
    b.isbn, 
    b.book_title, 
    COUNT(ist.issued_id) AS issue_count
INTO book_issued_cnt
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;

SELECT * FROM book_issued_cnt;
```


---

### 8. Retrieve All Books in a Specific Category

```sql
SELECT * FROM books
WHERE category = 'Classic';
```


---

### 9. Calculate Total Rental Income by Category

```sql
SELECT
    b.category,
    SUM(b.rental_price) AS total_income,
    COUNT(*) AS total_issued
FROM issued_status AS ist
JOIN books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY b.category;
```


---

### 10. Insert Multiple Members

```sql
INSERT INTO members (member_id, member_name, member_address, reg_date)
VALUES
    ('C120', 'Joe Biden', '134 Left St', '2025-05-30'),
    ('C121', 'Henry Flink', '153 Deber St', '2025-04-21');
```


---

### 11. List Members Registered in the Last 180 Days

```sql
SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());
```


---

### 12. List Employees with Branch Manager and Branch Details

```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b1.*,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b1 ON e1.branch_id = b1.branch_id
JOIN employees AS e2 ON e2.emp_id = b1.manager_id;
```


---

### 13. Create Table of Expensive Books (CTAS)

```sql
SELECT *
INTO expensive_books
FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_books;
```


---

### 14. Retrieve List of Books Not Yet Returned

```sql
SELECT * 
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```


---

### 15. Identify Members with Overdue Books

```sql
SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) AS days_overdue
FROM issued_status AS ist
JOIN members m ON m.member_id = ist.issued_member_id
JOIN books b ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
  AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY m.member_id;
```


---

### 16. Update Book Status on Return

```sql
-- Insert a return record
INSERT INTO return_status (return_id, issued_id, return_date)
VALUES ('RS119', 'IS135', GETDATE());

-- Update book status to 'yes' (available)
UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-307-58837-1';
```


---

### 17. Stored Procedure: Add Return Records

```sql
CREATE PROCEDURE add_return_records
    @p_return_id VARCHAR(10),
    @p_issued_id VARCHAR(10)
AS
BEGIN
    DECLARE @v_isbn VARCHAR(50);
    DECLARE @v_book_name VARCHAR(80);

    INSERT INTO return_status (return_id, issued_id, return_date)
    VALUES (@p_return_id, @p_issued_id, GETDATE());

    SELECT 
        @v_isbn = issued_book_isbn,
        @v_book_name = issued_book_name
    FROM issued_status
    WHERE issued_id = @p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = @v_isbn;

    PRINT 'Thank you for returning the book: ' + @v_book_name;
END;

-- Usage example:
EXEC add_return_records 'RS120', 'IS136';
```


---

### 18. Branch Performance Report (View)

```sql
CREATE VIEW branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status rs ON rs.issued_id = ist.issued_id
JOIN books bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;
```


---

### 19. Create Table of Active Members (CTAS)

```sql
SELECT *
INTO active_members
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATEADD(MONTH, -12, GETDATE())
);

SELECT * FROM active_members;
```


---

### 20. Find Top 3 Employees by Book Issues Processed

```sql
SELECT TOP 3
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN branch b ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id, b.branch_address, b.contact_no
ORDER BY no_book_issued DESC;
```


---

### 21. Stored Procedure: Issue Book

```sql
CREATE PROCEDURE issue_book
    @p_issued_id VARCHAR(10),
    @p_issued_member_id VARCHAR(30),
    @p_issued_book_isbn VARCHAR(30),
    @p_issued_emp_id VARCHAR(10)
AS
BEGIN
    DECLARE @v_status VARCHAR(10);

    SELECT @v_status = status 
    FROM books
    WHERE isbn = @p_issued_book_isbn;

    IF @v_status = 'yes' 
    BEGIN
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (@p_issued_id, @p_issued_member_id, GETDATE(), @p_issued_book_isbn, @p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = @p_issued_book_isbn;

        PRINT 'Book records added successfully for book ISBN: ' + @p_issued_book_isbn;
    END
    ELSE
    BEGIN
        PRINT 'Sorry to inform you the book you have requested is unavailable. Book ISBN: ' + @p_issued_book_isbn;
    END
END;

-- Usage example:
EXEC issue_book 'IS140', 'C108', '978-0-06-025492-6', 'E105';
```


---

### 22. Monthly Trend of Book Issues

```sql
SELECT 
    FORMAT(issued_date, 'yyyy-MM') AS month,
    COUNT(*) AS books_issued
FROM issued_status
GROUP BY FORMAT(issued_date, 'yyyy-MM')
ORDER BY month;
```


---

### 23. Identify Books Never Issued

```sql
SELECT isbn, book_title
FROM books
WHERE isbn NOT IN (SELECT DISTINCT issued_book_isbn FROM issued_status);
```


---

### 24. Branch Book Inventory Utilization

```sql
SELECT 
    b.branch_id,
    COUNT(DISTINCT i.issued_book_isbn) AS books_utilized,
    (SELECT COUNT(*) FROM books) AS total_books,
    ROUND(COUNT(DISTINCT i.issued_book_isbn) * 100.0 / (SELECT COUNT(*) FROM books), 2) AS utilization_percent
FROM branch b
JOIN employees e ON b.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY b.branch_id;
```


---

### 25. CTAS: Overdue Books \& Fines Summary

```sql
SELECT
    m.member_id,
    COUNT(CASE 
        WHEN r.return_id IS NULL AND DATEDIFF(DAY, i.issued_date, GETDATE()) > 30 THEN 1
        ELSE NULL
    END) AS overdue_books_count,
    ROUND(SUM(
        CASE 
            WHEN r.return_id IS NULL AND DATEDIFF(DAY, i.issued_date, GETDATE()) > 30 
            THEN (DATEDIFF(DAY, i.issued_date, GETDATE()) - 30) * 0.50
            ELSE 0
        END
    ), 2) AS total_fines_usd,
    COUNT(i.issued_id) AS total_books_issued
INTO overdue_fines_summary
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
GROUP BY m.member_id;

SELECT * FROM overdue_fines_summary;
```

---

# 📊 Reports and Analytics

## 📈 Operational Performance Reports
Branch performance analytics showing book issuance trends, return rates, and revenue generation across different library locations. These reports help identify high-performing branches and areas needing operational improvements.

## 👥 Member Activity Analysis
Comprehensive member engagement reports tracking reading patterns, overdue trends, and membership activity levels. This data drives member retention strategies and helps optimize library services for different user segments.

## 📚 Inventory Utilization Metrics
Detailed analysis of book circulation rates, identifying popular titles, underutilized inventory, and optimal collection development strategies. These insights guide purchasing decisions and collection management policies.

## 💰 Financial Performance Tracking
Revenue analysis by category, rental income trends, and fine collection summaries. These reports provide crucial data for budget planning, pricing strategies, and financial forecasting.

## ⏰ Overdue Management System
Automated tracking of overdue books with fine calculations, member notification systems, and collection management workflows. This ensures timely returns and maintains library resource availability.

## 👨‍💼 Staff Performance Metrics
Employee productivity reports showing book processing rates, customer service metrics, and workload distribution across different library branches and departments.

---

## Key Achievements

This project successfully demonstrates several critical database management capabilities. We implemented a fully normalized database structure that supports complex business operations while maintaining data integrity. The system includes automated business logic through stored procedures that handle book issuance and return processes with appropriate status updates and error handling.

Advanced reporting capabilities provide real-time insights into library operations, member behavior, and financial performance. The database design supports scalability with proper indexing strategies and efficient query optimization. Integration of multiple business rules ensures data consistency and operational compliance.

---

## 🎉 Project Conclusion

The Library Management System project represents a successful implementation of enterprise-level database design and management principles. Through this comprehensive system, we have created a robust foundation that addresses the complex operational needs of modern library management.

The project demonstrates practical mastery of advanced SQL techniques, from basic CRUD operations to sophisticated reporting and analytics capabilities. The implementation of stored procedures, views, and automated business logic showcases the ability to create maintainable and scalable database solutions.

Key accomplishments include the development of a normalized database structure that eliminates redundancy while maintaining performance, implementation of comprehensive reporting systems that provide actionable business insights, and creation of automated workflows that reduce manual errors and improve operational efficiency.

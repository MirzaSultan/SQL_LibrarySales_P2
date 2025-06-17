-- Project Tasks
select * from books;
SELECT * FROM members;
select * from issued_status;
select * from return_status;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address
UPDATE members
SET	member_address = '125 Main St'
WHERE	member_id='C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS140' from the issued_status table.
Delete from issued_status
where issued_id='IS140';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
Select 
	issued_emp_id
	--COUNT(issued_id) as total_books_issued
From issued_status
Group By issued_emp_id
Having Count(issued_id) > 1;


--CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
SELECT 
    b.isbn, 
    b.book_title, 
    COUNT(ist.issued_id) AS issue_count
INTO 
    book_issued_cnt
FROM 
    issued_status AS ist
JOIN 
    books AS b
    ON ist.issued_book_isbn = b.isbn
GROUP BY 
    b.isbn, 
    b.book_title;

select * from book_issued_cnt;

-- Task 7. Retrieve All Books in a Specific Category
SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

Select
    b.category,
    SUM(b.rental_price) as total_income,
    Count(*)
FROM 
    issued_status AS ist
JOIN 
    books AS b
    ON ist.issued_book_isbn = b.isbn
GROUP BY 
    b.category;

--INSERT RECORD INTO MEMBERS TABLE
Insert into members(member_id,member_name,member_address,reg_date)
Values
    (
    'C120','Joe Biden','134 Left St','2025-05-30'),
    ('C121','Henry Flink','153 Deber St','2025-04-21'
    );

-- List Members Who Registered in the Last 180 Days

SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());


-- List Employees with Their Branch Manager's Name and their branch details
select 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b1.*,
    e2.emp_name as Manager
from employees as e1
Join 
branch as b1
on e1.branch_id = b1.branch_id
Join
employees as e2
on e2.emp_id = b1.manager_id

-- Create a Table of Books with Rental Price Above a Certain Threshold
Select *
Into expensive_books
from books
where rental_price >7.00;

select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
Select * from issued_status as ist
LEFT JOIN
return_status as rs
on rs.issued_id = ist.issued_id
Where rs.return_id is NULL;



/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status = members = books = return_status
-- filter books which are being returned
-- overdue > 30

select 
    m.member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    --rs.return_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) as 'Days Overdue' 
from issued_status as ist
Join members m
on 
    m.member_id = ist.issued_member_id
Join books as b
on 
    b.isbn = ist.issued_book_isbn
Left Join return_status as rs
on 
    rs.issued_id = ist.issued_id
where 
    rs.return_date is null
    AND
    DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
Order By m.member_id;


/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/

-- Inserting Record Manaually
Insert Into return_status(return_id,issued_id,return_date)
Values ('RS119', 'IS135', GETDATE());

Update books
set status = 'yes'
where isbn = '978-0-307-58837-1';


-- Creating Stored Procedure for doing all this manaul work
CREATE PROCEDURE add_return_records
    @p_return_id VARCHAR(10),
    @p_issued_id VARCHAR(10)
AS
BEGIN
    DECLARE @v_isbn VARCHAR(50);         -- Adjust size as needed
    DECLARE @v_book_name VARCHAR(80);   -- Adjust size as needed

    -- Inserting into return_status based on user input
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (@p_return_id, @p_issued_id, GETDATE());

    -- Selecting values into variables
    SELECT 
        @v_isbn = issued_book_isbn,
        @v_book_name = issued_book_name
    FROM issued_status
    WHERE issued_id = @p_issued_id;

    -- Updating book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = @v_isbn;

    -- Displaying a message
    PRINT 'Thank you for returning the book: ' + @v_book_name;
END;

-- Testing Values
select * from issued_status
where issued_book_isbn = '978-0-7432-7357-1'

select * from books
where isbn = '978-0-7432-7357-1'

select * from return_status
where issued_id = 'IS136'

-- Inserting Record through stored procedure
EXEC add_return_records 'RS120','IS136';


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch,
showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

-- Creating a View
CREATE VIEW branch_reports AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e ON e.emp_id = ist.issued_emp_id
JOIN branch AS b ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;


-- Selecting data from view
SELECT * FROM branch_reports;


/*
Task 16: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
who have issued at least one book in the last 12 months.
*/

SELECT *
INTO active_members
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATEADD(MONTH, -12, GETDATE())
);

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY e.emp_name,b.branch_id,b.manager_id,b.branch_address,b.contact_no;


/*
Task 18: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

CREATE PROCEDURE issue_book
    @p_issued_id VARCHAR(10),
    @p_issued_member_id VARCHAR(30),
    @p_issued_book_isbn VARCHAR(30),
    @p_issued_emp_id VARCHAR(10)
AS
BEGIN
    DECLARE @v_status VARCHAR(10);

    -- Checking if the book is available 'yes'
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

-- Testing The function
SELECT * FROM books;
-- "978-0-06-025492-6" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

EXEC issue_book 'IS140', 'C108', '978-0-06-025492-6', 'E105';
EXEC issue_book 'IS141', 'C108', '978-0-375-41398-8', 'E104';

SELECT * FROM books
WHERE isbn = '978-0-06-025492-6'


/*
Task 19: Monthly trend of book issues
Why: Understand seasonal demand, marketing strategy planning.
*/
SELECT 
    FORMAT(issued_date, 'yyyy-MM') AS month,
    COUNT(*) AS books_issued
FROM issued_status
GROUP BY FORMAT(issued_date, 'yyyy-MM')
ORDER BY month;

-- Task 20: Identifying books that have never been issued.
SELECT isbn, book_title
FROM books
WHERE isbn NOT IN (SELECT DISTINCT issued_book_isbn FROM issued_status);


-- Task 21: Checking that how effectively each branch utilizes its book inventory.
SELECT 
    b.branch_id,
    COUNT(DISTINCT i.issued_book_isbn) AS books_utilized,
    (SELECT COUNT(*) FROM books) AS total_books,
    ROUND(COUNT(DISTINCT i.issued_book_isbn) * 100.0 / (SELECT COUNT(*) FROM books), 2) AS utilization_percent
FROM branch b
JOIN employees e ON b.branch_id = e.branch_id
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY b.branch_id;


/*
Task 22: Create Table As Select query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/

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

select * from overdue_fines_summary
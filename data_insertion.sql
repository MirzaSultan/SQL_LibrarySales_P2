-- Library Management System Project 2

-- [Creating Tables]

--Brach Table
Drop Table IF EXISTS branch;
Create Table branch
	(
	branch_id varchar(10) PRIMARY KEY,
	manager_id varchar(10),
	branch_address varchar(55),
	contact_no varchar(10)
	);

-- Employees Table
Drop Table IF EXISTS employees;
CREATE TABLE employees
	(
	emp_id	varchar(10) PRIMARY KEY,
	emp_name	varchar(25),
	position	varchar(15),
	salary	INT,
	branch_id	varchar(25)		--FK
	);

-- Books Table
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
	isbn	varchar(20) PRIMARY KEY,
	book_title	varchar(75),
	category	varchar(10),
	rental_price	FLOAT,
	status	varchar(15),
	author	varchar(35),
	publisher varchar(75)
	);

-- Members Table
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
	member_id	varchar(20) PRIMARY KEY,
	member_name	varchar(25),
	member_address	varchar(75),
	reg_date DATE
	);

-- Issued_Status Table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
	issued_id	varchar(10) PRIMARY KEY,
	issued_member_id	varchar(10),	--FK
	issued_book_name	varchar(75),
	issued_date	DATE,
	issued_book_isbn	varchar(25),	--FK
	issued_emp_id	varchar(10)		--FK
	);

-- Return_Status Table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
	return_id	varchar(10) PRIMARY KEY,
	issued_id	varchar(10), --FK
	return_book_name	varchar(75),
	return_date	DATE,
	return_book_isbn	varchar(20)
	);


-- Altering Table Employees Column branch_id
ALTER TABLE employees
ALTER COLUMN branch_id VARCHAR(10);

ALTER TABLE issued_status
ALTER COLUMN issued_member_id VARCHAR(20);

ALTER TABLE issued_status
ALTER COLUMN issued_book_isbn VARCHAR(20);

ALTER TABLE branch
ALTER COLUMN contact_no VARCHAR(25);

ALTER TABLE books
ALTER COLUMN category VARCHAR(25);

--FOREIGN KEY CONSTRAINTS

-- FK Branch_ID Relationship b/w Branch&Employees
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- FK issued_member_id Relationship b/w issued_status&members
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

-- FK issued_book_isbn Relationship b/w issued_status&books
ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

-- FK issued_emp_id Relationship b/w issued_status&employees
ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- FK issued_id Relationship b/w issued_status&return_status
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
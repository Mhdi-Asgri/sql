CREATE TYPE VEHICLE_FUEL AS ENUM ('GASOLINE', 'DIESEL', 'GAS', 'DUAL');
CREATE TYPE Dept_positions AS ENUM ('PROGRAMMER', 'MANAGER', 'NORMAL_EMPLOYEE');
CREATE TYPE PAYMENT AS ENUM ('CASH', 'TRANSACTION');
CREATE TYPE TYPE_TRANSACTION AS ENUM ('WITHDRAW', 'DEPOSIT');
CREATE TYPE FOLLOW AS ENUM ('NOT_YET', 'FOLLOWING', 'FOLLOWED');
CREATE TYPE SERVICE AS ENUM ('BAXI', 'B_BAR', 'B_BOX', 'B_WOMEN');



CREATE TABLE DEPARTMENT(
	Start_date DATE NOT NULL,
	mgr_ssn DECIMAL(10, 0) NOT NULL,
	Dname VARCHAR(50) PRIMARY KEY UNIQUE NOT NULL
);


CREATE TABLE EMPLOYEE (
    ID SERIAL PRIMARY KEY NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL,
	Start_date DATE,
	Profile_pic BYTEA,
	Skill VARCHAR(100) NOT NULL,
	Education VARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
	Position_dept Dept_positions NOT NULL,
	F_name VARCHAR(50) NOT NULL,
	SSN DECIMAL(10, 0) UNIQUE NOT NULL,
	Age INT CHECK (Age >= 18),
	Check_password DATE NOT NULL,
	Shaba DECIMAL(24, 0) NOT NULL,
	Dname VARCHAR(50) NOT NULL,
);

ALTER TABLE DEPARTMENT 
ADD FOREIGN KEY (mgr_ssn) REFERENCES EMPLOYEE(SSN);

CREATE TABLE PASSENGER(
    ID SERIAL PRIMARY KEY NOT NULL,
	F_name VARCHAR(50) NOT NULL,
	L_name VARCHAR(50) NOT NULL,
    Sex CHAR(1) CHECK (Sex IN ('m', 'f')) NOT NULL,
	Phone_number DECIMAL(10, 0) UNIQUE NOT NULL,
	Age INT,
	Reg_date DATE NOT NULL, 
	Email VARCHAR(100)
);


CREATE TABLE CHECK_INF(
	Reg_License_Date DATE NOT NULL,
	SSN_pic BYTEA NOT NULL,
	Issuing_The_Certificate DATE NOT NULL,
	Car_Card_pic BYTEA NOT NULL,
	Criminal_Record BYTEA NOT NULL,
	License_pic BYTEA NOT NULL,
	CheckForShaba BOOLEAN NOT NULL,
	CheckForSSN BOOLEAN NOT NULL,
	CheckCarCard BOOLEAN NOT NULL,
	checkForCertificate BOOLEAN NOT NULL,
	ChechForCriminal_Record BOOLEAN NOT NULL,
	Employee_ID INT NOT NULL,
	Driver_ID SERIAL PRIMARY KEY NOT NULL,
	FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEE(SSN)
);



CREATE TABLE Driver(
    ID INT UNIQUE NOT NULL,
    F_name VARCHAR(50) NOT NULL,
    L_name VARCHAR(50) NOT NULL,
	Profile_pic BYTEA NOT NULL,
	Shaba DECIMAL(24, 0) NOT NULL,
	Disability CHAR(250),
	Approval_date DATE NOT NULL,
	SSN DECIMAL(10, 0) UNIQUE NOT NULL,
	Certificateـnumber DECIMAL(10, 0) UNIQUE NOT NULL,
	Age INT CHECK (Age >= 18),
    Sex CHAR(1) CHECK (Sex IN ('m', 'f')) NOT NULL,
	Phone_number DECIMAL(10, 0) UNIQUE NOT NULL,
	Fuel_quota DECIMAL(3, 2) CHECK (Fuel_quota >= 0),
	Driver_Location VARCHAR(100) NOT NULL,
	service_type SERVICE NOT NULL,
	Latitude DOUBLE PRECISION,
    Longitude DOUBLE PRECISION
	FOREIGN KEY (ID) REFERENCES CHECK_INF(Driver_ID) ON DELETE CASCADE
);


CREATE TABLE VEHICHLE(
	Plaque VARCHAR(8) PRIMARY KEY UNIQUE NOT NULL,
	Driver_ID INT UNIQUE NOT NULL,
	Year INT NOT NULL,
	Capacity FLOAT NOT NULL,
	Name CHAR(20) NOT NULL,
	FOREIGN KEY (Driver_ID) REFERENCES Driver(ID) ON DELETE CASCADE
);

CREATE TABLE TRUCK(
	Plaque VARCHAR(8) NOT NULL,
	Color CHAR(10) NOT NULL,
	Type_Fuel VEHICLE_FUEL,	
	FOREIGN KEY (Plaque) REFERENCES VEHICHLE(Plaque) ON DELETE CASCADE
);

CREATE TABLE CAR(
	Plaque VARCHAR(8) NOT NULL,
	Color CHAR(10) NOT NULL,
	Type_Fuel VEHICLE_FUEL,
	FOREIGN KEY (Plaque) REFERENCES VEHICHLE(Plaque) ON DELETE CASCADE
);


CREATE TABLE MOTOR(
	Plaque VARCHAR(8) NOT NULL,
	FOREIGN KEY (Plaque) REFERENCES VEHICHLE(Plaque) ON DELETE CASCADE
);



CREATE TABLE TRIP(
	Trip_ID SERIAL PRIMARY KEY UNIQUE NOT NULL,
	Trip_Date DATE NOT NULL,
	Time_start TIME NOT NULL,
	Distance DECIMAL(10, 2), --km
	Wait_time TIME NOT NULL DEFAULT '00:05:00',
	Start_location VARCHAR(100) NOT NULL,
	Time_end TIME,
	Canceled BOOLEAN NOT NULL DEFAULT FALSE,
	Driver_ID INT NOT NULL,
	User_ID INT NOT NULL,
	FOREIGN KEY (User_ID) REFERENCES PASSENGER(ID),
	FOREIGN KEY (Driver_ID) REFERENCES Driver(ID)
);

CREATE TABLE Trip_load(
	Trip_ID INT NOT NULL,
	Destination VARCHAR(100) NOT NULL,
	Help BOOLEAN NOT NULL,
	StuffـValue DECIMAL(10, 2) NOT NULL,
	Weight Decimal(10, 2),
	Breakable BOOLEAN NOT NULL DEFAULT FALSE,
	FOREIGN KEY (Trip_ID) REFERENCES TRIP(Trip_ID) ON DELETE CASCADE
);

CREATE TABLE Trip_person(
	Trip_ID INT UNIQUE NOT NULL,
	Destination VARCHAR(100) NOT NULL,
	FOREIGN KEY (Trip_ID) REFERENCES TRIP(Trip_ID) ON DELETE CASCADE
);


CREATE TABLE Baxi_Wallet(
	T_Date DATE NOT NULL,
	Amount DECIMAL(10, 2) NOT NULL,
	Status BOOLEAN, -- DONE:TRUE, FAILED: FALSE
	Payed BOOLEAN NOT NULL, -- PAYED:TRUE, NOT_PAYED: FALSE
	T_Time TIME NOT NULL,
	Trip_ID INT NOT NULL,
	Driver_ID INT NOT NULL,
	FOREIGN KEY (Trip_ID) REFERENCES TRIP(Trip_ID),
	FOREIGN KEY (Driver_ID) REFERENCES Driver(ID)
);



CREATE TABLE UserToDriverTransaction(
	User_ID INT NOT NULL,
	Driver_ID INT NOT NULL,
	Trip_ID INT NOT NULL,
	Amount DECIMAL(10, 2) NOT NULL,
	T_Date DATE NOT NULL,
	Transaction_Time TIME NOT NULL,
    Pay_type PAYMENT NOT NULL DEFAULT 'TRANSACTION',
	Status BOOLEAN, -- DONE:TRUE, FAILED: FALSE
	FOREIGN KEY (Trip_ID) REFERENCES TRIP(Trip_ID),
	FOREIGN KEY (User_ID) REFERENCES PASSENGER(ID),	
	FOREIGN KEY (Driver_ID) REFERENCES Driver(ID)
);


CREATE TABLE User_Transaction(
	User_ID INT NOT NULL,
	Amount DECIMAL(10, 2) NOT NULL,
	Transaction_Date DATE NOT NULL,
	Transaction_Time TIME NOT NULL,
	Status BOOLEAN NOT NULL, -- DONE:TRUE, FAILED: FALSE
	FOREIGN KEY (User_ID) REFERENCES PASSENGER(ID) ON DELETE CASCADE
);



CREATE TABLE Driver_Transaction(
	Driver_ID INT NOT NULL,
	Transaction_Type TYPE_TRANSACTION NOT NULL,
	Amount DECIMAL(10, 2) NOT NULL,
	T_Date DATE,
	Transaction_Time TIME,
	Status BOOLEAN NOT NULL, -- DONE:TRUE, FAILED: FALSE
	FOREIGN KEY (Driver_ID) REFERENCES Driver(ID) ON DELETE CASCADE
);

CREATE TABLE BLACK_LIST(
	SSN DECIMAL(10, 0) UNIQUE NOT NULL,
	FOREIGN KEY (SSN) REFERENCES Driver(SSN)
);

CREATE TABLE Violation(
	Follow_up FOLLOW NOT NULL DEFAULT 'NOT_YET',
	REPORT TEXT,
	T_ID INT NOT NULL,
	FOREIGN KEY (T_ID) REFERENCES TRIP(Trip_ID)
);

CREATE TABLE ADDRESS(
	User_ID INT not null,
	Address VARCHAR(100) not null,
	FOREIGN KEY (User_ID) REFERENCES PASSENGER(ID) ON DELETE CASCADE
);


CREATE TABLE User_Point(
	Points INT CHECK (Points >= 0 AND Points <= 5) NOT NULL,
	ID INT NOT NULL,
	Description TEXT,
	FOREIGN KEY (ID) REFERENCES Trip(Trip_ID) ON DELETE CASCADE
);



CREATE TABLE Driver_Point(
	Points INT CHECK (Points >= 0 AND Points <= 5),
	ID INT,
	FOREIGN KEY (ID) REFERENCES Trip(Trip_ID) ON DELETE CASCADE
);


CREATE TABLE Driver_Wallet(
	ID INT NOT NULL,
	Balance DECIMAL(12, 2) NOT NULL CHECK (Balance >= -50000),
	FOREIGN KEY (ID) REFERENCES Driver(ID) 
);

CREATE TABLE User_Wallet(
	ID INT NOT NULL,
	Balance DECIMAL(12, 2) NOT NULL CHECK (Balance >= 0) NOT NULL,
	FOREIGN KEY (ID) REFERENCES PASSENGER(ID)
);







CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT NOW(),
    id INT,  -- Store the username (if available)
    action VARCHAR(10) NOT NULL,  -- 'INSERT', 'UPDATE', or 'DELETE'
    table_name VARCHAR(50) NOT NULL,
	modified_by VARCHAR(50) NOT NULL
);




CREATE TABLE Subset(
	Inviter INT NOT NULL,
	Invited INT NOT NULL,
	FOREIGN KEY (Inviter) REFERENCES Driver(ID) ON DELETE CASCADE,
	FOREIGN KEY (Inviter) REFERENCES Driver(ID) ON DELETE CASCADE
);




CREATE TABLE monthly_payment (
    F_name VARCHAR(50) NOT NULL,
    L_name VARCHAR(50) NOT NULL,
    pay_date DATE DEFAULT CURRENT_DATE,
	Amount DECIMAL(10,2) NOT NULL,
	ID INT NOT NULL,
	FOREIGN KEY (ID) REFERENCES Driver(ID) ON DELETE CASCADE
);
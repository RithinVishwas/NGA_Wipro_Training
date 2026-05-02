use DemoDB;

CREATE TABLE Employees
(
    EmpID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Salary INT
);
INSERT INTO Employees VALUES (1, 'John', 'Doe', 'IT', 50000);
INSERT INTO Employees VALUES (2, 'Jane', 'Smith', 'HR', 60000);
INSERT INTO Employees VALUES (3, 'Amit', 'Sharma', 'IT', 80000);
INSERT INTO Employees VALUES (4, 'Sara', 'Khan', 'Finance', 75000);

SELECT * FROM Employees;

--Sclar Function
CREATE FUNCTION dbo.GetAnnualSalary (@Salary INT)
RETURNS INT
AS
BEGIN
    RETURN @Salary * 12;
END;

SELECT EmpID, FirstName, Salary,
       dbo.GetAnnualSalary(Salary) AS AnnualSalary
FROM Employees;

---TVF
CREATE FUNCTION dbo.GetEmployeesBySalary (@MinSalary INT)
RETURNS TABLE
AS
RETURN
(
    SELECT EmpID, FirstName, Salary
    FROM Employees
    WHERE Salary > @MinSalary
);

SELECT * FROM dbo.GetEmployeesBySalary(60000);


--Multi TVF
CREATE FUNCTION dbo.GetITEmployees()
RETURNS @Result TABLE
(
    EmpID INT,
    Name VARCHAR(50),
    Salary INT
)
AS
BEGIN
    INSERT INTO @Result
    SELECT EmpID, FirstName, Salary
    FROM Employees
    WHERE Department = 'IT';

    RETURN;
END;

SELECT * FROM dbo.GetITEmployees();


-----------------Display all three functions ------------------------------

SELECT EmpID, FirstName, Salary,
       dbo.GetAnnualSalary(Salary) AS AnnualSalary
FROM Employees;

SELECT * 
FROM dbo.GetEmployeesBySalary(60000);

SELECT * 
FROM dbo.GetITEmployees();








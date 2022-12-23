Create or alter function fnCalculatorDesi (@en float, @boy float, @yukseklik float)
Returns float
As
Begin
	declare @result float;
	Select @result = @en*@boy*@yukseklik/3000

Return @result
End
Go
select dbo.fnCalculatorDesi(10.1,25.3,47.3)
Go

Create or alter procedure spAddEmpTer(@EmpID int, @TerID nvarchar(20))
AS 
insert into EmployeeTerritories Values (@EmpID, @TerID)
go

Create or alter trigger trgInsertValue ON EmployeeTerritories After Insert 
As
Declare @emp_id int, @ter_id nvarchar(20), @c int
Select @emp_id= EmployeeID, @ter_id = TerritoryID From inserted
Select @c = COUNT(TerritoryID) from EmployeeTerritories where EmployeeID = @emp_id 

if(@c - 1) = 10
begin
rollback
raiserror('Sýnýra ulaþýldý (%d) ', 15, 1,@emp_id)
end
if EXISTS (select * from EmployeeTerritories where TerritoryID = @ter_id)
Begin
rollback
raiserror('(%s) numaralý bölge var kardeþim bak iþine ', 15, 1,@ter_id)
end
Go

exec dbo.spAddEmpTer 7, '06897'
Go

Create or alter view vwSupplier 
as 
	Select sp.CompanyName as companyName,
	Count(P.ProductID) as totalProduct
	from Products P 
	inner join Suppliers sp on sp.SupplierID = P.SupplierID
	Group By sp.CompanyName
Go

select * from dbo.vwSupplier
go
/*
create procedure spAddOrderDetails(@OrderID INT, @ProductID INT, @UnitPrice MONEY, @Quantity SMALLINT, @Discount REAL)
as
declare @unitInStock int=( select UnitsInStock from Products where ProductID =@ProductID)
if @unitInStock>= @Quantity
begin
insert  into [Order Details] values (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount)
update p
*/
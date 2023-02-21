Use Northwind
Go
Select * from dbo.Orders

Select ROW_NUMBER() Over(Partition By Country Order By City Desc) As Satir_no,
country, City, CompanyName
From dbo.Customers

--IDs of top selling sellers in each country
Select * From
(
Select O.OrderID,
CustomerID,
EmployeeID,
ShipCountry,
Sum(UnitPrice * Quantity) AS Ciro,
ROW_NUMBER() Over(Partition By ShipCountry Order By Sum(UnitPrice*Quantity) DESC) As Satir_No
From dbo.[Order Details] OD Inner join Orders O ON O.OrderID = OD.OrderID
Group By
O.OrderID, CustomerID, EmployeeID, ShipCountry
) Satislar
Where Satir_No = 1
Go

-- Carpma iþlemi yapan fonksiyon
Create Or Alter Function carpmaIslemi (@sayi1 INT, @sayi2 INT = 10)
Returns INT
AS 
Begin
	Declare @result INT;
	Select @result = @sayi1 *@sayi2
	
	Return @result
End
Go

Select dbo.carpmaIslemi(5,6) carpim1, dbo.carpmaIslemi(5, Default)

-- Function that checks odd, even and zero
Go

-- Girilen sayinin tek, çift veya sifir mi olduðunu kontrol eden fonksiyon
Create or Alter Function tek_cift_sifir(@number1 INT)
Returns Varchar(50)
AS
Begin
	Declare @state Varchar(50);
	if(@number1 % 2 = 0 And @number1 <> 0)
		select @state = 'number1 çift sayidir';
	
	Else if(@number1 % 2 = 1)
		select @state = 'number1 tek sayidir';

	else
		select @state = 'number1 sifirdir';

return @state
End
Go
Select dbo.tek_cift_sifir(5), dbo.tek_cift_sifir(2), dbo.tek_cift_sifir(0)
Go

-- -- Function that returns the date of employment of the personnel whose ID information is given, in years

Create OR Alter function personelHireDate (@empID INT)
Returns INT
As
Begin
	Declare @HireDate_Year INT;
	Select @HireDate_Year = YEAR(HireDate) From Employees 
	Where EmployeeID = @empID

Return @HireDate_Year
End
Go

Select FirstName +' '+ LastName AS Name_Surname,
		dbo.personelHireDate(EmployeeID) Hire_Date_Year
		From Employees

Go

 -- Function that gives the name and surname (adjacent), age and duration of employment of the personnel in the desired country
 Create or Alter Function personelInfo (@country VARCHAR(50))
 Returns table As
 Return
	(Select FirstName + ' ' + LastName AS Ad_Soyad,
			DATEDIFF(YEAR, BirthDate, GETDATE()) AS Yas,
			DATEDIFF(YEAR, HireDate, GETDATE()) AS sure
	From Employees
	Where Country = @country
	)
Go

Select * From dbo.personelInfo('USA')

Go

-- Function that returns the product name, unit price and quantity received in the last order of the given customer
Create or alter Function fncSonTeslim(@cusID AS NCHAR(10))
Returns @tableSip Table(urun_adi Varchar(50), birimFiyat money, miktar smallint)
AS
Begin
	Declare @maxTarih DATETIME

	Select @maxTarih = MAX(OrderDate) 
	From Orders 
	where CustomerID = @cusID

	Insert @tableSip
	Select P.ProductName, OD.UnitPrice, OD.Quantity
	From Orders O 
	inner join [Order Details] OD ON OD.OrderID = O.OrderID
	inner join Products P ON P.ProductID = OD.ProductID
	Where O.OrderDate = @maxTarih and O.CustomerID = @cusID
Return
End
Go

Select * From dbo.fncSonTeslim('VINET')
Go

-- View Example --
Create or Alter View view_calisanOzet As
	select FirstName + ' ' + LastName As name_surname,
			DATEDIFF(YEAR, HireDate, GETDATE()) As Yasi,
			DATEDIFF(YEAR, BirthDate, GETDATE())AS dogumTarihi
	From Employees
Go
Select * from dbo.view_calisanOzet
Go

Create or alter view view_GenelSatislar
AS
	Select C.customerID AS CHK,
		Convert(Char(10), OrderDate, 103) AS siparisTarihi,
		Convert(Char(10), ShippedDate, 103)AS TeslimTarihi,
		ISNULL(C.Region, 'Belirsiz') AS MusteriBolgesi,
		OD.UnitPrice * OD.Quantity AS Tutar,
		CASE 
			When Freight <= 30 Then 'Hafif'
			When Freight <= 50 Then 'Orta'
			Else 'Agir'
		End AS Tonaj,
		E.title + ' ' + E.firstName + ' ' + E.LastName AS Satici
	From Orders O
	inner join [Order Details] OD ON OD.OrderID = O.OrderID
	inner join Customers C ON c.CustomerID = O.CustomerID
	inner join Employees E On E.EmployeeID = O.EmployeeID
Go
Select * From view_GenelSatislar Where CHK = 'VINET'
Go


-- Creating Standart Procedur
Create or alter Procedure spTumMusteriler AS
	Select * from Customers
Go

-- Calling Standart Procedur
spTumMusteriler
Exec spTumMusteriler
Go

-- Query fetching n randomly selected customers each time called
Create or alter Procedure spKarisikMusteri(@n INT) AS
	Select Top (@n) * From Customers Order By NEWID()
Go

Exec spKarisikMusteri 5
Go

IF OBJECT_ID('spBelirliMusteri') IS NOT NULL
Begin
	Drop Procedure spBelirliMusteri
End
Go

-- Procedur, which fetches the specific customer's information
Create or alter procedure spBelirliMusteri(@musteri_id NCHAR(5) = 'ANTON') 
AS
	Select * From Customers Where CustomerID = @musteri_id
Go
Exec spBelirliMusteri 'VINET'
Exec spBelirliMusteri Default
Go

-- If the customer ID is not given, we can write an SP that brings all customers, 
-- and if so, only the customer whose ID is given

Create or alter procedure spMusteri(@musteri_id NCHAR(5) = Null)
AS
	Select * From Customers Where CustomerID = ISNULL(@musteri_id, CustomerID)
Go
Exec spMusteri 'VINET'
Exec spMusteri
Go

-- If the customer ID is not given, we can write an SP that brings all customers, 
-- and if so, only the customer whose ID and city are given

Create or alter procedure spMusteriler(@sehir NVARCHAR(15) = Null, @address NVARCHAR(60) = null)
AS
	Select * From Customers
	Where 
		City = ISNULL(@sehir,City)
		And Address Like '%' + ISNULL(@address, Address) +'%'
Go
Exec spMusteriler 'London'
Exec spMusteriler 'London', 'ge'
Go
/* In the SPs created so far, we have only used input parameters. But sometimes SP has one or more 
we can also ask for value rotation. In this case, output parameters are used. Unless otherwise specified 
parameters are treated as input by SQL.*/

Create or alter procedure spMusterilerOut(@sehir NVARCHAR(15) = Null, @adres NVARCHAR(60) = Null, @RowCounter INT OUTPUT)
As
	Select * From Customers
	Where City = ISNULL(@sehir,City)
	And
	Address Like '%' + ISNULL(@adres,Address) + '%'

	Select @RowCounter = @@ROWCOUNT
Go
Declare @finderCount INT
Exec spMusterilerOut 'London', Null, @finderCount OUTPUT
Select @finderCount

-- Select Count(CustomerID) from Customers where Fax IS NULL
Go

Create or alter procedure spReturnOrnegi(@s1 int,@s2 int, @s int OUTPUT)
As
	Set @s = @s1 + @s2
	Return @s1 * @s2
Go

Declare @toplam int, @carpma int
Exec @carpma = spReturnOrnegi 8 ,5, @toplam Output
Select @toplam, @carpma
Go

-- Procedur, which fetches the table
-- If there is more than one select statement in the SP, 
-- the results are added one after the other as if Union All was made.

Create or alter procedure spTabloTipliDegisklenOrnegi
AS
Select FirstName, LastName, ReportsTo from Employees
Select Address, City, 100 From Employees Where FirstName = 'Nancy'
--Select FirstName, LastName, ReportsTo From Employees Where FirstName = 'Nancy'
Go

Declare @sonuclar Table(AD Varchar(50), Soyad Varchar(50), Amiri INT)
Insert Into @sonuclar Exec spTabloTipliDegisklenOrnegi

Select * From @sonuclar
Go

-- If we wanna solving this problem
create or alter procedure spResultSetOrnegi
AS
	Select 'Dear' +' '+ Title, FirstName, LastName  From Employees
	--Select ProductName, UnitPrice, UnitsInStock From Products where UnitPrice >20 Order By UnitPrice DESC
	Select ProductName, 
	UnitPrice, 
	'Last ' + Convert(varchar(10) ,UnitsInStock) + ' products left',
	Case 
	When UnitPrice <= 20 Then 'under 20$'
	When UnitPrice <= 50 and UnitPrice > 20 Then 'best selling'
	Else 'Elegant'
	End
	From Products
	Order By UnitPrice Desc
Go
Exec spResultSetOrnegi With Result Sets
(
(Unvan Varchar(100) ,Ad Varchar(10), Soyad Varchar(10) )
--(Unvan Varchar(100) ,Ad Varchar(10), Soyad Varchar(10) ) --First Result
,
(UrunAdi Varchar(50), Birim_Fiyat INT, UnitsInStock varchar(50), UrunDurumu Varchar(20) ) --Second Result
)
Go

Select top 1 ProductName, UnitPrice
	from Products 
	order by UnitPrice desc

Go



Create Type typSatisEkibi As Table
(
	saticiID int,
	AdSoyad Varchar(50)
)
Go


Create or alter procedure spSatisRaporu(@saticilar AS typSatisEkibi Readonly)
As
Begin
Set NOCOUNT ON
	SELECT S.adsoyad,
		C.companyName,
		Sum(O.freight)
	From Orders O
		inner join Customers C ON C.CustomerID = O.CustomerID
		inner join @saticilar S ON S.saticiID = O.EmployeeID
	Group BY S.AdSoyad, C.CompanyName
	Set Nocount off
End
Go

Declare @satis_elemanlari AS typSatisEkibi
Insert Into @satis_elemanlari Select EmployeeID, FirstName + ' ' +LastName from Employees
Select * From @satis_elemanlari
Exec spSatisRaporu @satis_elemanlari
Go

If OBJECT_ID('RegionTablosuLoglari') IS NOT NULL
	Drop Table RegionTablosuLoglari
Go

Create Table RegionTablosuLog
(
	id INT NOT NULL IDENTITY(1,1) Primary Key,
	tarih_saat datetime,
	islem Varchar(10) NOT NULL,
	yeni_deger Varchar(50),
	eski_deger Varchar(50)
)
Go
Insert into Region
Output GETDATE(), 'Insert', inserted.RegionDescription, null Into RegionTablosuLog
Values(5,'Test')
Go

Select * from Region
select * from RegionTablosuLog
Go 

Update Region
Set RegionDescription='NONE'
Output GETDATE(), 'Update', inserted.RegionDescription, deleted.RegionDescription
into RegionTablosuLog
Where RegionDescription = 'Test'
Go

Select * From Region
Select * From RegionTablosuLog
Go


Delete From Region
Output GETDATE(), 'Delete', Null, deleted.RegionDescription
into RegionTablosuLog
Where RegionDescription = 'NONE'
Go

Select * From Region
Select * From RegionTablosuLog
Go

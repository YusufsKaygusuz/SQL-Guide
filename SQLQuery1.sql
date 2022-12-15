Use Northwind
Go
Select * from dbo.Orders

Select ROW_NUMBER() Over(Partition By Country Order By City Desc) As Satir_no,
country, City, CompanyName
From dbo.Customers

--Herbir ülkedeki en yüksek satýþý yapan satýcýlarýn ID leri
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

-- Tek, çift ve sifir kontrolü yapan fonksiyon
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

-- ID bilgisi verilen personelin yýl olarak iþe giriþ tarihini dönen fonksiyon

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

 -- Ýstenen ülkedeki personellerin adý ve soyadý (bitiþik), yaþý ve çalýþtýðý süreyi veren fonksiyon
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

--Verilen müþterinin en son sipariþindeki ürün adý, birim fiyatý ve alýnan miktarý getiren fonksiyon
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
Create Procedure spTumMusteriler AS
	Select * from Customers
Go

-- Calling Standart Procedur
spTumMusteriler
Exec spTumMusteriler
Go

-- Query fetching n randomly selected customers each time called
Create Procedure spKarisikMusteri(@n INT) AS
	Select Top (@n) * From Customers Order By NEWID()
Go

Exec spKarisikMusteri 5
Go

-- Procedur, which fetches the specific customer's information
Create or alter procedure spBelirliMusteri(@musteri_id NCHAR(5) = 'ANTON') 
AS
	Select * From Customers Where CustomerID = @musteri_id
Go
Exec spBelirliMusteri 'VINET'
Exec spBelirliMusteri Default

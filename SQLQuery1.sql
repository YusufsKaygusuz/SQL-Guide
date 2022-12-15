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

/* Homework
Use randevu_sistemi
Select * from dbo.tblHasta

IF OBJECT_ID ('dbo.fn_toplam_doktor') IS Not null
Begin
	drop function fn_toplam_doktor
End

Go
-- Hastane idsi verilen hastanenin çalýþan doktor sayýsýný dönen fonksiyon
Create or alter function fn_toplam_doktor(@hastane_id int)
Returns int
AS
Begin
	declare @totalDoctor int;
	Select @totalDoctor = Count(DoktorID) From dbo.tblHastane
	where tblHastane.ID = @hastane_id

	return @totalDoctor
End
Go
Select dbo.fn_toplam_doktor(5)
Go

-- Herhangi bir hastaneye ait bilgileri getiren View
Create or alter View hastane_bilgileri
As
	Select HST.Ad as hastane_adi,
	Convert(Char(15), kurulus_tarihi, 103) as hastane_kurulusu,
	dbo.fn_toplam_doktor(5) as toplam_doktor_sayisi,
	Case
	When YEAR(kurulus_tarihi) <= 1990 Then 'Çok Eski'
	When Year(kurulus_tarihi) > 1990 and Year(kurulus_tarihi)<= 2000 Then 'Eski'
	Else 'Yeni'
	End As yeni_eski,
	Shr.AD As sehir_adi,
	HST.HastaneTipiID AS hastane_Tipi,
	ROW_NUMBER() Over (Partition By Shr.AD Order By kurulus_tarihi DESC) As sehir_bazinda_hastane_sayilari
 
	from TblHastane HST
		inner join TblDoktor DR ON DR.ID = HST.DoktorID
		inner join TblSehir Shr ON Shr.ID = HST.SehirID
Go
Select hb.hastane_adi,
httip.AD As hastane_tipi,
yeni_eski,
sehir_adi,
sehir_bazinda_hastane_sayilari
from hastane_bilgileri as hb
	inner join TblHastaneTipi as httip ON httip.ID = hb.hastane_Tipi

*/



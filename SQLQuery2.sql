-- Query that raises products by 5% until the average product price in the dairy
--category is 50 or more
Declare @counter int =0
Declare @avgPrice Float

Select @avgPrice = AVG(P.UnitPrice)
From Products P 
inner join Categories C ON C.CategoryID = P.CategoryID
Where C.CategoryName = 'Dairy Products'

While @avgPrice < 50
Begin
	Update Products
	Set UnitPrice *=1.05
	From Products P 
inner join Categories C ON C.CategoryID = P.CategoryID
Where C.CategoryName = 'Dairy Products'

Select @avgPrice = AVG(P.UnitPrice)
From Products P 
inner join Categories C ON C.CategoryID = P.CategoryID
Where C.CategoryName = 'Dairy Products'

Set @counter +=1
End

Select @avgPrice AS last_avg_price, @counter AS Sayac


--Show the total and average sales in the desired year on the basis of product or category according
--to the parameter given in a procedure using the money symbol

Go
Create or alter view vwSiparisDetay As
Select OrderID AS siparisID, ProductID As UrunID, 
Quantity*UnitPrice - OD.Discount AS NetTutar
From [Order Details] OD
Go
Select * from dbo.vwSiparisDetay
Go

Create or alter Procedure spUrunKategoriSatislari (@yil int, @sorguNo int = 1)
As
Set Nocount on
If (@sorguNo = 1)
Begin
	Select P.ProductName,
	Format(Sum(SD.NetTutar), 'c', 'en-us') AS totalSelling,
	FORMAT(AVG(SD.NetTutar), 'c', 'en-us') AS averageSelling

	From Orders O 
	inner join vwSiparisDetay SD ON SD.siparisID = O.OrderID
	inner join Products P ON P.ProductID = SD.UrunID

	Where Year(O.OrderDate) = @yil

	Group By p.ProductName
	Order BY P.ProductName
End
Else if (@sorguNo = 2)
Begin
	Select C.CategoryName,
	Format(Sum(SD.NetTutar), 'c', 'en-us') AS totalCSelling,
	Format(AVG(SD.NetTutar), 'c', 'en-us') AS averageCSelling

	From Orders O 
	inner join vwSiparisDetay SD ON SD.siparisID = O.OrderID
	inner join Products P ON P.ProductID = SD.UrunID
	inner join Categories C ON C.CategoryID = P.CategoryID

	Where Year(O.OrderDate) = @yil
	
	Group By C.CategoryName
	Order By C.CategoryName
End
Set nocount off
Go

Exec spUrunKategoriSatislari 1997,1
Exec spUrunKategoriSatislari 1997,2
Go

Create or alter view vwSevkiyatCalisma
AS
	Select S.CompanyName AS sevkiyatciFirma,
	Count(*) As calismaSayisi
	From Orders O inner join Shippers S On S.ShipperID = O.ShipVia
	Group By S.CompanyName
Go
Select * From vwSevkiyatCalisma
Go


Select COUNT(*) AS BeforeTransaction From Region
Declare @hata INT

Begin Transaction
Insert Region Values(5, 'Test')
Set @hata = @@ERROR
IF @hata<>0 GOTO Hata_Duzeltme
Select COUNT(*) As MiddleTransaction, @hata AS HataKodu From region

Insert Region Values(5,'Test') --PK Hatasý
Set @hata = @@ERROR
IF @hata<>0 Goto Hata_Duzeltme
Commit

Hata_Duzeltme:
Select @@ERROR AS HataKodu
IF @hata<>0
Begin
Rollback
End

Select COUNT(*) AS AfterTransaction, @hata As HataKodu From Region


--Delete From Region where RegionID = 5
--Select * from Region

Select COUNT(*) AS BeforeTransaction From Region
Declare @Hata2 int

Begin Transaction
Insert Region Values(5,'Test')
Set @Hata2 = @@ERROR
IF @Hata2<> 0 Goto hata_duzeltme
Select COUNT(*) As CenterTransaction, @Hata2 AS hataKodu From Region
Save Tran Check_Point

Insert Region Values(5,'Test') -- Error of Primary Key
Set @Hata2 = @@ERROR
IF @Hata2<> 0 Goto hata_duzeltme
Commit

hata_duzeltme:
If @Hata2 <> 0
Begin 
IF XACT_STATE()<>-1
Begin
	Rollback Tran Check_Point
	Commit
	Print 'It have been come back to checkpoint'
	End
Else
Rollback
End

--Introduction to Trigger --
/*
Select COUNT(*) As AfterTransaction, @Hata2 AS HataKodu From Region

--Delete From Region where RegionID = 5
--Select * from Region

IF OBJECT_ID('ConstBakiye', 'D') IS NOT NULL  --D : Default Constraint
	Alter Table Customers Drop Constraint ConstBakiye
Go

IF Col_Length('Customers', 'Bakiye') IS NOT NULL
	Alter Table Customers Drop Column Bakiye
Go

IF Col_Length('Customers', 'CreatedDate') IS NOT NULL
	Alter Table Customers Drop Column CreatedDate
Go

IF Col_Length('Customers', 'ModifiedDate') IS NOT NULL
	Alter Table Customers Drop Column ModifiedDate
Go

Alter Table Customers Add Bakiye Money Constraint ConstBakiye Default 0 with values
Go

Alter Table Customers Add CreatedDate DateTime
Go 

Alter Table Customers Add ModifiedDate DateTime
Go

Create Trigger trgCustomersInsert ON Customers After Insert
As
	Declare @MusID Nchar(5) = (Select CustomerID From inserted)
	Alter Table Customers Disable Trigger trgCustomersUpdate
	
	Update Customers Set CreatedDate = GETDATE() Where CustomerID = @MusID
	
	Alter Table Customers Enable Trigger trgCustomersUpdate
	Go

Create Trigger trgCustomersUpdate ON Customers After Update
As
	Declare @MusID Table (ID Nchar(5)) -- More one data may be updated in same time So we shall use table
	Insert Into @MusID Select CustomerID From inserted

	IF UPDATE(CustomerID)
		Begin
			Raiserror ('!!! Customer ID do not update. Update was cancelled',16,1 )
			Rollback
		End
	Else
		Update Customers Set ModifiedDate = GETDATE() Where CustomerID IN (Select ID From @MusID)
Go

	Create Trigger trgCustomerDelete ON Customers After Delete
	AS
		Insert Into CustomersDeleted Select *, GETDATE() From deleted
Go
*/
Go

Create table DeletedValuesTable
(
	ID int,
	Description Varchar(10),
	DeletedDate DateTime
)

IF OBJECT_ID('trgRegionDeleted') IS NOT NULL
Drop Trigger trgRegionDeleted
Go

Create or alter Trigger trgRegionDelete ON Region After Delete
As
	Insert into DeletedValuesTable Select *, GETDATE() From deleted
Go

Create or alter Trigger trgRegionUpdate ON Region After Update
As 
	Declare @InsertRegionID Table(id INT)
	insert into @InsertRegionID Select RegionID From inserted

	IF Update(RegionID)
		Begin
			Raiserror('Customer ID does not updated So updated was cancalled.',16,1)
			Rollback
		End
	Else
		Update Region Set RegionDescription= ' ' + CONVERT(Varchar(20), GetDate()) 
		Where RegionID IN (Select id From @InsertRegionID)
Go

Insert Into Region Values(5,'Test1')
Select * From Region
Insert Into Region Values(6,'Test2')
Select * From Region
--update Region set RegionID = 7 where RegionID=5
Select * From Region
update Region set RegionDescription = 'Test_5' where RegionID = 5 
Select * From Region
Go

Select * From Region
Delete From Region Where RegionID IN (5,6)
Select * From Region
Select * From DeletedValuesTable Order By ID Asc

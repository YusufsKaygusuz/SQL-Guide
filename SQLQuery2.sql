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


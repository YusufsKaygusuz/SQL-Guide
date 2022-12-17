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

/*
Write a FUNCTION and it will return the most ordered product (ProductId) in number (quantity)
for the given year. When the year information is given as 0 (zero), it returns the most ordered product of all time.
*/

Create or alter function fn_yil_urun(@year int)
Returns int as
Begin
Declare @proID int;
if @year = 0
Begin
	Select @proID  = (Select Top 1 OD.productID
				From [Order Details] OD inner join Orders O
				ON O.orderID = OD.OrderID
				Group By OD.productID
				Order By Sum(OD.Quantity) Desc
				)
End
Else
Begin
	Select @proID = (Select Top 1 OD.ProductID
		From [Order Details] OD inner join Orders O 
			ON OD.orderID = O.orderID
			Where Year(O.Orderdate) = @year
			Group By OD.productID
			Order By Sum(OD.Quantity) Desc
			)
End
Return @proID
End
Go

Select dbo.fn_yil_urun(1996)
Select dbo.fn_yil_urun(0)
Go

/*
Write a FUNCTION, and those who get the product whose ProductID is given will return the product they bought the most together.
*/
Create or alter function fn_ikinci_urun(@proID int)
Returns int as
Begin
Declare @result int;
Select @result = ProductID
From [Order Details] OD1
Where OD1.OrderID IN (Select O.OrderID
					From [Order Details] OD inner join Orders O
					On O.orderID = OD.OrderID
					Where OD.ProductID = @proID)
And productID <> @proID
Group By ProductID
Order By Sum(Quantity) ASC
Return @result
End


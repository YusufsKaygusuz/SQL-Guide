CREATE TABLE tblKullanici_
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(50) NOT NULL,
	Soyad VARCHAR(50) NOT NULL,
	DogTrh DATE NOT NULL,
	Yas AS DATEDIFF(yy, DogTrh, GETDATE()),
	IlkOlcumTarihi DATE, -- Ýlk ölçülen kilo deðerinin girildiði tarih
	BaslangicAgirlik FLOAT, -- Ýlk ölçülen kilogram deðeri
	SonOlcumTarihi DATE, -- En son ölçülen kilogram deðerinin girildiði tarih
	MevcutAgirlik FLOAT, -- En son ölçülen kilogram deðeri		
	HedefAgirlik FLOAT NOT NULL, -- Kullanýcýnýn hedeflediði kilogram deðeri
	Boy FLOAT NOT NULL, -- CM olarak girilir
	KullaniciTipi TINYINT NOT NULL DEFAULT 0 -- 0:Ücretsiz, 1:Ücretli
)
GO

CREATE TABLE tblOlcum_
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
	Tarih DATE NOT NULL,
	Deger FLOAT NOT NULL CHECK (Deger > 0)
)
GO

/*
	Write a function that returns the Body Mass Index (BMI) value based on the given height (in meters) and weight (in kg) values.
	BMI value is calculated as WEIGHT / (SIZE * HEIGHT).
	The resulting value should be rounded to two digits after the dot.
*/

Create or alter Function fncBMI (@height float, @weight float)
returns float as
begin
	return Round(@weight / (@height*@height), 2)
end
go

select dbo.fncBMI(1.62, 60)

/*
	Write a view that brings the information of the users registered in the system as follows.
		NameSurname | Age | Target Weight | Starting Weight | Least Measurement | Curent Weight | Weight Lost | State | BMI
	
	•	Last Measurement: The number of days since the last weight measurement date will be displayed.
	•	Weight Loss: It is the difference between the current weight and the starting weights.
	•	Status: “Target Reached” if the current weight is less than or equal to the target weight, otherwise the difference between them should be written.
	•	BMI: The function in the first question will be called. (Please note that height information is recorded in cm in the system)

*/
go
Create or alter view vw_KullaniciInfo as
	Select Ad+ ' ' +Soyad as NameSurname,
	Yas as Age,
	HedefAgirlik as GoalWeight,
	BaslangicAgirlik as StartWeight,
	DATEDIFF(DD,SonOlcumTarihi, GETDATE()) as passDay,
	MevcutAgirlik as currentWeight,
	MevcutAgirlik - BaslangicAgirlik as GivedWeight,

	Case when MevcutAgirlik <= HedefAgirlik Then 'You achieved your goal.'
	else CONVERT(varchar(20), MevcutAgirlik - HedefAgirlik) + ' KG' 
	end as StateWeight,

	dbo.fncBMI(Boy, MevcutAgirlik) as BMI
	from tblKullanici
go


/*
	Write the procedure that can record a User's weight measurement value on any date. The restrictions are:
		•	If no date is specified in the procedure, the current system date will be used.
		•	If there is no record for the specified date, a new record will be created, but if there is, the weight information in that record will be updated.
		•	If the entered weight value is less than or equal to the user's target weight, the message
"Congratulations, you have reached your goal" will be displayed, otherwise the message "Sorry you have not reached your goal yet" will be displayed.
*/

Create or alter procedure spRegistMeasure (@userID int, @Measure float,  @regDate DATE = NULL) as
IF @regDate IS NULL set @regDate = CONVERT(date, GETDATE())

if exists(Select * from tblOlcum where ID=@userID and Tarih = @regDate)
	update tblOlcum set Deger = @Measure where KullaniciID = @userID and Tarih = @regDate

else
	insert into tblOlcum values(@userID, @regDate, @Measure)

Declare @targerWeight float;
Select @targerWeight = HedefAgirlik from tblKullanici where ID = @userID

if @Measure <= @targerWeight
raiserror('Congratulations, you have reached your goal',15,1)
else
raiserror('Sorry you have not reached your goal yet',15,1)
go

/*
	Write down the trigger that will run when any measurement value is inserted, updated or deleted (one for each, not three separately).
	•	The trigger in question should update the FirstMeasureDate, StartWeight, LastMeasureDate, and CurrentWeight fields in the user table,
taking into account all the measurement values of the relevant user.
	•	Assume that no batch updates or deletions are performed on the measurement table. (i.e. inserted and deleted will always return a single user row)
*/

Create or alter trigger trgControl on tblOlcum after insert, update, delete as
Declare @userID int, @insertOrUpdateID int, @deleteID int
select @insertOrUpdateID = KullaniciID from inserted 
select @deleteID = KullaniciID from deleted

select @userID = ISNULL(@insertOrUpdateID, @deleteID) --This point is the distinct point and really important

Declare @FirstMeasureDate Date, @StartWeight FLOAT, @LastMeasureDate Date, @CurrentWeight Float

Select @FirstMeasureDate = MIN(Tarih) from tblOlcum where KullaniciID = @userID
Select @StartWeight = Deger from tblOlcum where KullaniciID = @userID and Tarih = @FirstMeasureDate

Select @LastMeasureDate = MAX(Tarih) from tblOlcum where KullaniciID = @userID
Select @CurrentWeight = Deger from tblOlcum where KullaniciID = @userID and Tarih = @LastMeasureDate

update tblKullanici 
set 
 IlkOlcumTarihi = @FirstMeasureDate,
 BaslangicAgirlik = @StartWeight,
 SonOlcumTarihi = @LastMeasureDate,
 MevcutAgirlik = @CurrentWeight
where ID = @userID
go


/*
	Write another trigger that will run when any measurement value is entered.
	•	What is expected from this trigger is to prevent the eighth entry from occurring
if the user is a free type user and a total of seven measurement values are entered in the relevant table.
	•	In such a case, a message such as “Free users can enter up to 7 measurements” should also be displayed.
*/

create or alter trigger trgControlCustomerType on tblOlcum after insert as
Declare @userID int, @UserType TINYINT, @TotalMeasure smallint

Select @userID = KullaniciID from inserted
Select @UserType = KullaniciTipi from tblKullanici where ID = @userID
Select @TotalMeasure = COUNT(*) from tblOlcum where ID = @userID

if @UserType = 0 and @TotalMeasure >7
Begin
	raiserror ('Free users can enter up to 7 measurements', 16,1)
	rollback
end
go

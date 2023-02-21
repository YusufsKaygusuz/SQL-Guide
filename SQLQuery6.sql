CREATE TABLE tblOgrenci
(
	ogrno CHAR(9) PRIMARY KEY,
	ad VARCHAR(50) NOT NULL,
	soyad VARCHAR(50) NOT NULL,
	GNO FLOAT, -- The student's overall grade point average. out of 100
	donem TINYINT NOT NULL DEFAULT 0, -- This value is incremented by 1 as the registry refreshes. Normal period is 8 semesters
	aktif TINYINT NOT NULL DEFAULT 1 -- 0: finished, 1: in progress, 2: frozen
)

CREATE TABLE tblOgretimOyesi
(
	tc CHAR(11) PRIMARY KEY,
	unvan VARCHAR(10),
	ad VARCHAR(50) NOT NULL,
	soyad VARCHAR(50) NOT NULL
)

CREATE TABLE tblDers
(
	kod VARCHAR(10) PRIMARY KEY,
	ad VARCHAR(30) NOT NULL,
	kredi TINYINT NOT NULL,
	ogr_uyesi_tc CHAR(11) NOT NULL FOREIGN KEY REFERENCES tblOgretimOyesi(tc),
	kontenjan INT NOT NULL CHECK (kontenjan >= 0),
	kayitli_ogr INT NOT NULL DEFAULT 0
)

CREATE TABLE tblOgrenciDersKayit
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	ogr_no CHAR(9) NOT NULL FOREIGN KEY REFERENCES tblOgrenci(ogrno),
	ders_kodu VARCHAR(10) NOT NULL FOREIGN KEY REFERENCES tblDers(kod),
	vize INT,
	final INT,
	ort AS vize * 0.3 + final * 0.7 -- average of a student in a course
)
GO

/*
Write the function to convert the given one hundred (100) grade value to the four (4) grade value. The formula for the cycle:
	FourOverGrade = -0.283 + 0.043 * HundredOverGrade
*/

Create or alter function FourOverGrade (@note int)
returns float as
begin
	return  -0.283 + 0.043 * @note
end
go

select dbo.FourOverGrade(82)
go

/*
Write a View that will fetch the student information as follows. The letter grade calculation is as follows;
	90 or higher for AA, 80 or higher for BB, 70 or higher for CC, 60 or higher for DD, 59 and below for FF.
	(Use the function in the first question for the quadrant)
	Student Number | Name Surname | Period Status (in writing) | Hundreds Average | Letter Grade | Quarter Average | Registration Status (in text) |
*/
create or alter view vwStudentInfo as

Select ogrno as studentNo,
	ad+ ' ' + soyad as nameSurname,
	case when donem > 8 then 'Term extended'
		else 'Normal'
		end as termStatus,
	GNO as HundredAverage,
	case when GNO >= 90 then 'AA'
		 when GNO >= 80 then 'BB'
		 when GNO >= 70 then 'CC'
		 when GNO >= 60 then 'DD'
		 when GNO <= 59 then 'FF'
		 end as letterGrade,
	dbo.FourOverGrade(GNO) as QuarterAverage,
	case when aktif = 0 then 'Graduated'
		 when aktif = 1 then 'Contining'
		 when aktif = 2 then 'Frozen'
		 end as regStatus
from tblOgrenci
go


/*
Write the Stored Procedure (SP) that takes the student number and course code as parameters and registers the relevant course. The requirements are:
• In order to register for a course, the quota for that course must not be exceeded. If the quota for the course is full, the course should not be registered
and an error message should be displayed.
• A student must have only one enrollment for a course. If the student wants to enroll in the same course for the second time, the course should not be 
registered and an error message should be displayed.
• The procedure should use an isolation level that will not cause phantom read concurrency issues.
• While registering a course, the number of registered students of that course should be increased by 1.
*/
Create or alter procedure spRegisterLecture(@StudentNo char(9), @LectureCode varchar(10)) as
begin
	Set TRANSACTION ISOLATION LEVEL SERIALIZABLE 
		BEGIN TRANSACTION
	declare @kontenjan int, @RegisteredStudent int
	Select @kontenjan = kontenjan, @RegisteredStudent = kayitli_ogr from tblDers where kod = @LectureCode

if @kontenjan > @RegisteredStudent
	if not exists(select * from tblOgrenciDersKayit where ogr_no = @StudentNo and ders_kodu = @LectureCode)
	begin
		insert into tblOgrenciDersKayit values(@LectureCode, @StudentNo, null, null)
		update tblDers set kontenjan -= 1 where kod = @LectureCode
		commit
	end
	else
	begin
		raiserror('Student already registered',15,1)
		rollback
	end
else
begin
	raiserror('Quota is full',15,1)
	rollback
end
end
go

/*
Write a Trigger for the above question. The requirements are:
• Persons with an average of less than 2 can enroll in a maximum of 5 courses.
• No student can register for more than 8 courses.
*/
create or alter trigger trgControl on tblOgrenciDersKayit after insert as
declare @LectureCount int = (Select COUNT(*) from tblOgrenciDersKayit where ogr_no = (select ogr_no from inserted))
declare @QuarterNote float = (select QuarterAverage from vwStudentInfo where studentNo = (select ogr_no from inserted))

if @QuarterNote < 2  and  @LectureCount >5
begin
		raiserror('Note Average is smaller 2 in Quarter Average',15,1)
		rollback
end

else if @LectureCount >8
begin
raiserror('Do not take more 8 lesson in same term',15,1)
rollback
end
go

/*
tblDers tablosundaki kontenjan alaný güncellendiðinde çalýþacak bir Trigger yazýnýz. Eðer kontenjan deðeri kayýtlý öðrenci sayýsýndan az olacak þekilde
bir güncelleme iþlemi yapýlýyorsa bu iþlem iptal edilmeli ve bu konuda kullanýcý bilgilendirilmelidir.
Bir defada birden fazla dersin kontenjaný deðiþtirilmek istenmiþ olabileceðinden yukarýda belirtilen kýsýta uymayan bir güncelleme olduðunda tüm güncelleme
iþleminin iptal edilmesi gerekir.
*/

create or alter trigger trgCheckQuota on tblDers after update as
begin
	if UPDATE(kontenjan)
	begin
		if Exists(select * from inserted I where I.kontenjan - I.kayitli_ogr < 0)
		begin
			raiserror('Quato transaction denied and blocked', 15, 1)
			rollback
		end
	end
end
go



			


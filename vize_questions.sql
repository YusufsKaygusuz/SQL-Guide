Use randevu_sistemi
Select * from dbo.tblHasta

IF OBJECT_ID ('dbo.fn_toplam_doktor') IS Not null
Begin
	drop function fn_toplam_doktor
End

Go
-- Hastane idsi verilen hastanenin çalışan doktor sayısını dönen fonksiyon
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

IF OBJECT_ID('hastane_bilgileri') IS NOT NULL
Begin
Drop View hastane_bilgileri;
Print 'Silindi'
End
Go

-- Herhangi bir hastaneye ait bilgileri getiren View
Create or alter View hastane_bilgileri
As
	Select HST.Ad as hastane_adi,
	Convert(Char(15), kurulus_tarihi, 103) as hastane_kurulusu,
	dbo.fn_toplam_doktor(HST.ID) as toplam_doktor_sayisi,
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
toplam_doktor_sayisi,
sehir_bazinda_hastane_sayilari
from hastane_bilgileri as hb
	inner join TblHastaneTipi as httip ON httip.ID = hb.hastane_Tipi

Go
-- z = Hasta id'sini temsil ediyor.
-- Sisteme giriş yapmak yapmak isteyen kullanıcıdan aldığımız bilgiler ile kullanıcı eğer sistemde kayıtlı ve doğru 
-- şifreyi girerse sisteme girer. HastaTC veritabanında yoksa verilen bilgiler dahilinde veritabanına eklenir.

IF OBJECT_ID ('spHastaKontrol') IS NULL
	Drop Procedure spHastaKontrol
Go


Create or alter procedure spHastaKontrol(@HastaTC Varchar(11), @hastaAdı Varchar(20), @hastaSoyadı Varchar(20),
@Login varchar(20), @newPassword varchar(20))
As
Declare @HastaID int;
Declare @password varchar(20);

Select @password = Login from TblHasta
Select @HastaID = H.z From TblHasta H
	inner join TblRandevu R On R.HastaID = H.z
	Where H.HastaTC = @HastaTC
	Begin Transaction

if(@password = @login)
Begin
	Print('Giriş Başarılı')
	commit

	Begin Try
	--Şifre eğer null tanımlanmışsa catch satırlarına gidilir.
	update tblHasta set [Login] = @newPassword
	Commit
	end try

	Begin Catch
	raiserror('Şifre boş olamaz',15,1)
	rollback
	end catch
End

Else
Begin
	if(@HastaTC Not IN (Select HastaTC from TblHasta))
	Begin
	insert into TblHasta values(@HastaTC,@hastaAdı,@hastaSoyadı,Null, Null,Null,Null,Null,@Login)
	print ('Kayıt başarılı')
	commit
	End

	Else
	Begin
	raiserror('Girdiğiniz şifre doğru değil.',15,1)
	rollback
	End
End
Go

Exec spHastaKontrol '49732105614', 'Süleyman', 'Abay', 'pass123', Null
Go

/* Kayıt oluşturulan hastanın TC kimlik numarası 11 haneden az ise update işlemine izin verilmez.
*/

IF OBJECT_ID('trgHastaUpdate') IS NOT NULL
Drop Trigger trgHastaUpdate
Go

Create or alter trigger trgHastaUpdate ON tblHasta After Update
AS
Declare @HastaTc Varchar(11) = (Select HastaTC From inserted)
IF (Len(@HastaTc)<11)
Begin
Raiserror ('Hasta Tc numarası 11 haneden küçük olamaz', 16,1)
Rollback
End
Go

--İlaç var Tablosundaki ilaç adeti değiştirilebilir.

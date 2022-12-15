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
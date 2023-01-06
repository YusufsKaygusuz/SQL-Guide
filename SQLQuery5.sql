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
	Verilen boy (metre cinsinden) ve kilo (kg cinsinden) deðerlerine göre Vücut Kitle Ýndeksi (Body Mass Index, BMI) deðerini geri dönen bir fonksiyon yazýnýz.
	BMI deðeri, KÝLO / (BOY * BOY) þeklinde hesaplanmaktadýr.
	Sonuç deðeri noktadan sonra iki basamak olacak þekilde yuvarlanýlarak döndürülmelidir
*/

Create or alter Function fncBMI (@height float, @weight float)
returns float as
begin
	return Round(@weight / (@height*@height), 2)
end
go

select dbo.fncBMI(1.62, 60)

/*
	Sistemde kayýtlý kullanýcýlarýn bilgilerini aþaðýdaki þekilde getiren bir view yazýnýz.
		Ad Soyad | Yaþ | Hedef Aðýrlýk | Baþlangýç Aðýrlýk | Son Ölçüm | Mevcut Aðýrlýk | Verilen Kilo | Durum | BMI
	
	•	Son Ölçüm: En son kilo ölçüm tarihinden o ana kadar geçen gün sayýsý gösterilecektir.
	•	Verilen Kilo: Mevcut aðýrlýk ile baþlangýç aðýrlýðýn farkýdýr.
	•	Durum: Eðer mevcut aðýrlýk hedef aðýrlýktan küçük ya da eþit ise “Hedefe Ulaþýldý”, aksi halde aralarýndaki fark yazýlmalýdýr.
	•	BMI: Ýlk sorudaki fonksiyon çaðrýlacaktýr. (sistemde boy bilgisinin cm olarak kayýtlý olduðuna dikkat ediniz)

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


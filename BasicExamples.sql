CREATE TABLE tblKullanici_
(
ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(50) NOT NULL,
	Soyad VARCHAR(50) NOT NULL,
	DogTrh DATE NOT NULL,
	Yas AS DATEDIFF(yy, DogTrh, GETDATE()),
	IlkOlcumTarihi DATE, -- Ilk ölçülen kilo degerinin girildigi tarih
	BaslangicAgirlik FLOAT, -- Ilk ölçülen kilogram degeri
	SonOlcumTarihi DATE, -- En son ölçülen kilogram degerinin girildigi tarih
	MevcutAgirlik FLOAT, -- En son ölçülen kilogram degeri		
	HedefAgirlik FLOAT NOT NULL, -- Kullanicinin hedefledigi kilogram degeri
	Boy FLOAT NOT NULL, -- CM olarak girilir
	KullaniciTipi TINYINT NOT NULL DEFAULT 0 -- 0:Ücretsiz, 1:Ücretli
)
Go

CREATE TABLE tblOlcum_
(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	KullaniciID INT FOREIGN KEY REFERENCES tblKullanici(ID) NOT NULL,
	Tarih DATE NOT NULL,
	Deger FLOAT NOT NULL CHECK (Deger > 0)
)
Go

/*
Verilen boy (metre cinsinden) ve kilo (kg cinsinden) degerlerine göre Vücut Kitle Indeksi (Body Mass Index, BMI) 
degerini geri dönen bir fonksiyon yazınız.
	BMI degeri, KILO / (BOY * BOY) seklinde hesaplanmaktadir.
	Sonuç degeri noktadan sonra iki basamak olacak sekilde yuvarlanalarak döndürülmelidir
*/
Create or alter function fncBodyMassIndex(@weight Float, @height Float)
Returns Float
AS 
Begin
	Return Round( (@weight/(@height*@height)), 2)
End
Go
Select dbo.fncBodyMassIndex(60.9,1.72)
Go

/*
Sistemde kayitli kullanicilarin bilgilerini asagidaki sekilde getiren bir view yaziniz.
		Ad Soyad | Yas | Hedef Agirlik | Baslangiç Agirlik | Son Ölçüm | Mevcut Agirlik | Verilen Kilo | Durum | BMI
	
	•	Son Ölçüm: En son kilo ölçüm tarihinden o ana kadar geçen gün sayisi gösterilecektir.
	•	Verilen Kilo: Mevcut agirlik ile baslangic agirligin farklidir.
	•	Durum: Eger mevcut agirlik hedef agirliktan küçük ya da esit ise “Hedefe Ulasildi”, aksi halde aralarindaki fark yazilmalidir.
	•	BMI: Ilk sorudaki fonksiyon çagrilacaktir. (sistemde boy bilgisinin cm olarak kayitli olduguna dikkat ediniz)
*/

Create or alter view vwKayitliKullanici As
	Select Ad+' '+Soyad as AdSoyad,
			Yas,
			HedefAgirlik,
			BaslangicAgirlik,
			DATEDIFF(Day,SonOlcumTarihi,GETDATE()) as SonOlcüm,
			MevcutAgirlik,
			MevcutAgirlik - BaslangicAgirlik as verilenKilo,
			Case 
				When MevcutAgirlik<HedefAgirlik then 'Hedefe Ulaşıldı!'
				else 'Geriye Kalan: ' + Convert(Varchar(10), (MevcutAgirlik - BaslangicAgirlik)) + ' KG'
			End As Durum,
			dbo.fncBodyMassIndex(MevcutAgirlik, Boy/100) as BMI

	From tblKullanici K inner join tblOlcum O ON K.ID = O.KullaniciID
Go

/*
Bir kullanicinin herhangi bir tarihteki kilo ölcüm degerini kaydedebilecek prosedürü yaziniz. Kisitlar böyledir: 
		•	Prosedüre tarih belirtilmedigi takdirde geçerli sistem tarihi kullanilacaktir.
		•	Ayni tarih için birden fazla giris yapalabilmektedir. Ancak sistemde son girilen kilo bilgisi tutulmaktadir. 
Diger bir deyisle eger belirtilen tarih için kayit yoksa yeni kayit olusturulacak ama varsa o kayittaki kilo bilgisi güncellenecektir.
		•	Girilen kilo degeri kullanicinin hedef kilo degerinden küçük ya da esit ise 
		“Tebrikler hedefinize ulastiniz” mesaji, degilse “Üzgünüm hedefinize henüz ulasamadiniz” mesaji görüntülenecektir.
*/

Create or alter procedure spOlcumEkle(@KisiID int, @value Float, @tarih Date = NULL) 
AS
IF @tarih IS NULL
set @tarih = Convert(varchar(10), GETDATE())

IF Exists (Select * From tblOlcum where ID = @KisiID and Tarih = @tarih)
update tblOlcum set Deger = @value where KullaniciID = @KisiID and Tarih = @tarih

Else
insert into tblOlcum values(@KisiID, @tarih, @value)

declare @hedefKilo float;
Select @hedefKilo = HedefAgirlik From tblKullanici where ID = @KisiID

IF @value <= @hedefKilo
Raiserror('Congrulation, You have reached the goal.',10,1)

Else
Raiserror('Sorry, You do not reach the goal.',10,1)
Go

/*
-Herhangi bir ölçüm degeri girildiginde, güncellendiginde ya da silindiginde çalisacak olan triggeri yaziniz
(ayri ayri üç tane degil hepsi için tek bir tane yazilmalidir).
-Söz konusu trigger, kullanici tablosundaki IlkOlcumTarihi, BaslangicAgirlik, SonOlcumTarihi, ve MevcutAgirlik
alanlarini ilgili kullanicinin tüm ölçüm degerlerini dikkate alarak güncellemelidir.
-Ölçüm tablosu üzerinde toplu güncelleme ve silme islemlerinin yapilmadigini varsayiniz.
(yani inserted ve deleted her zaman tek bir kullaniciya ait satirlari dönecektir)
*/
Create or alter Trigger trgKullaniciKilolariGuncelle ON tblOlcum After insert, update, delete as
Declare @KID INT, @KID1 INT, @KID2 INT 
Select @KID1 = KullaniciID from inserted
Select @KID2 = KullaniciID From deleted

Set @KID = ISNULL(@KID1, @KID2)
-- Logical Assomption

Declare @FirstDate Date, @FirstValue Float, @LastDate Date, @CurrentValue Float;

Select @FirstDate = MIN(Tarih), @LastDate = MAX(Tarih) from tblOlcum where KullaniciID = @KID
Select @FirstValue = Deger From tblOlcum where KullaniciID = @KID and Tarih = @FirstDate
Select @LastDate = Deger From tblOlcum where KullaniciID = @KID and Tarih = @LastDate

Update tblKullanici
Set
	IlkOlcumTarihi = @FirstDate,
	BaslangicAgirlik = @FirstValue,
	SonOlcumTarihi = @LastDate,
	MevcutAgirlik = @CurrentValue
	Where ID = @KID
Go

/*
Herhangi bir ölçüm degeri girildiginde çalisacak olan bir baska trigger daha yaziniz.
Bu trigger’dan beklenen, eger kullanici ücretsiz tipli bir kullanici ise ve toplamda yedi adet ölçüm degeri
ilgili tabloya girilmis ise sekizinci girisin olmasini engellemektir.
Böyle bir durumda “Ücretsiz kullanicilar en çok 7 tane ölçüm girebilirler” seklinde bir mesaj da gösterilmelidir.
*/

Create or alter trigger tr7DayControl ON tblOlcum after insert as
Declare @user_id int;
Declare @totalInput smallint;
Declare @KullaniciTipi tinyint;

Select @user_id = KullaniciID from inserted
Select @KullaniciTipi = KullaniciTipi from tblKullanici where ID = @user_id
Select @totalInput = COUNT(*) From tblOlcum Where KullaniciID = @user_id

if @totalInput > 7 and @KullaniciTipi = 0
Begin
Raiserror ('!!!You reached your limit. You can searh other packets',16,1)
Rollback
End
Go


CREATE TABLE tblOgrenci
(
	ogrno CHAR(9) PRIMARY KEY,
	ad VARCHAR(50) NOT NULL,
	soyad VARCHAR(50) NOT NULL,
	GNO FLOAT, -- Öðrencinin genel not ortalamasý. 100 üzerindendir
	donem TINYINT NOT NULL DEFAULT 0, -- kayýt yenileme oldukça bu deðer 1 arttýrýlýr. Normal süre 8 dönemdir
	aktif TINYINT NOT NULL DEFAULT 1 -- 0: bitirmiþ, 1: devam ediyor, 2: dondurmuþ
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
	ort AS vize * 0.3 + final * 0.7 -- bir öðrencinin bir dersteki ortalamasý
)
GO

/*
Verilen yüzlük (100) not deðerini dörtlük (4) not deðerine çevirecek fonksiyonu yazýnýz. Çevrim için formül:
	DörtÜzerindenNot = -0.283 + 0.043 * YüzÜzerindenNot
*/
Create or alter function fncDortlukPuan (@grade int)
Returns Float
AS
Begin
	return -0.283 + 0.043 * @grade
End
Go

Select dbo.fncDortlukPuan(82)
Go

Create or alter view vwStudentInfo AS
Select ogrno as studentNumber,
ad +' ' +soyad as NameSurname,
Case when donem>8 then 'öğrenci Dönem Uzatmıştır' else 'normal'
end as donem,
GNO,
case when GNO>90 then 'AA'
	 when GNO>80 then 'BB'
	 when GNO>70 then 'CC'
	 WHEN GNO >= 60 THEN 'DD'
	 ELSE 'FF'
End as HarfNotu,
dbo.fncDortlukPuan(GNO) AS DortlukOrt,
CASE
				WHEN aktif = 0 THEN 'MEZUN OLMUÞ'
				WHEN aktif = 1 THEN 'DEVAM EDÝYOR'
				WHEN aktif = 2 THEN 'DONDURMUÞ'
			END AS KayitDurumu
FROM tblOgrenci 
Go

/*
Öðrenci numarasý ve ders kodunu parametre olarak alýp ilgili ders kaydýný yapan Stored Procedure (SP) yazýnýz. Gereksinimler þöyledir:
	•	Bir derse kayýt yapabilmek için o dersin kontenjanýnýn aþýlmamýþ olmasý gerekir. Eðer dersin kontenjaný dolmuþ ise, ders kaydý yapýlmamalý ve durumla ilgili bir hata mesajý gösterilmelidir
	•	Bir öðrencinin bir ders için tek bir kaydý olmalýdýr. Eðer öðrenci ayný derse ikinci kez kayýt yapmak istiyorsa, ders kaydý yapýlmamalý ve durumla ilgili bir hata mesajý gösterilmelidir
	•	Prosedür, phantom read eþ zamanlýlýk (concurrency) sorununu yaþatmayacak bir izolasyon seviyesini kullanmalýdýr
	•	Ders kaydýný müteakip o dersin kayýtlý öðrenci sayýsý bir (1) arttýrýlmalýdýr
*/
Create or alter procedure spDersKayit(@ogrenciNo char(9), @dersKodu Varchar(10)) AS
Begin
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
Declare @kontenjan int; 
Declare @kayitli int;
Select @kontenjan = kontenjan, @kayitli = kayitli_ogr from tblDers where kod = @dersKodu

if(@kontenjan > @kayitli)
	if Not Exists (Select * from tblOgrenciDersKayit where ogr_no = @ogrenciNo and ders_kodu = @dersKodu)
	Begin
		insert into tblOgrenciDersKayit values(@ogrenciNo, @dersKodu, Null, Null)
		update tblDers set kayitli_ogr +=1 where kod = @dersKodu
		commit
	end
	else
	begin
		RAISERROR('!!! BU DERSE ZATEN KAYITLISINIZ. TEKRARDAN KAYIT OLAMAZSINIZ. !!! ', 16, 1)																
		ROLLBACK
	end

else
BEGIN
RAISERROR('!!! KONTENJAN YETERSÝZ. DERS KAYDI YAPILAMAZ. !!! ', 16, 1)			
ROLLBACK
END
end
Go

/*
Üstteki soru için bir Trigger yazýnýz. Gereksinimler þöyledir:
	•	Ortalamasý 2’nin altýnda olan öðrenciler en çok 5 derse kayýt yaptýrabilirler
	•	Hiçbir öðrenci 8’den fazla derse kaydolamaz

*/
Create trigger trgOgrenciDersSayisiKontrol ON tblOgrenciDersKayit After insert as 
Begin
	Declare @countKayit int = (Select COUNT(*) from tblOgrenciDersKayit Where ogr_no = (select ogr_no from inserted))
	Declare @ort float = (Select DortlukOrt from vwStudentInfo where studentNumber = (Select ogr_no from inserted) )
	IF @countKayit > 5 AND @ort < 2
			BEGIN
				RAISERROR('EN ÇOK 5 DERS SEÇEBÝLÝRSÝNÝZ...', 16, 1)
				ROLLBACK
			END
		ELSE IF @countKayit > 8
			BEGIN			
				RAISERROR('EN ÇOK 8 DERS SEÇEBÝLÝRSÝNÝZ...', 16, 1)
				ROLLBACK
			END
	END
Go

Create or alter trigger trgAcilanDersKontenjan On tblDers After Update as
begin
	IF UPDATE(kontenjan)
			if Exists (Select * from inserted i where i.kontenjan - i.kayitli_ogr <0)
			BEGIN
						RAISERROR('KONTENJAN KAYITLI ÖÐRENCÝ SAYISINDAN DAHA AZ OLAMAZ', 16, 1)
						ROLLBACK
					END
end
go


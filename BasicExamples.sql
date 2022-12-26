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
degerini geri dönen bir fonksiyon yazýnýz.
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
				When MevcutAgirlik<HedefAgirlik then 'Hedefe Ulaþýldý!'
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


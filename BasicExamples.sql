CREATE TABLE tblKullanici_
(
ID INT IDENTITY(1,1) PRIMARY KEY,
	Ad VARCHAR(50) NOT NULL,
	Soyad VARCHAR(50) NOT NULL,
	DogTrh DATE NOT NULL,
	Yas AS DATEDIFF(yy, DogTrh, GETDATE()),
	IlkOlcumTarihi DATE, -- Ilk �l��len kilo degerinin girildigi tarih
	BaslangicAgirlik FLOAT, -- Ilk �l��len kilogram degeri
	SonOlcumTarihi DATE, -- En son �l��len kilogram degerinin girildigi tarih
	MevcutAgirlik FLOAT, -- En son �l��len kilogram degeri		
	HedefAgirlik FLOAT NOT NULL, -- Kullanicinin hedefledigi kilogram degeri
	Boy FLOAT NOT NULL, -- CM olarak girilir
	KullaniciTipi TINYINT NOT NULL DEFAULT 0 -- 0:�cretsiz, 1:�cretli
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
Verilen boy (metre cinsinden) ve kilo (kg cinsinden) degerlerine g�re V�cut Kitle Indeksi (Body Mass Index, BMI) 
degerini geri d�nen bir fonksiyon yaz�n�z.
	BMI degeri, KILO / (BOY * BOY) seklinde hesaplanmaktadir.
	Sonu� degeri noktadan sonra iki basamak olacak sekilde yuvarlanalarak d�nd�r�lmelidir
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
		Ad Soyad | Yas | Hedef Agirlik | Baslangi� Agirlik | Son �l��m | Mevcut Agirlik | Verilen Kilo | Durum | BMI
	
	�	Son �l��m: En son kilo �l��m tarihinden o ana kadar ge�en g�n sayisi g�sterilecektir.
	�	Verilen Kilo: Mevcut agirlik ile baslangic agirligin farklidir.
	�	Durum: Eger mevcut agirlik hedef agirliktan k���k ya da esit ise �Hedefe Ulasildi�, aksi halde aralarindaki fark yazilmalidir.
	�	BMI: Ilk sorudaki fonksiyon �agrilacaktir. (sistemde boy bilgisinin cm olarak kayitli olduguna dikkat ediniz)
*/

Create or alter view vwKayitliKullanici As
	Select Ad+' '+Soyad as AdSoyad,
			Yas,
			HedefAgirlik,
			BaslangicAgirlik,
			DATEDIFF(Day,SonOlcumTarihi,GETDATE()) as SonOlc�m,
			MevcutAgirlik,
			MevcutAgirlik - BaslangicAgirlik as verilenKilo,
			Case 
				When MevcutAgirlik<HedefAgirlik then 'Hedefe Ula��ld�!'
				else 'Geriye Kalan: ' + Convert(Varchar(10), (MevcutAgirlik - BaslangicAgirlik)) + ' KG'
			End As Durum,
			dbo.fncBodyMassIndex(MevcutAgirlik, Boy/100) as BMI

	From tblKullanici K inner join tblOlcum O ON K.ID = O.KullaniciID
Go

/*
Bir kullanicinin herhangi bir tarihteki kilo �lc�m degerini kaydedebilecek prosed�r� yaziniz. Kisitlar b�yledir: 
		�	Prosed�re tarih belirtilmedigi takdirde ge�erli sistem tarihi kullanilacaktir.
		�	Ayni tarih i�in birden fazla giris yapalabilmektedir. Ancak sistemde son girilen kilo bilgisi tutulmaktadir. 
Diger bir deyisle eger belirtilen tarih i�in kayit yoksa yeni kayit olusturulacak ama varsa o kayittaki kilo bilgisi g�ncellenecektir.
		�	Girilen kilo degeri kullanicinin hedef kilo degerinden k���k ya da esit ise 
		�Tebrikler hedefinize ulastiniz� mesaji, degilse ��zg�n�m hedefinize hen�z ulasamadiniz� mesaji g�r�nt�lenecektir.
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
-Herhangi bir �l��m degeri girildiginde, g�ncellendiginde ya da silindiginde �alisacak olan triggeri yaziniz
(ayri ayri �� tane degil hepsi i�in tek bir tane yazilmalidir).
-S�z konusu trigger, kullanici tablosundaki IlkOlcumTarihi, BaslangicAgirlik, SonOlcumTarihi, ve MevcutAgirlik
alanlarini ilgili kullanicinin t�m �l��m degerlerini dikkate alarak g�ncellemelidir.
-�l��m tablosu �zerinde toplu g�ncelleme ve silme islemlerinin yapilmadigini varsayiniz.
(yani inserted ve deleted her zaman tek bir kullaniciya ait satirlari d�necektir)
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
Herhangi bir �l��m degeri girildiginde �alisacak olan bir baska trigger daha yaziniz.
Bu trigger�dan beklenen, eger kullanici �cretsiz tipli bir kullanici ise ve toplamda yedi adet �l��m degeri
ilgili tabloya girilmis ise sekizinci girisin olmasini engellemektir.
B�yle bir durumda ��cretsiz kullanicilar en �ok 7 tane �l��m girebilirler� seklinde bir mesaj da g�sterilmelidir.
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


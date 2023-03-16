# SQL-Examples
 This SQL examples includes: Function, View, Stored Procedure and etc.

<h2>📚 Fonksiyonlar ve Görünümler Hakkında Bilgi</h2>

Bu README dosyası, SQL'de Fonksiyonlar ve Görünümler hakkında temel bilgileri sağlar. Fonksiyonlar ve Görünümler, SQL programlama dilinde sıklıkla kullanılan önemli öğelerdir. Bu dosya, bu öğelerin nasıl kullanılacağına ve ne işe yaradığına dair genel bir bakış sunar.

<h2>📝 Funcitons</h2>

Fonksiyonlar, SQL programlama dilinde işlevsellik sağlayan bloklardır. Bir fonksiyon, belirli bir görevi gerçekleştiren kodu içerir ve bu görevi yerine getirdiğinde sonuç değeri döndürür. Fonksiyonlar, sorguları daha okunaklı hale getirmek ve tekrarlanan işlemleri azaltmak için kullanılabilir.

Örnek olarak, aşağıdaki SQL kodu, iki sayıyı toplayan bir fonksiyon tanımlar:

     CREATE FUNCTION topla(a INT, b INT)
     RETURNS INT
     BEGIN
       RETURN a + b;
     END;

Bu fonksiyon, iki sayıyı toplar ve sonucu döndürür. Fonksiyonlar, belirli bir işlevi yerine getirmek için tekrar kullanılabilir ve sorguları daha okunaklı hale getirebilir.

<h2>👀 Views</h2>

Görünümler, bir SQL sorgusunun sonucunu depolamak yerine, bu sorgunun sonucunu her zaman bir tablo olarak oluşturan bir sanal tablodur. Görünümler, bir veya daha fazla tablodan veri almak, bu verileri işlemek ve sonucunu bir tablo olarak döndürmek için kullanılabilir.

Örnek olarak, aşağıdaki SQL kodu, bir tablodan sadece belirli bir sütunu seçen bir görünüm tanımlar:

    CREATE VIEW my_view AS
    SELECT column_name
    FROM my_table;

Bu görünüm, "my_table" adlı tablodan "column_name" sütununu seçer ve bu sütunu "my_view" adlı bir görünüm olarak döndürür. Görünümler, verilerin daha organize ve erişilebilir hale getirilmesine yardımcı olur.

<h2>💻 Nasıl Kullanılır</h2>

Fonksiyonlar ve Görünümler, SQL programlama dilinde kullanılabilir. Bir fonksiyon tanımlamak veya bir görünüm oluşturmak için, önce SQL sorgu editörüne erişmeniz gerekir. Bu editöre erişmek için, bir SQL veritabanı yönetim sistemi (DBMS) kullanabilirsiniz.

Fonksiyonlar, CREATE FUNCTION komutu ile oluşturulur ve çağrılmak için SELECT veya diğer SQL sorgu türleri kullanılır. Örneğin, yukarıdaki örnek fonksiyonu çağırmak için aşağıdaki SQL kodu kullanılabilir:

    SELECT topla(2, 3);
Bu sorgu, "topla" fonksiyonunu çağırır ve 2 ve 3 sayılarını toplayarak sonucu döndürür.

Görünümler, CREATE VIEW komutu ile oluşturulur ve SELECT sorgusu kullanılarak erişilir. Örneğin, yukarıdaki örnek görünümü kullanmak için aşağıdaki SQL kodu kullanılabilir:
   
    SELECT * FROM my_view;
     
Bu sorgu, "my_view" görünümünü çağırır ve "my_table" tablosundan sadece "column_name" sütununu içeren bir tablo döndürür.

<h2>📖 Sonuç</h2>

Bu README dosyası, SQL programlama dilinde Fonksiyonlar ve Görünümler hakkında genel bilgiler sağlamaktadır. Fonksiyonlar, belirli bir görevi yerine getiren kod bloklarıdır ve sorguları daha okunaklı hale getirmek için kullanılabilir. Görünümler, bir SQL sorgusunun sonucunu depolamak yerine, bu sorgunun sonucunu her zaman bir tablo olarak oluşturan bir sanal tablodur. Görünümler, verilerin daha organize ve erişilebilir hale getirilmesine yardımcı olur. SQL programlama dilinde Fonksiyonlar ve Görünümler kullanarak, verileri daha etkili bir şekilde işleyebilir ve sorguları daha okunaklı hale getirebilirsiniz.

<h2>📝 Stored Procedures (Depolanmış Prosedürler)</h2>

Stored Procedure, SQL programlama dilindeki bir öğedir ve bir veya daha fazla SQL sorgusundan oluşan bir programdır. Bu program, veritabanı tarafında saklanır ve tekrar tekrar kullanılabilen işlemleri otomatikleştirmek için kullanılır. Stored Procedure, veri tabanı yöneticileri ve uygulama geliştiricileri için birçok avantaj sağlar.

<h2>🔍 Avantajlar</h2>

1️⃣ Performans: Stored Procedure'ler, birçok SQL sorgusunu birleştirerek veritabanı performansını artırır. Stored Procedure'ler, SQL sorgularını bir kez derler ve daha sonra kullanıma hazır hale getirirler. Bu nedenle, veri tabanı yöneticileri ve uygulama geliştiricileri, performans sorunlarını çözmek için daha fazla zaman harcamak yerine, depolanan prosedürlerin kullanımı ile daha hızlı sonuçlar elde edebilirler.

2️⃣ Güvenlik: Stored Procedure'ler, veritabanı güvenliğini artırır. Bu, veri tabanı yöneticilerinin ve uygulama geliştiricilerinin, veritabanı üzerindeki hassas verileri korumalarına yardımcı olur. Stored Procedure'ler, SQL enjeksiyon saldırılarına karşı daha iyi koruma sağlar ve veritabanı yöneticilerinin, hassas verilere erişimi kontrol etmelerine yardımcı olur.

3️⃣ Yeniden kullanılabilirlik: Stored Procedure'ler, birçok uygulamada yeniden kullanılabilir. Veritabanı yöneticileri ve uygulama geliştiricileri, aynı kodu tekrar tekrar yazmak yerine, depolanan prosedürleri kullanarak işlemleri otomatikleştirebilirler. Bu, zaman ve kaynakların daha verimli kullanımını sağlar.

<h2>📝 Kullanımı</h2>

Stored Procedure'ler, veritabanı yöneticileri ve uygulama geliştiricileri tarafından yaratılır ve yönetilir. Stored Procedure'ler, veritabanı yöneticileri tarafından, CREATE PROCEDURE komutu kullanılarak yaratılır. Stored Procedure'ler, parametrelerle de kullanılabilir.

Örneğin, aşağıdaki SQL kodu, "my_procedure" adlı bir Stored Procedure yaratır:

    CREATE PROCEDURE my_procedure
    @parameter1 int,
    @parameter2 varchar(50)
    AS
    BEGIN
        SELECT *
        FROM my_table
        WHERE column1 = @parameter1
        AND column2 = @parameter2
    END

Bu Stored Procedure, "my_table" tablosunda "column1" ve "column2" sütunlarına göre verileri filtreleyerek geri döndürür. Bu Stored Procedure, "@parameter1" ve "@parameter2" adlı iki parametre alır.

<h2>📝 Kullanımı (devam)</h2>

Stored Procedure'ler, uygulama geliştiricileri tarafından, EXECUTE komutu kullanılarak çağrılır. Aşağıdaki SQL kodu, yukarıdaki örnekte oluşturulan Stored Procedure'yi çağırır:

    EXECUTE my_procedure
    Go
 
Bu komut, "my_procedure" Stored Procedure'ünü, "@parameter1" değeri olarak "1" ve "@parameter2" değeri olarak "example" ile çağırır.

Stored Procedure'ler, veritabanı yöneticileri ve uygulama geliştiricileri tarafından yönetilir ve düzenlenir. Stored Procedure'ler, ALTER PROCEDURE komutu kullanılarak düzenlenebilir veya DROP PROCEDURE komutu kullanılarak silinebilir.

<h2>🔍 Özet</h2>

Stored Procedure'ler, SQL programlama dilinde bir öğedir ve bir veya daha fazla SQL sorgusundan oluşan bir programdır. Stored Procedure'ler, performans, güvenlik ve yeniden kullanılabilirlik gibi birçok avantaj sağlar. Stored Procedure'ler, veritabanı yöneticileri tarafından yaratılır ve EXECUTE komutu kullanılarak çağrılır. Stored Procedure'ler, ALTER PROCEDURE komutu kullanılarak düzenlenebilir veya DROP PROCEDURE komutu kullanılarak silinebilir.

<h2>📝 Triggers (Tetikleyiciler)</h2>

Triggers (Tetikleyiciler), veritabanı yöneticileri tarafından SQL programlama dilinde kullanılan bir öğedir. Triggers, belirli bir tablodaki bir olay gerçekleştiğinde (INSERT, UPDATE, DELETE vb.), belirli bir işlemi otomatik olarak gerçekleştiren bir SQL kod bloğudur. Triggers, veritabanı yöneticileri için birçok avantaj sağlar.

<h2>🔍 Avantajlar</h2>

Triggers'ların birkaç avantajı vardır:

1️⃣ Veri bütünlüğü: Triggers, veritabanı yöneticilerinin veri bütünlüğünü sağlamalarına yardımcı olur. Örneğin, bir Trigger, bir tabloya yeni bir kayıt eklendiğinde, bu kaydın diğer tablolardaki ilgili kayıtlarla ilişkilendirilmesini sağlayabilir.

2️⃣ Güvenlik: Triggers, veritabanı güvenliğini artırır. Triggers, kullanıcının belirli bir olayı tetiklemesi gerektiği için, veritabanına kötü amaçlı yazılım eklenmesini önler.

3️⃣ Otomatikleştirme: Triggers, belirli bir olay gerçekleştiğinde belirli bir işlemi otomatik olarak gerçekleştirir. Bu, veritabanı yöneticileri için zaman ve kaynak tasarrufu sağlar.

<h2>📝 Kullanımı</h2>

Triggers, veritabanı yöneticileri tarafından yaratılır ve yönetilir. Triggers, bir tabloya eklendiğinde veya bir tablodan silindiğinde otomatik olarak çalıştırılır. Triggers, belirli bir tabloya eklenirken, CREATE TRIGGER komutu kullanılarak yaratılır.

Örneğin, aşağıdaki SQL kodu, "my_table" adlı bir tabloya INSERT olayı gerçekleştiğinde tetiklenecek bir Trigger yaratır:

    CREATE TRIGGER my_trigger
    ON my_table
    AFTER INSERT
    AS
    BEGIN
        -- işlem yapılacak SQL kodları buraya yazılır
    END
 
Bu Trigger, "my_table" adlı bir tabloya yeni bir kayıt eklenirken tetiklenir ve "BEGIN" ve "END" arasına yazılan SQL kodlarını otomatik olarak çalıştırır.

<h2>🔍 Özet</h2>

Triggers, veritabanı yöneticileri tarafından SQL programlama dilinde kullanılan bir öğedir. Triggers, belirli bir tablodaki bir olay gerçekleştiğinde belirli bir işlemi otomatik olarak gerçekleştiren bir SQL kod bloğudur. Triggers, veri bütünlüğü, güvenlik ve otomatikleştirme gibi birçok avantaj sağlar. Triggers, veritabanı yöneticileri tarafından CREATE TRIGGER komutu kullanılarak yaratılır ve yönetilir.

<h2>📝 Transaction ve Rollback</h2>

Transaction, bir veya birden fazla SQL sorgusunu tek bir işlem olarak işleme alma işlemidir. Bir transaction içindeki tüm sorgular, ya tamamlanacak ya da hepsi başarısız olacaktır. Transaction'lar veri bütünlüğünü korumak için çok önemlidir. Bununla birlikte, her zaman her şey yolunda gitmeyebilir ve bir transaction başarısız olabilir. Bu durumda, Rollback kullanılarak işlem geri alınabilir.

<h2>🔍 Transaction</h2>

Transaction, veritabanındaki işlemleri daha güvenli hale getirmek için kullanılır. Transaction, bir veya birden fazla SQL sorgusunu tek bir işlem olarak işleme alır. Bir transaction içindeki tüm sorgular, ya tamamlanacak ya da hepsi başarısız olacaktır. Transaction'lar, veri bütünlüğünü korumak için çok önemlidir, çünkü bir transaction içindeki sorgulardan biri başarısız olursa, transaction tamamlanmayacak ve yapılan tüm değişiklikler geri alınacaktır.

Örneğin, aşağıdaki SQL kodu, bir transaction başlatır ve "my_table" adlı bir tabloya iki yeni kayıt ekler:

        BEGIN TRANSACTION
        INSERT INTO my_table (column1, column2) VALUES (value1, value2);
        INSERT INTO my_table (column1, column2) VALUES (value3, value4);
        COMMIT TRANSACTION
           
Bu SQL kodu, "BEGIN TRANSACTION" ile başlayarak bir transaction başlatır. Daha sonra, "my_table" adlı bir tabloya iki yeni kayıt ekler. Son olarak, "COMMIT TRANSACTION" kullanarak transaction'ı tamamlar ve işlemi onaylar.

<h2>🔍 Rollback</h2>

Bir transaction başarısız olursa, Rollback kullanılarak tüm yapılan değişiklikler geri alınabilir. Rollback, transaction içinde yapılan tüm değişiklikleri geri alarak veritabanını transaction öncesi duruma geri getirir.

Örneğin, aşağıdaki SQL kodu, bir transaction başlatır ve "my_table" adlı bir tabloya iki yeni kayıt ekler. Ancak, ikinci INSERT işlemi başarısız olur ve transaction geri alınır:

    BEGIN TRANSACTION
    INSERT INTO my_table (column1, column2) VALUES (value1, value2);
    INSERT INTO my_table (column1, column2) VALUES (value3, value4); -- Bu sorgu hata verecek
    ROLLBACK TRANSACTION

Bu SQL kodu, "BEGIN TRANSACTION" ile başlayarak bir transaction başlatır. Daha sonra, "my_table" adlı bir tabloya iki yeni kayıt ekler. Ancak, ikinci INSERT sorgusu başarısız olur ve "ROLLBACK TRANSACTION" kullanılarak transaction geri alınır.

<h2>🔍 Özet</h2>

Transaction, bir veya birden fazla SQL sorgusunu tek bir işlem olarak işleme alma işlemidir. Transaction'lar veri bütünlüğünü koruması ve Rollback kullanılarak, bir transaction başarısız olursa yapılan tüm değişiklikler geri alınabilir. Rollback, transaction içinde yapılan tüm değişiklikleri geri alarak veritabanını transaction öncesi duruma geri getirir. Bu özellik, veritabanındaki veri bütünlüğünü korumak için çok önemlidir.

Stored Procedure, View, Function, Transaction ve Rollback, SQL'de veritabanı yönetimi için önemli araçlardır. Bu araçlar, veritabanı tasarımı ve yönetimi için esneklik, güvenlik ve performans sağlarlar. Her bir araç farklı işlevlere sahip olsa da, hepsi veri bütünlüğünü korumak ve veritabanı işlemlerini optimize etmek için birlikte çalışırlar.

🚀 Happy coding! 🎉

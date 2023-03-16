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




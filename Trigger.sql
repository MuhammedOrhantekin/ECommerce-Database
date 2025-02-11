-- Payment tablosu için ödeme detaylarını kontrol eden tetikleyici:
-- Bu tetikleyici, yeni bir ödeme eklenirken PaymentDetailID'nin sağlanması durumunda diğer ödeme detaylarının NULL olmasını kontrol eder.
-- Eğer PaymentDetailID sağlanmazsa, CardNumber, CardExpiryDate, CVV ve CardHolderName alanlarının NULL olmamasını sağlar.
DELIMITER //

CREATE TRIGGER ValidatePaymentDetail
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    -- Eğer PaymentDetails mevcutsa diğer alanlar NULL olmalı
    IF NEW.PaymentDetailID IS NOT NULL THEN
        IF NEW.CardNumber IS NOT NULL OR NEW.CardExpiryDate IS NOT NULL OR NEW.CVV IS NOT NULL OR NEW.CardHolderName IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PaymentDetails sağlandıysa diğer ödeme detayları NULL olmalı!';
        END IF;
    -- Eğer PaymentDetails mevcut değilse hiçbir alan NULL olmamalı
    ELSE
        IF NEW.CardNumber IS NULL OR NEW.CardExpiryDate IS NULL OR NEW.CVV IS NULL OR NEW.CardHolderName IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'PaymentDetails yoksa diğer ödeme detayları NULL olamaz!';
        END IF;
    END IF;
END;
//
DELIMITER ;


-- Review tablosu için aynı müşteri tarafından aynı ürüne yapılan tekrar yorumları engelleyen tetikleyici:
-- Bu tetikleyici, yeni bir yorum eklenirken, aynı müşteri ve aynı ürün için daha önce yapılmış bir yorumun olup olmadığını kontrol eder.
-- Eğer daha önce yapılmış bir yorum varsa hata fırlatır.
DELIMITER //

CREATE TRIGGER PreventDuplicateReview
BEFORE INSERT ON Review
FOR EACH ROW
BEGIN
    DECLARE review_count INT;

    -- Aynı müşterinin aynı ürüne yaptığı yorumların sayısını kontrol et
    SELECT COUNT(*)
    INTO review_count
    FROM Review
    WHERE CustomerID = NEW.CustomerID
      AND ProductID = NEW.ProductID;

    -- Eğer zaten bir yorum yaptıysa hata fırlat
    IF review_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bu müşteri bu ürüne zaten bir yorum yapmış!';
    END IF;
END;
//
DELIMITER ;


-- OrderItem tablosu için stok güncellemesini yapan tetikleyici:
-- Bu tetikleyici, yeni bir sipariş maddesi eklendiğinde stok miktarını günceller.
-- İlgili ürünün stok miktarı sıfırın altına düşerse hata fırlatır ve işlem tamamlanmaz.
DELIMITER //

CREATE TRIGGER UpdateStockOnOrder
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
    DECLARE inventory_id INT;
    DECLARE barcode CHAR(13);

    -- İlgili InventoryID ve Barcode değerlerini ProductStock tablosundan al
    SELECT InventoryID, Barcode
    INTO inventory_id, barcode
    FROM ProductStock
    WHERE ProductID = NEW.ProductID
    LIMIT 1;

    -- Stok miktarını güncelle
    UPDATE Stock
    SET Quantity = Quantity - NEW.Quantity
    WHERE InventoryID = inventory_id
      AND Barcode = barcode;

    -- Stok miktarını kontrol et, negatif olmamalı
    IF (SELECT Quantity FROM Stock WHERE InventoryID = inventory_id AND Barcode = barcode) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stok yetersiz! Sipariş işlenemez.';
    END IF;
END;
//

DELIMITER ;

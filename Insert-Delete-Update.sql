-- Product table

INSERT INTO Product (ProductID, ProductName, Information, Brand, Price, Properties, SellerID,ShippingCost)
VALUES (23, 'Akıllı Saat', 'Su geçirmez, GPS özellikli', 'TeknoMark', 1500.00, 'Renk: Siyah, Ağırlık: 50g', 26,50);

DELETE FROM Product
WHERE ProductID = 21;

UPDATE Product
SET Properties = 'Malzeme: Ahşap, Renk: Sarı'
WHERE ProductID = 1;





-- User Table

INSERT INTO `User` (Password, BirthDate, RegistrationDate, Email, PhoneNumber)
VALUES ('password123', '1995-06-15', CURDATE(), 'Amin@example.com', '05551234567');



DELETE FROM `User`
WHERE UserID = 9;


UPDATE `User`
SET Email = 'newemail@example.com', PhoneNumber = '05557654321'
WHERE UserID = 2;




-- Campaign Table

INSERT INTO Campaign (CampaignID, Name, Description, StartDate, EndDate, IsPromotion, PromotionType, PromotionStartDate, PromotionEndDate, PromotionConditions, Status, IsDiscount, DiscountType, DiscountStartDate, DiscountEndDate, DiscountValue, DiscountConditions)
VALUES
-- 1. Promotion ve Discount birlikte kullanılıyor
(9, 'Ramazan Kampanyası', 'Gıda ürünlerinde 10%.', '2025-03-01', '2025-03-29', FALSE,  NULL, NULL, NULL, NULL, NULL, TRUE, 'Percentage', '2025-03-01', '2025-03-29', 10.00, 'Gıda ürünlerinde geçerlidir.')
;

DELETE FROM Campaign
WHERE CampaignID = 1;

UPDATE Campaign
SET EndDate = '2025-05-30'
WHERE CampaignID = 2;




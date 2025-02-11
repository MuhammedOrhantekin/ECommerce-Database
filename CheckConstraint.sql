-- Review tablosu için Check Constraint:
-- Bu kısıtlama, Rating (Puan) değerinin 1 ile 5 arasında olmasını sağlar.
ALTER TABLE Review
ADD CONSTRAINT CheckReviewRating
CHECK (Rating BETWEEN 1 AND 5);


-- PaymentDetail tablosu için Check Constraint:
-- Bu kısıtlama, CVV alanının uzunluğunun 3 haneli olmasını ve sadece rakamlardan oluşmasını sağlar.
ALTER TABLE PaymentDetail
ADD CONSTRAINT CheckCardCVVLength
CHECK (LENGTH(CVV) = 3 AND CVV REGEXP '^[0-9]{3}$');


-- User tablosu için Check Constraint:
-- Bu kısıtlama, Email alanının geçerli bir e-posta formatında olmasını sağlar.
-- Geçerli format örneği: "example@domain.com"
ALTER TABLE `User`
ADD CONSTRAINT CheckEmailFormat
CHECK (Email LIKE '%_@__%.__%');

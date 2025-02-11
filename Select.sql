
-- 2 tabloyu ilgilendiren SELECT sorguları:

-- Satıcı ve stok bilgilerini listeleyen sorgu:
-- Bu sorgu, ürün adı, satıcının adı, mağaza adı ve stok miktarını listelemektedir.
SELECT P.ProductName, S.FirstName AS SellerName, S.StoreName, ST.Quantity
FROM Product P
JOIN Seller S ON P.SellerID = S.SellerID
JOIN ProductStock PS ON P.ProductID = PS.ProductID
JOIN Stock ST ON PS.InventoryID = ST.InventoryID AND PS.Barcode = ST.Barcode;

-- Müşteri ürün incelemelerini listeleyen sorgu:
-- Bu sorgu, müşteri adını, ürün adını, mağaza adını, ürün puanını ve yorumu listelemektedir.
SELECT CUS.FirstName, CUS.LastName, P.ProductName, S.StoreName, R.Rating, R.Comment
FROM Customer CUS
JOIN Review R ON CUS.CustomerID = R.CustomerID
JOIN Product P ON R.ProductID = P.ProductID
JOIN Seller S ON P.SellerID = S.SellerID;


-- 3 tabloyu ilgilendiren SELECT sorguları:

-- Sipariş, müşteri ve kargo detaylarını listeleyen sorgu:
-- Bu sorgu, müşterinin adı, sipariş bilgileri, kargo takip numarası ve teslimat durumunu listelemektedir.
SELECT 
    C.FirstName AS CustomerFirstName,
    C.LastName AS CustomerLastName,
    O.OrderNo,
    O.OrderDate,
    O.TotalAmount,
    S.AddressTitle,
    S.City,
    S.District,
    S.Neighborhood,
    SH.TrackingNumber,
    SH.DeliveryStatus
FROM Customer C
JOIN `User` U ON C.CustomerID = U.UserID
JOIN `Order` O ON C.CustomerID = O.CustomerID
JOIN ShippingDetail S ON O.ShippingID = S.ShippingID
LEFT JOIN Shipment SH ON O.LogisticID = SH.LogisticID;

-- Satıcıların stok bilgileri ve ürün detaylarını listeleyen sorgu:
-- Bu sorgu, mağaza adı, ürün adı, stok miktarı, liste fiyatı ve satıcı türü bilgilerini döndürür.
SELECT S.StoreName, P.ProductName, ST.Quantity, ST.ListPrice, S.SellerType, S.StoreRating
FROM Seller S
JOIN Inventory I ON S.SellerID = I.SellerID
JOIN Stock ST ON I.InventoryID = ST.InventoryID
JOIN ProductStock PS ON ST.InventoryID = PS.InventoryID AND ST.Barcode = PS.Barcode
JOIN Product P ON PS.ProductID = P.ProductID;

-- Sipariş ürünleri ve müşteri detaylarını listeleyen sorgu:
-- Bu sorgu, müşteri adı, sipariş numarası, ürün adı ve ürün miktarını listelemektedir.
SELECT CUS.FirstName, CUS.LastName, O.OrderNo, P.ProductName, OI.Quantity
FROM Customer CUS
JOIN `Order` O ON CUS.CustomerID = O.CustomerID
JOIN OrderItem OI ON O.OrderNo = OI.OrderNo AND O.CustomerID = OI.CustomerID
JOIN Product P ON OI.ProductID = P.ProductID;





-- 5 kritik SELECT sorgusu:

-- Aynı barkodlu ürünlerin satıcı ve fiyat detayları:
-- Bu sorgu, aynı barkoda sahip ürünlerin farklı satıcıdaki fiyatlarını ve açıklamalarını listelemektedir.
SELECT 
    PS.Barcode,
    P.ProductName,
    S.SellerID,
    S.StoreName,
    S.StoreRating, -- Satıcı Puanı
    P.Information, -- Ürün Açıklaması
    P.ShippingCost,
    P.Price AS ProductPrice
FROM 
    ProductStock PS
JOIN 
    Product P ON PS.ProductID = P.ProductID
JOIN 
    Seller S ON P.SellerID = S.SellerID
WHERE 
    PS.Barcode IN (
        SELECT Barcode
        FROM ProductStock PS1
        JOIN Product P1 ON PS1.ProductID = P1.ProductID
        JOIN Seller S1 ON P1.SellerID = S1.SellerID
        GROUP BY PS1.Barcode
        HAVING COUNT(DISTINCT S1.SellerID) > 1 -- Farklı satıcı sayısını kontrol eder
    )
GROUP BY 
    PS.Barcode, P.ProductName, S.SellerID, S.StoreName, S.StoreRating, P.Information, P.ShippingCost, P.Price
ORDER BY 
    PS.Barcode, P.Price;


-- Kampanya ve indirim detayları:
-- Bu sorgu, kampanyalara dahil olan ürünlerin indirim sonrası fiyatlarını ve kampanya detaylarını listelemektedir.
SELECT 
    CU.FirstName, 
    CU.LastName, 
    P.ProductName, 
    P.Price, 
    C.Name AS CampaignName,
    C.IsDiscount,
    C.DiscountType,
    C.DiscountValue,
    C.IsPromotion,
    C.PromotionType,
    C.PromotionConditions,
    
    CASE 
        WHEN C.IsDiscount = TRUE THEN 
            CASE 
                WHEN C.DiscountType = 'Percentage' THEN P.Price - (P.Price * C.DiscountValue / 100)
                WHEN C.DiscountType = 'Flat' THEN P.Price - C.DiscountValue
                ELSE P.Price
            END
        ELSE P.Price
    END AS PriceAfterDiscount,
    
    CASE 
        WHEN C.IsPromotion = TRUE THEN 
            CASE 
                WHEN C.PromotionType = 'FreeShipping' THEN CONCAT('Free Shipping Applied')
                WHEN C.PromotionType = 'BuyOneGetOne' THEN CONCAT('Eligible for Buy 1 Get 1 Offer')
                ELSE 'Promotion Applied'
            END
        ELSE 'No Promotion'
    END AS PromotionDetails
FROM Customer CU
JOIN ShoppingCart SC ON CU.ShoppingCartID = SC.ShoppingCartID
JOIN CartItems CI ON SC.ShoppingCartID = CI.ShoppingCartID
JOIN Product P ON CI.ProductID = P.ProductID
JOIN CampaignCart CC ON SC.ShoppingCartID = CC.ShoppingCartID
JOIN Campaign C ON CC.CampaignID = C.CampaignID;


-- Teslimat gecikmelerini listeleyen sorgu:
-- Bu sorgu, siparişlerin teslimat durumlarını ve gecikme günlerini hesaplamaktadır.
SELECT 
    O.OrderNo, 
    CU.FirstName, 
    CU.LastName, 
    S.TrackingNumber, 
    S.CarrierName, 
    S.DeliveryStatus, 
    S.EstimatedDeliveryDate, 
    S.DeliveryDate,
    DATEDIFF(S.DeliveryDate, S.EstimatedDeliveryDate) AS DelayDays
FROM `Order` O
JOIN Customer CU ON O.CustomerID = CU.CustomerID
JOIN Shipment S ON O.LogisticID = S.LogisticID
WHERE S.DeliveryStatus = 'Delivered';


-- Satıcıların en çok sattığı ürünler:
-- Bu sorgu, her satıcının en çok satış yaptığı ürünleri ve toplam satış miktarlarını listeler.
SELECT S.StoreName, S.SellerType, S.SalesCategoryType,  P.ProductName, SUM(OI.Quantity) AS TotalSold
FROM Seller S
JOIN Product P ON S.SellerID = P.SellerID
JOIN OrderItem OI ON P.ProductID = OI.ProductID
GROUP BY S.SellerID, P.ProductID
ORDER BY S.StoreName, TotalSold DESC;


-- Düşük stok seviyesindeki ürünler:
-- Bu sorgu, depolardaki düşük stok seviyesine sahip ürünleri ve bu ürünlerin detaylarını listeler.
SELECT P.ProductName, ST.Barcode, ST.Quantity, I.InventoryName, I.AdressLine, S.StoreName
FROM Stock ST
JOIN ProductStock PS ON ST.InventoryID = PS.InventoryID AND ST.Barcode = PS.Barcode
JOIN Product P ON PS.ProductID = P.ProductID
JOIN Inventory I ON ST.InventoryID = I.InventoryID
JOIN Seller S ON I.SellerID = S.SellerID
WHERE ST.Quantity < 20
ORDER BY ST.Quantity ASC;


#Her bir kullanıcı için en son yapılan sipariş ve siparişin toplam tutarı
#Bu sorgu, her bir kullanıcı için en son yapılan sipariş bilgilerini ve sipariş toplam tutarını listeler.

SELECT 
    CUS.FirstName, 
    CUS.LastName, 
    MAX(O.OrderDate) AS LastOrderDate, 
    SUM(O.TotalAmount) AS TotalSpent,
    COUNT(DISTINCT OI.OrderItemNo) AS TotalOrderItems,
    GROUP_CONCAT(P.ProductName ORDER BY P.ProductName ASC SEPARATOR ', ') AS ProductNames,
    GROUP_CONCAT(OI.Quantity ORDER BY P.ProductName ASC SEPARATOR ', ') AS Quantities,
    GROUP_CONCAT(OI.ItemStatus ORDER BY P.ProductName ASC SEPARATOR ', ') AS ItemStatuses
FROM Customer CUS
JOIN `Order` O ON CUS.CustomerID = O.CustomerID
JOIN OrderItem OI ON O.OrderNo = OI.OrderNo
JOIN Product P ON OI.ProductID = P.ProductID
GROUP BY CUS.CustomerID
ORDER BY LastOrderDate DESC;




-- 1.iterasyon

CREATE TABLE IF NOT EXISTS `User` (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    `Password` VARCHAR(255) NOT NULL,
    BirthDate DATE NULL,
    RegistrationDate DATE NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS Campaign (
    CampaignID INT PRIMARY KEY AUTO_INCREMENT,
    `Name` VARCHAR(255) NOT NULL,
    `Description` TEXT,
    StartDate DATE,
    EndDate DATE
);



CREATE TABLE if not exists ShippingDetail (
    ShippingID INT PRIMARY KEY AUTO_INCREMENT,
    AddressTitle VARCHAR(255) NOT NULL,
    AddressLine VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    District VARCHAR(100) NOT NULL,
    Neighborhood VARCHAR(100) NOT NULL,
    BillType ENUM('Personal', 'Corporate') NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL
);


CREATE TABLE if not exists Subscription (
    SubscriptionID INT PRIMARY KEY AUTO_INCREMENT, 
    StartDate DATE NOT NULL,
    EndDate DATE,
    RenewalDate DATE NOT NULL,             
    Fee DECIMAL(10, 2) NOT NULL            
);


CREATE TABLE IF NOT EXISTS PaymentDetail (
    PaymentDetailID INT PRIMARY KEY AUTO_INCREMENT,
    CardNumber VARCHAR(16) NOT NULL,
    CardExpiryDate DATE NOT NULL,
    CardholderName VARCHAR(100) NOT NULL,
    CVV VARCHAR(3) NOT NULL
);


CREATE TABLE IF NOT EXISTS Inventory (
	InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    AdressLine VARCHAR(255) NOT NULL,
    `InventoryName` VARCHAR(255) NOT NULL
);


CREATE TABLE IF NOT EXISTS Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(255) NOT NULL,
    Information TEXT,
    Brand VARCHAR(100),
    Price DECIMAL(10, 2) NOT NULL,
    Properties TEXT
);

CREATE TABLE IF NOT EXISTS Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS Logistic (
    LogisticID INT PRIMARY KEY AUTO_INCREMENT
);


CREATE TABLE IF NOT EXISTS Shipment (
    TrackingNumber VARCHAR(50) PRIMARY KEY,
    PackageWeight DECIMAL(10, 2) NOT NULL,
    PackageDimension VARCHAR(100) NOT NULL,
    CarrierName VARCHAR(100) NOT NULL,
    DeliveryStatus ENUM('In Transit', 'Out for Delivery', 'Delivered') NOT NULL,
    DeliveryDate DATE ,
    EstimatedDeliveryDate DATE NOT NULL,
    ShipmentDate DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    PaymentAmount DECIMAL(10, 2) NOT NULL,
    PaymentMethod ENUM('CreditCard', 'DebitCard') NOT NULL,
    CardNumber VARCHAR(16) NULL,
    CardExpiryDate DATE NULL,
    CardholderName VARCHAR(100) NULL,
    CVV VARCHAR(3) NULL
);


CREATE TABLE IF NOT EXISTS PromotionCode (
    PromotionCodeID INT PRIMARY KEY AUTO_INCREMENT,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CodeType ENUM('Coupon', 'GiftCard', 'Code') NOT NULL,
    Information TEXT
);


CREATE TABLE IF NOT EXISTS ShoppingCart (
    ShoppingCartID INT PRIMARY KEY AUTO_INCREMENT
);


CREATE TABLE Stock (
    InventoryID INT NOT NULL,
    Barcode CHAR(13) NOT NULL,
    Quantity INT NOT NULL, 
    ListPrice DECIMAL(10, 2),
    PRIMARY KEY (InventoryID, Barcode),     
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID) 
    ON DELETE CASCADE 
	ON UPDATE CASCADE  
);


CREATE TABLE IF NOT EXISTS AppliedToPayment (
    PaymentID INT PRIMARY KEY,
    PromotionCodeID INT UNIQUE ,
    FOREIGN KEY (PromotionCodeID) REFERENCES PromotionCode(PromotionCodeID) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE Subscription
ADD COLUMN UserID INT NOT NULL,
ADD CONSTRAINT FK_Subscription_User FOREIGN KEY (UserID) REFERENCES User(UserID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT UC_Subscription_User UNIQUE (UserID);


CREATE TABLE ProductStock (
    ProductID INT ,            
    Barcode CHAR(13)  ,
    InventoryID INT , 
    PRIMARY KEY (ProductID,Barcode,InventoryID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
	
    FOREIGN KEY (InventoryID, Barcode) REFERENCES Stock(InventoryID, Barcode) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);



ALTER TABLE ShippingDetail
ADD COLUMN UserID INT NOT NULL,
ADD FOREIGN KEY (UserID) REFERENCES User(UserID)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


ALTER TABLE PaymentDetail
ADD COLUMN UserID INT NOT NULL,
ADD FOREIGN KEY (UserID) REFERENCES User(UserID)
	ON DELETE CASCADE
    ON UPDATE CASCADE;



ALTER TABLE Category
ADD COLUMN ParentCategoryID INT NULL,
ADD CONSTRAINT FK_Category_SubCategory FOREIGN KEY (ParentCategoryID) REFERENCES Category(CategoryID)
ON DELETE SET NULL
ON UPDATE CASCADE;


ALTER TABLE Payment
ADD COLUMN PaymentDetailID INT,
ADD CONSTRAINT FK_Payment_PaymentDetail FOREIGN KEY (PaymentDetailID) REFERENCES PaymentDetail(PaymentDetailID)
ON DELETE SET NULL
ON UPDATE CASCADE;


ALTER TABLE Shipment
ADD COLUMN LogisticID INT NOT NULL,
ADD CONSTRAINT FK_Shipment_Logistic FOREIGN KEY (LogisticID) REFERENCES Logistic(LogisticID)
ON DELETE RESTRICT
ON UPDATE CASCADE;




CREATE TABLE IF NOT EXISTS CampaignCart (
    CampaignID INT NOT NULL,
    ShoppingCartID INT NOT NULL,
    PRIMARY KEY (CampaignID, ShoppingCartID),
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ShoppingCartID) REFERENCES ShoppingCart(ShoppingCartID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS CampaignProduct (
    CampaignID INT NOT NULL,
    ProductID INT NOT NULL,
    PRIMARY KEY (CampaignID, ProductID),
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS CategoryProduct (
    CategoryID INT NOT NULL,
    ProductID INT NOT NULL,
    PRIMARY KEY (CategoryID, ProductID),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS CartItems (
    ProductID INT NOT NULL,
    ShoppingCartID INT NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (ProductID, ShoppingCartID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ShoppingCartID) REFERENCES ShoppingCart(ShoppingCartID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS UserLastLogin (
    UserID INT NOT NULL,
    LastLogin DATETIME NOT NULL,
    PRIMARY KEY (UserID, LastLogin),
    FOREIGN KEY (UserID) REFERENCES User(UserID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Seller (
    SellerID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    StoreName VARCHAR(255) NOT NULL,
    TaxID VARCHAR(50) NOT NULL,
    StoreRating DECIMAL(3, 2),
    SellerType ENUM('Individual', 'Corporate') NOT NULL,
    StoreDate DATE NOT NULL,
    TotalSellNumber INT,
    IbanNo VARCHAR(50),
    SalesCategoryType VARCHAR(255),
    FOREIGN KEY (SellerID) REFERENCES `User`(UserID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Customer (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES `User`(UserID)
    ON DELETE CASCADE
	ON UPDATE CASCADE
);

ALTER TABLE Campaign
    ADD COLUMN IsPromotion BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN PromotionType ENUM('Seasonal', 'LimitedTime', 'NewArrival', 'Clearance', 'BuyOneGetOne'),
    ADD COLUMN PromotionStartDate DATE,
    ADD COLUMN PromotionEndDate DATE,
    ADD COLUMN PromotionConditions TEXT,
    ADD COLUMN `Status` ENUM('Active', 'Upcoming', 'Expired', 'Cancelled'),
    ADD COLUMN IsDiscount BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN DiscountType ENUM('Flat', 'Percentage', 'FreeShipping'),
    ADD COLUMN DiscountStartDate DATE,
    ADD COLUMN DiscountEndDate DATE,
    ADD COLUMN DiscountValue DECIMAL(10, 2),
    ADD COLUMN DiscountConditions TEXT;





-- 2.iterasyon

CREATE TABLE IF NOT EXISTS `Order` (
    OrderNo INT NOT NULL,
    CustomerID INT NOT NULL,
    ShoppingCartID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderStatus ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (OrderNo, CustomerID, ShoppingCartID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (ShoppingCartID) REFERENCES ShoppingCart(ShoppingCartID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);




CREATE TABLE IF NOT EXISTS Collection (
    CollectionName VARCHAR(255) NOT NULL,
    CustomerID INT NOT NULL,
    PRIMARY KEY (CollectionName, CustomerID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);




ALTER TABLE `Order`
ADD COLUMN PaymentID INT NOT NULL,
ADD COLUMN PaymentDate DATE ,
ADD COLUMN PaymentStatus ENUM('Completed', 'Failed', 'Cancelled') NOT NULL,
ADD CONSTRAINT FK_Order_Payment FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT UC_Order_Payment UNIQUE (PaymentID);

ALTER TABLE `Order`
ADD COLUMN LogisticID INT NOT NULL,
ADD CONSTRAINT FK_Order_Logistic FOREIGN KEY (LogisticID) REFERENCES Logistic(LogisticID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT UC_Order_Logistic UNIQUE (LogisticID);


ALTER TABLE Customer
ADD COLUMN ShoppingCartID INT NOT NULL,
ADD CONSTRAINT FK_Customer_ShoppingCart FOREIGN KEY (ShoppingCartID) REFERENCES ShoppingCart(ShoppingCartID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
ADD CONSTRAINT UQ_Customer_ShoppingCart UNIQUE (ShoppingCartID);



ALTER TABLE PromotionCode
ADD COLUMN CustomerID INT,
ADD FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


ALTER TABLE Product
ADD COLUMN SellerID INT NOT NULL,
ADD COLUMN ShippingCost INT NOT NULL DEFAULT 0,
ADD FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


ALTER TABLE Payment
ADD COLUMN CustomerID INT NOT NULL,
ADD FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


ALTER TABLE Inventory
ADD COLUMN SellerID INT NOT NULL,
ADD FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE;


ALTER TABLE `Order`
ADD COLUMN ShippingID INT NOT NULL,
ADD FOREIGN KEY (ShippingID) REFERENCES ShippingDetail(ShippingID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;


CREATE TABLE IF NOT EXISTS Follow (
    SellerID INT NOT NULL,
    CustomerID INT NOT NULL,
    PRIMARY KEY (SellerID, CustomerID),
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS SellerCampaign (
    SellerID INT NOT NULL,
    CampaignID INT NOT NULL,
    PRIMARY KEY (SellerID, CampaignID),
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);



CREATE TABLE IF NOT EXISTS CollectionHas (
    CollectionName VARCHAR(255) NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    PRIMARY KEY (CollectionName, CustomerID, ProductID),
    FOREIGN KEY (CollectionName, CustomerID) REFERENCES Collection(CollectionName, CustomerID) 
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);




-- 3.iterasyon

CREATE TABLE IF NOT EXISTS OrderItem (
    OrderNo INT NOT NULL,
    CustomerID INT NOT NULL,
    ShoppingCartID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderItemNo INT NOT NULL,
    Quantity INT NOT NULL,
    ItemStatus ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') NOT NULL,
    PRIMARY KEY (OrderNo, CustomerID, ShoppingCartID, ProductID, OrderItemNo),
    FOREIGN KEY (OrderNo, CustomerID, ShoppingCartID) REFERENCES `Order`(OrderNo, CustomerID, ShoppingCartID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


ALTER TABLE OrderItem
ADD COLUMN TrackingNumber VARCHAR(50) ,
ADD FOREIGN KEY (TrackingNumber) REFERENCES Shipment(TrackingNumber)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
    
    
    
-- 4.İterasyon
CREATE TABLE IF NOT EXISTS Review (
	ReviewNo INT NOT NULL,
    OrderNo INT NOT NULL,
    CustomerID INT NOT NULL,
    ShoppingCartID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderItemNo INT NOT NULL,
    ReviewDate DATE NOT NULL,
    Rating INT NOT NULL ,
    `Comment` TEXT NULL,
    PRIMARY KEY (OrderNo, CustomerID, ShoppingCartID, ProductID, OrderItemNo,ReviewNo),
    FOREIGN KEY (OrderNo, CustomerID, ShoppingCartID, ProductID, OrderItemNo) REFERENCES OrderItem(OrderNo, CustomerID, ShoppingCartID, ProductID, OrderItemNo)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- view combining 4 tables to get the shop name, customer name and driver name
-- this info would be required to send the customer an email confirming the order

CREATE VIEW Order_Details AS 
SELECT o.Order_ID, s.Shop_name, c.Full_name, d.Driver_name
FROM Order_Table o
INNER JOIN Shop_Table s ON o.Shop_ID = s.Shop_ID
INNER JOIN Customer_Table c ON o.Customer_ID = c.Customer_ID
INNER JOIN Driver_Table d ON d.Driver_ID = o.Driver_ID
WHERE Order_ID = 'the order ID you are searching for';

-- To see the items from a particular shop

SELECT i.Item_name 
FROM Item_Table i
INNER JOIN Shop_Table s ON i.Shop_ID = s.Shop_ID
WHERE Shop_name = 'the name of the shop you want to see items from';

-- Too see all the shops in the area of a particular customer

SELECT s.Shop_name 
FROM Shop_Table s
INNER JOIN Customer_Table c ON c.Zone_ID = s.Zone_ID
WHERE c.Customer_ID = 'ID of the customer you want to see shops for';

-- To search for shops in a particular category

SELECT s.Shop_name, c.Category_name 
FROM Shop_Table s
INNER JOIN Category_Table c ON c.Category_ID = s.Category_ID
WHERE c.Category_name = 'the category you are looking for e.g. groceries';

-- To get the details of the driver that delivered a particular order

SELECT d.Driver_name, d.Email 
FROM Driver_Table d
INNER JOIN Order_Table o ON o.Driver_ID = d.Driver_ID
WHERE Order_ID = 'the order number you are searching for';

-- To see a list of items from a particular order

SELECT i.Item_name
FROM Item_table i 
INNER JOIN Items_Order_Table o ON o.Item_ID = o.Item_ID
WHERE Order_ID = 'the order number for this order';


-- stored function to apply 15% discount to an order 
DELIMITER //
CREATE FUNCTION apply_discount(price_before_discount decimal(6,2)) RETURNS decimal(6,2) DETERMINISTIC
BEGIN
  RETURN 0.85 * price_before_discount;
END 
//
DELIMITER ;

-- apply stored function to an order 

SELECT Order_ID, Price, apply_discount(Price) AS "Price After Discount"
from Order_Table
WHERE Order_ID = 'order ID you want to apply it to';


-- to find customers' overall spend through the app 

SELECT c.Full_name AS "Customer Name", SUM(o.Price) AS "Total Spend"
FROM Order_Table o
INNER JOIN Customer_Table c ON c.Customer_ID = o.Customer_ID
GROUP BY c.Full_name
ORDER BY SUM(o.Price) DESC;


--subquery
-- To see all the items which are available for delivery 
SELECT Item_name FROM Item_table
WHERE Shop_ID IN
(SELECT Shop_ID FROM Shop_Table WHERE Delivery = True)


-- Trigger function to validate email address

CREATE TRIGGER validate_email 
	BEFORE INSERT
	ON Customer_Table
	FOR EACH ROW
BEGIN
	IF NEW.Email NOT LIKE '%_@%_.__%' THEN
		
		SET NEW.Email = NULL;
	END IF;
END;


-- Event 

SET GLOBAL event_scheduler = ON;


CREATE TABLE orders_tracker
(ID INT NOT NULL AUTO_INCREMENT, 
Last_Update TIMESTAMP,
Numer_of_Orders INT,
PRIMARY KEY (ID));

DELIMITER //

CREATE EVENT count_orders
ON SCHEDULE AT NOW() + INTERVAL 1 MINUTE
DO BEGIN
	INSERT INTO orders_tracker(Last_Update, Number_of_Orders)
	VALUES (NOW(), (SELECT COUNT(*) FROM Order_Table));
END//

DELIMITER ;








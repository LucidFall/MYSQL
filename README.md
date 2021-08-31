# Demonstration of sql skills

The database_creating sql file create the database the following code is working on. (generated with MySQLWorkbench forward engineering on my EER diagram)

The following is the demonstration of my sql skills (triggers, events and stored procedures). The database is aimed to store customer, product in stock and payment informations. Which has the following table and its functionality specified below:

+ customers: this contains basic customer information with points recorded
+ orders: this contains an overview of the order (amount due/paid with customer id recorded)
+ order_details: this record the amount of each type of product purchased as long as specific instruction from the buyer to each product they bought.
+ payments: this record all payments made from buyer to each order. 
+ products: keep track of the number of product still in stock with their price.

## Triggers

The following is triggered whenever a client makes a payment on an order, it automatically update orders' amount_paid. 

first create various log files including payment log, points log and product stock log
```sql
USE store_db;
DROP TABLE IF EXISTS payment_log;

CREATE TABLE payment_log
(
    log_id_pay    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id INT     NOT NULL,
    date    DATE    NOT NULL,
    amount    FLOAT  NOT NULL,
    action_type VARCHAR(45) NOT NULL,
    action_date DATETIME,
    PRIMARY KEY(log_id_pay)
);

DROP TABLE IF EXISTS point_log;

CREATE TABLE point_log
(
    log_id_point    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id INT     NOT NULL,
    date    DATE    NOT NULL,
    points INT    NOT NULL,
    PRIMARY KEY(log_id_point)
)

DROP TABLE IF EXISTS stock_log;

CREATE TABLE stock_log
(
    log_id_stock    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id INT     NOT NULL,
    date    DATE    NOT NULL,
    action_type VARCHAR(45) NOT NULL,
    PRIMARY KEY(log_id_stock)
)
```

then create trigger what gets triggered whenever a payment happens, it update the amount paid along with points with log recorded:
```sql
DELIMITER $$

DROP TRIGGER IF EXISTS payments_after_update$$

CREATE TRIGGER payments_after_update
  AFTER INSERT ON payments
    FOR EACH ROW
        
  BEGIN
    UPDATE orders
    SET amount_paid = amount_paid + NEW.amount
    WHERE order_id = NEW.order_id;
            
    INSERT INTO payment_log
    VALUES(DEFAULT, NEW.customer_id, NEW.payment_date, NEW.amount, 'pay', now());
            
    UPDATE customers
    SET points = points + floor(NEW.amount * 10)
    WHERE customer_id = NEW.customer_id;
            
    INSERT INTO point_log
    VALUES(DEFAULT, NEW.customer_id, NEW.payment_date, floor(NEW.amount * 10));
            
    END $$

DELIMITER ;
```

the following is a trigger for when a purchase is made and product stock amount gets updated with log recorded.
```sql
DELIMITER $$

DROP TRIGGER IF EXISTS stock_after_purchase$$

CREATE TRIGGER stock_after_purchase
  AFTER INSERT ON order_detail
    FOR EACH ROW
  
    BEGIN
    UPDATE products
        SET num_in_stock = num_in_stock - NEW.quantity
        WHERE product_id = NEW.product_id;
        
        INSERT INTO stock_log
        VALUES(DEFAULT, NEW.product_id, NOW(), 'bought');
    END $$

DELIMITER ;
```

Creating events that delete log data that stored 1 year long to save spaces.
```sql
DELIMITER $$
DROP EVENT IF EXISTS yearly_delete_payment_audit$$
CREATE EVENT yearly_delete_payment_audit
ON SCHEDULE
  EVERY 1 YEAR STARTS '2021-01-01'
DO BEGIN
  DELETE FROM payment_log
    WHERE date < NOW() - INTERVAL 1 YEAR;
END $$

DELIMITER ;
```

below is a helper function to calculate total unpaid amount of a given customer. 

```sql
DELIMITER $$

DROP FUNCTION IF EXISTS get_total_unpaid$$
CREATE FUNCTION get_total_unpaid(
  customer_id INT
)
RETURNS FLOAT
READS SQL DATA
  BEGIN
    DECLARE total_due FLOAT;
        DECLARE total_paid FLOAT;
        DECLARE total_unpaid FLOAT DEFAULT 0;
        
        SELECT SUM(amount_due), SUM(amount_paid)
        INTO total_due, total_paid
        FROM orders o
        WHERE o.customer_id  = customer_id;
        
        SET total_unpaid = total_due - total_paid;
        RETURN total_unpaid;
  END$$
DELIMITER ;
```

Below is a bunch of stored procedures to execute complex queries to both protect data integrity and easy access from outside emvironment like python and JAVA. 



+ get a table of client with their unpaid amount.
```sql
DELIMITER $$
DROP PROCEDURE IF EXISTS get_customer_payment_status$$
CREATE PROCEDURE get_customer_payment_status()
BEGIN
  SELECT c.customer_id, c.first_name, c.last_name, get_total_unpaid(c.customer_id)
    FROM customers c, orders o
    WHERE c.customer_id = o.customer_id;
END$$
DELIMITER ;
```

+ add stock to an existing product
```sql
DELIMITER $$

DROP PROCEDURE IF EXISTS add_stock$$

CREATE PROCEDURE add_stock (
  product_id INT,
    quantity INT
)
BEGIN
  UPDATE products p
    SET num_in_stock = num_in_stock + quantity
    WHERE  p.product_id = product_id;
END$$

DELIMITER ;
```


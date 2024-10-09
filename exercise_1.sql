--Exercise 1: Create a PostgreSQL Function
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INT)
RETURNS NUMERIC
AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM(od.unitprice * od.quantity * (1 - od.discount))
    INTO total
    FROM northwind.orders o
  JOIN northwind.order_details od USING(orderid)
    WHERE od.orderid = order_id;

    RETURN round(total,2);
END;
$$
LANGUAGE plpgsql;

select calculate_order_total(5);
--Exercise 2: Implement a Stored Procedure
CREATE PROCEDURE update_stock(product_id INT, quantity INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE northwind.products
    SET UnitsInStock = UnitsInStock + quantity
    WHERE "productid" = product_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'This product id #% is not found!!', product_id;
  END IF;
END;
$$;
select * from northwind.products;
-- this is for exception check, this is no product id 1111 , it should give error message
CALL update_stock(1111, 50);

-- updating product id 20 
CALL update_stock(20, 10);
-- to check updating value
SELECT * FROM northwind.products WHERE productid = 20;
-- to fix this error: ERROR:  function "update_stock" already exists with same argument types 
DROP PROCEDURE update_stock(product_id INT, quantity INT);
--exercise 3
-- Create a new table to log price updates
CREATE TABLE northwind.price_update_log (
    log_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES northwind.products(ProductID),
    old_price NUMERIC,
    new_price NUMERIC,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Define the log_price_update procedure
CREATE OR REPLACE FUNCTION northwind.log_price_update_function()
RETURNS TRIGGER --the function must return a trigger, otherwise it is not a trigger function
LANGUAGE plpgsql
AS $$
BEGIN
	--Checking if the price has changed
	IF OLD.unitprice <> NEW.unitprice THEN
		INSERT INTO northwind.price_update_log(product_id, product_new_price, product_old_price, updated_date)
		VALUES (OLD.productid, NEW.unitprice, OLD.unitprice, NOW());
	END if;
	RETURN NEW; --Return the new record
END;
$$;

-- Create the trigger
CREATE or replace TRIGGER log_price_update
AFTER UPDATE ON northwind.products
FOR EACH ROW
EXECUTE FUNCTION northwind.log_price_update_function();


-- Update the UnitPrice of a product
UPDATE northwind.products
SET UnitPrice = 25.00
WHERE ProductID = 11;

select *
from northwind.products;

--Exercise 4: Utilize Cursors in PL/pgSQL

DO
$$
DECLARE
   
    order_cursor CURSOR FOR
        SELECT OrderID FROM northwind.orders;
    order_rec RECORD; 
    order_total NUMERIC; 
BEGIN
    -- Open the cursor
    OPEN order_cursor; 

    
    LOOP
        FETCH NEXT FROM order_cursor INTO order_rec; 
        EXIT WHEN NOT FOUND; 

           order_total := calculate_order_total(order_rec.OrderID); 

          RAISE NOTICE 'Order ID: %, Total: %', order_rec.OrderID, order_total;
    END LOOP;

 
    CLOSE order_cursor;
END;
$$;


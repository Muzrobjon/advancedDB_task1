--Exercise 1: Create a PostgreSQL Function
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
--to check error
CALL update_stock(1111, 50);


CALL update_stock(20, 5);
SELECT * FROM northwind.products WHERE productid = 20;

DROP PROCEDURE update_stock(product_id INT, quantity INT);
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



DO
$$
DECLARE
	--declaring the cursor
	order_cursor CURSOR FOR
				SELECT *
				FROM northwind.orders;
	order_rec RECORD;
	order_total NUMERIC;
BEGIN
	OPEN order_cursor; 
	LOOP
		FETCH NEXT FROM order_cursor INTO order_rec; 
		EXIT WHEN NOT FOUND; -- exiting if no row left
		
		order_total = northwind.calculate_order_total(order_rec.orderid); 
		
		RAISE NOTICE 'Order id: %, Total: %', order_rec.orderid, order_total;
	END LOOP;
	
	CLOSE order_cursor;
END;
$$;

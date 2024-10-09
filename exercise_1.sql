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
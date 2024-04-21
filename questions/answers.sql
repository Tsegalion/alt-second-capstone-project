-- Question 1
-- This query determines the most popular product in successful orders

-- Select the product_id, product_name, and count the number of times each product appears in successful orders
SELECT 
    P.id AS product_id, 
    P.name AS product_name, 
    COUNT(*) AS num_times_in_successful_orders -- Count the number of times each product appears in successful orders
FROM 
    ALT_SCHOOL.LINE_ITEMS AS LI
JOIN 
    ALT_SCHOOL.ORDERS AS O ON LI.order_id = O.order_id 
JOIN 
    ALT_SCHOOL.PRODUCTS AS P ON LI.item_id = P.id -- Join with the PRODUCTS table on the item_id
JOIN 
    ALT_SCHOOL.EVENTS AS E ON E.customer_id = O.customer_id -- Join with the EVENTS table on the customer_id
WHERE 
    -- Filter for successful orders where the event type is 'add_to_cart' and the item_id matches the product_id
    O.status = 'success' AND E.event_data->>'event_type' = 'add_to_cart' AND E.event_data->>'item_id' = P.id::text
GROUP BY P.id, P.name
ORDER BY num_times_in_successful_orders DESC
LIMIT 1;



-- Question 2
-- This query determines the top 5 customers who have spent the most on successful orders

-- Select the customer_id, location, and calculate the total spend for each customer
SELECT 
    C.customer_id AS customer_id, 
    C.location, 
    SUM(P.price * (E.event_data->>'quantity')::int) AS total_spend -- Calculate the total spend by multiplying the price of each product by the quantity added to the cart
FROM 
    ALT_SCHOOL.CUSTOMERS AS C
JOIN 
    ALT_SCHOOL.EVENTS AS E ON E.customer_id = C.customer_id -- Join with the EVENTS table on the customer_id
JOIN 
    ALT_SCHOOL.PRODUCTS AS P ON P.id = (E.event_data->>'item_id')::int -- Join with the PRODUCTS table on the item_id
JOIN 
    ALT_SCHOOL.ORDERS AS O ON O.customer_id = C.customer_id -- Join with the ORDERS table on the customer_id
WHERE 
    -- Filter for successful orders where the event type is 'add_to_cart'
    O.status = 'success' AND E.event_data->>'event_type' = 'add_to_cart'
GROUP BY C.customer_id, C.location
ORDER BY total_spend DESC
LIMIT 5; -- Limit the results to the top 5 customers with the highest total spend



-- Question 3
-- This query determines the most common location where successful checkouts occurred

-- Select the location and count the number of checkouts for each location
SELECT 
    C.location, 
    COUNT(*) AS checkout_count
FROM 
    ALT_SCHOOL.EVENTS AS E
JOIN 
    ALT_SCHOOL.CUSTOMERS AS C ON E.customer_id = C.customer_id -- Join with the CUSTOMERS table on the customer_id
JOIN 
    ALT_SCHOOL.ORDERS AS O ON O.customer_id = C.customer_id -- Join with the ORDERS table on the customer_id
WHERE 
    -- Filter for successful checkouts
    O.status = 'success' AND E.event_data->>'event_type' = 'checkout'
GROUP BY C.location
ORDER BY checkout_count DESC
LIMIT 1;



-- Question 4
-- This query identifies customers who have abandoned their carts and counts the number of events (excluding 'visit' events) that occurred before the abandonment
SELECT 
    E.customer_id,
    COUNT(*) AS num_events
FROM 
    ALT_SCHOOL.EVENTS AS E
WHERE 
    -- Filtering events to include only cart modification events
    E.event_data->>'event_type' IN ('add_to_cart', 'remove_from_cart')
    AND E.customer_id NOT IN (  -- Excluding customers who have any checkout events
        SELECT 
            DISTINCT E.customer_id
        FROM 
            ALT_SCHOOL.EVENTS AS E
        WHERE 
            E.event_data->>'event_type' = 'checkout'
    )
GROUP BY E.customer_id
ORDER BY num_events DESC


   
-- Question 5
-- This query calculates the average number of 'visit' events for customers who have successfully checked out
SELECT 
    ROUND(AVG(num_visits), 2) AS average_visits  -- Round the average number of visits to two decimal places
FROM (
    -- Subquery to count visits per customer who successfully checked out
    SELECT 
        E.customer_id, 
        COUNT(*) AS num_visits  -- Count the number of visit events per customer
    FROM 
        ALT_SCHOOL.EVENTS AS E
    WHERE 
        E.event_data->>'event_type' = 'visit'  -- Filter events to include only 'visit' types
        AND E.customer_id IN (
            -- Subquery to identify customers who have a successful checkout
            SELECT 
                E.customer_id 
            FROM 
                ALT_SCHOOL.EVENTS AS E 
            WHERE 
                E.event_data->>'event_type' = 'checkout'
                AND E.event_data->>'status' = 'success'
        )
    GROUP BY E.customer_id
) AS visits_per_customer;
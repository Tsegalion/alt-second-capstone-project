-- Create schema
CREATE SCHEMA IF NOT EXISTS ALT_SCHOOL;


-- create the products table
create table if not exists ALT_SCHOOL.PRODUCTS
(
    id  serial primary key,
    name varchar not null,
    price numeric(10, 2) not null
);

-- provide command to copy ALT_SCHOOL.PRODUCTS data into POSTGRES
COPY ALT_SCHOOL.PRODUCTS (id, name, price)
FROM '/data/products.csv' DELIMITER ',' CSV HEADER;

-- create the customers table
create table if not exists ALT_SCHOOL.CUSTOMERS
(
    customer_id uuid primary key,
    device_id uuid not null,
    location varchar not null,
    currency varchar not null --changed the datatype from bigint as provided by the ERD because the data in the CSV is of character type.
);

-- provide command to copy ALT_SCHOOL.CUSTOMERS data into POSTGRES
COPY ALT_SCHOOL.CUSTOMERS (customer_id, device_id, location, currency)
FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;

-- create the orders table
create table if not exists ALT_SCHOOL.ORDERS
(
    order_id uuid not null primary key,
    customer_id uuid not null,
    status varchar not null,
    checked_out_at timestamp not null
);

-- provide command to copy ALT_SCHOOL.ORDERS data into POSTGRES
COPY ALT_SCHOOL.ORDERS (order_id, customer_id, status, checked_out_at)
FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;

-- create the line_items table
create table if not exists ALT_SCHOOL.LINE_ITEMS
(
    line_item_id serial primary key,
    order_id uuid not null,
    item_id int not null,
    quantity int not null
);

-- provide command to copy ALT_SCHOOL.LINE_ITEMS data into POSTGRES
COPY ALT_SCHOOL.LINE_ITEMS (line_item_id, order_id, item_id, quantity)
FROM '/data/line_items.csv' DELIMITER ',' CSV HEADER;

-- create the events table
create table if not exists ALT_SCHOOL.EVENTS
(
    event_id bigint primary key,
    customer_id uuid not null,
    event_data JSONB not null,
    event_timestamp timestamp not null
);

-- provide command to copy ALT_SCHOOL.EVENTS data into POSTGRES
COPY ALT_SCHOOL.EVENTS (event_id, customer_id, event_data, event_timestamp)
FROM '/data/events.csv' DELIMITER ',' CSV HEADER;
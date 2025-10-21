-- tabela customers
create table public.customers (...);

create index idx_customers_user_id on customers(user_id);
create index idx_customers_email on customers(email);

-- tabela products
create table public.products (...);

create index idx_products_sku on products(sku);
create index idx_products_name on products(name);

-- tabela orders
create table public.orders (...);

create index idx_orders_customer_id on orders(customer_id);
create index idx_orders_status on orders(status);
create index idx_orders_created_at on orders(created_at);

-- tabela order_items
create table public.order_items (...);

create index idx_order_items_order_id on order_items(order_id);
create index idx_order_items_product_id on order_items(product_id);
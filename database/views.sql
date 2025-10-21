-- view: resumo de pedidos por cliente, com contagem de itens
create or replace view customer_order_summary as
select
  o.id,
  o.status,
  o.total_amount,
  o.created_at,
  c.name as customer_name,
  count(oi.id) as items_count
from orders o
join customers c on o.customer_id = c.id
left join order_items oi on o.id = oi.order_id
group by o.id, c.name;

-- view: detalhes completos de cada pedido, com cliente e produtos
create or replace view order_details_view as
select
  o.id as order_id,
  o.status,
  o.total_amount,
  o.created_at,
  c.name as customer_name,
  c.email,
  p.name as product_name,
  p.sku,
  oi.quantity,
  oi.unit_price,
  oi.subtotal
from orders o
join customers c on o.customer_id = c.id
join order_items oi on o.id = oi.order_id
join products p on oi.product_id = p.id
order by o.created_at desc, p.name;
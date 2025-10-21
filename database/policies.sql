-- políticas de acesso da tabela customers
create policy view_own_customers
  on customers for select
  using (auth.uid() = user_id);

create policy update_own_customers
  on customers for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy insert_own_customers
  on customers for insert
  with check (auth.uid() = user_id);

-- políticas de acesso da tabela orders
create policy view_own_orders
  on orders for select
  using (customer_id in (select id from customers where user_id = auth.uid()));

create policy insert_own_orders
  on orders for insert
  with check (customer_id in (select id from customers where user_id = auth.uid()));

create policy admin_manage_orders
  on orders for all
  using (auth.jwt() ->> 'role' = 'admin');

-- políticas de acesso da tabela order_items
create policy view_own_order_items
  on order_items for select
  using (order_id in (
    select id from orders where customer_id in (
      select id from customers where user_id = auth.uid()
    )
  ));

create policy insert_own_order_items
  on order_items for insert
  with check (order_id in (
    select id from orders where customer_id in (
      select id from customers where user_id = auth.uid()
    )
  ));
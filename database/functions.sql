-- função: calcula o total de um pedido com base nos itens associados
create or replace function calculate_order_total(p_order_id uuid)
returns decimal as $$
declare
  v_total decimal;
begin
  select coalesce(sum(subtotal), 0)
  into v_total
  from order_items
  where order_id = p_order_id;

  return v_total;
end;
$$ language plpgsql stable;

-- função e trigger: atualiza automaticamente o valor total de um pedido
create or replace function update_order_total()
returns trigger as $$
begin
  update orders
  set total_amount = calculate_order_total(coalesce(new.order_id, old.order_id)),
      updated_at = now()
  where id = coalesce(new.order_id, old.order_id);

  return coalesce(new, old);
end;
$$ language plpgsql;

create trigger trg_update_order_total
after insert or update or delete on order_items
for each row execute function update_order_total();

-- função: altera o status de um pedido e retorna informações sobre a atualização
create or replace function update_order_status(p_order_id uuid, p_new_status text)
returns json as $$
declare
  v_old_status text;
begin
  if p_new_status not in ('pending','processing','shipped','delivered','cancelled') then
    raise exception 'status inválido: %', p_new_status;
  end if;

  select status into v_old_status from orders where id = p_order_id;
  if v_old_status is null then
    raise exception 'pedido não encontrado: %', p_order_id;
  end if;

  update orders
  set status = p_new_status, updated_at = now()
  where id = p_order_id;

  return json_build_object(
    'success', true,
    'old_status', v_old_status,
    'new_status', p_new_status,
    'updated_at', now()
  );
end;
$$ language plpgsql;

-- função: reduz o estoque de um produto conforme a quantidade vendida
create or replace function decrease_stock(p_product_id uuid, p_quantity integer)
returns json as $$
declare
  v_stock integer;
begin
  select stock into v_stock from products where id = p_product_id for update;
  if v_stock is null then
    raise exception 'produto não encontrado: %', p_product_id;
  end if;
  if v_stock < p_quantity then
    raise exception 'estoque insuficiente. disponível: %, solicitado: %', v_stock, p_quantity;
  end if;

  update products
  set stock = stock - p_quantity, updated_at = now()
  where id = p_product_id;

  return json_build_object(
    'success', true,
    'product_id', p_product_id,
    'quantity_removed', p_quantity,
    'remaining_stock', v_stock - p_quantity
  );
end;
$$ language plpgsql;
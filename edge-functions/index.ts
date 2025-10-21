import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization"
};
serve(async (req)=>{
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  try {
    const { orderId } = await req.json();
    if (!orderId) {
      return new Response(JSON.stringify({
        error: "orderId é obrigatório"
      }), {
        status: 400,
        headers: corsHeaders
      });
    }
    // Cria o client com as chaves do Supabase
    const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
    // Busca os detalhes do pedido
    const { data: orderItems, error } = await supabase.from("order_details_view").select("*").eq("order_id", orderId);
    if (error || !orderItems || orderItems.length === 0) {
      return new Response(JSON.stringify({
        error: "Pedido não encontrado"
      }), {
        status: 404,
        headers: corsHeaders
      });
    }
    // Extrai informações gerais
    const order = orderItems[0];
    const header = [
      "Cliente",
      "E-mail",
      "Status",
      "Produto",
      "SKU",
      "Quantidade",
      "Preço Unitário",
      "Subtotal",
      "Total do Pedido",
      "Data do Pedido"
    ];
    const rows = orderItems.map((item)=>[
        item.customer_name,
        item.email,
        item.status,
        item.product_name,
        item.sku,
        item.quantity,
        item.unit_price.toFixed(2),
        item.subtotal.toFixed(2),
        item.total_amount.toFixed(2),
        new Date(item.created_at).toLocaleDateString("pt-BR")
      ]);
    // Monta o CSV manualmente
    const csvContent = header.join(",") + "\n" + rows.map((r)=>r.map((v)=>`"${v}"`).join(",")).join("\n");
    // Retorna o CSV como arquivo
    return new Response(csvContent, {
      status: 200,
      headers: {
        "Content-Type": "text/csv; charset=utf-8",
        "Content-Disposition": `attachment; filename=pedido_${orderId}.csv`,
        ...corsHeaders
      }
    });
  } catch (err) {
    console.error("Erro:", err);
    return new Response(JSON.stringify({
      error: err.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders
      }
    });
  }
});

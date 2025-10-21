Documentação do Projeto – Sistema de Pedidos com Supabase e Função de Confirmação de Pedido
1. Visão Geral
O projeto implementa um sistema de gerenciamento de pedidos (e-commerce simplificado), utilizando Supabase como banco de dados e autenticação, e Deno para uma função serverless responsável pelo envio automático de e-mails de confirmação de pedido.

O foco é garantir segurança, integridade dos dados, rastreabilidade dos pedidos e automação da comunicação com o cliente.

2. Estrutura do Banco de Dados
2.1 Tabela customers
Armazena os dados dos clientes vinculados ao usuário autenticado (auth.users). O campo user_id referencia diretamente o usuário do Supabase. Índices foram criados em user_id e email para otimizar consultas. Políticas de segurança garantem que cada usuário acesse apenas seus próprios clientes.

2.2 Tabela products
Gerencia os produtos disponíveis para venda. Contém nome, descrição, preço, estoque e um SKU único. Validações com CHECK impedem preços negativos e inconsistências de estoque. Índices otimizam a busca por nome e SKU.

2.3 Tabela orders
Representa os pedidos realizados pelos clientes. O campo status possui validação restrita (pending, processing, shipped, delivered, cancelled) para garantir consistência. O campo total_amount é atualizado automaticamente por meio de triggers. Políticas de acesso permitem que apenas o dono do pedido (ou administradores) possam visualizar ou modificar os dados.

2.4 Tabela order_items
Relaciona os produtos aos pedidos. Calcula automaticamente o subtotal (quantity * unit_price). Dispara uma trigger após inserções, atualizações ou exclusões para recalcular o total do pedido.

2.5 Triggers e Funções
calculate_order_total: soma os subtotais de um pedido

update_order_total: atualiza o total automaticamente via trigger

update_order_status: altera o status do pedido e retorna um JSON com o resultado

decrease_stock: reduz o estoque do produto vendido, impedindo vendas sem disponibilidade

2.6 Views Criadas
customer_order_summary: visão geral dos pedidos por cliente, com contagem de itens e valores totais

order_details_view: une pedidos, clientes e produtos em uma visualização completa, facilitando relatórios e integrações

3. Função Serverless em Deno (Envio de E-mail de Confirmação)
Objetivo: Enviar automaticamente um e-mail de confirmação ao cliente após o registro de um novo pedido.

Fluxo lógico:

Tratamento de CORS e pré-verificação

Recepção da requisição com orderId

Conexão com o Supabase

Geração do corpo do e-mail

Envio via Resend API

Tratamento de erros e resposta

4. Decisões Técnicas e Justificativas
Supabase: autenticação integrada e políticas RLS

UUID como chave primária: unicidade global

Triggers automáticas: consistência de valores

Views: simplificam consultas e integrações

Função serverless: escalável e independente

Envio de e-mail via Resend: automação confiável

RLS: segurança e privacidade

5. Considerações Finais
O sistema foi projetado com foco em segurança, integridade e escalabilidade. A combinação entre Supabase e Deno oferece uma arquitetura moderna e eficiente para aplicações de e-commerce.

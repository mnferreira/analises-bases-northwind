-- é possível fazer query com uma operação matemática, por exemplo:
select 
    units_in_stock * unit_price as total
from products

select *, unit_price * quantity as revenue
from order_details


-- para selecionar apenas os valores que começam com uma letra específica (busca coringa):
select * from employees
where first_name like 'M%'
limit 10

select * from employees
where title like '%sales%'
limit 10

''' funções agregadas:
    - contagem
    - soma
    - media
    - maximo
    - minimo
'''

-- para saber quantas unidades foram vendidas no total:
select sum(quantity) as total_unit_sold from order details

-- para saber a soma por produto (scada produto vendido):
select product_id, sum(quantity) as total_units_sold
from order_details
group by product_id
order by total_units_sold

-- para entender em quais meses as vendas foram melhores (importante para ver a evolução ao longo do tempo)
select date_trunc('month', order_date) as order_month, count(order_id)
from order_details
group by order_month
order by order_month

-- para saber os produtos que vendeu mais de 1000 unidades:
select product_id, sum(quantity) as total_units_sold
from order_details
group by product_id
havind sum(quantity) >= 1000 --função having permite que foltre depois que agrupou

-- joins

'''
inner join: elemento existe em ambas as tabelas
left join: considera a tabela da esquerda como referência e traz o que achar de referência na direita
right join: considera a tabela da direita como referência e traz o que achar de referência na esquerda
full join: traz a correspondência de ambas as tabelas
'''

-- relacionar as categorias e produtos:
select 
    product_name,
    quantity_per_unit,
    unit_price,
    category_name,
    description
from products
inner join categories on
categories.category_id = products.category_id -- importante especificar o nome das tabelas pois os atributos têm o mesmo nome

-- calcular a média por produto vendido e selecionar aqueles acima da média:
select *
from order_details
where quantity > 
    ( -- subquery
    select avg(quantity)
    from order_details
    )

-- utlizando o comando with e as CTE (common table expression):
with average as (
    select avg(quantity) as average_quantity
    from order_details
)
select * from order_details, average
where quantity > average.average_quantity

-- otimizar queries (índices):

'''
os índicies preordenam a tabela e, assim, otimizam a busca e melhoram a performance da consulta
'''
create index idx_category on products(category_id)

-- funções de janela: faz uma varredura dentro da partição pra responder perguntas mais específicas
-- qual a primeira venda de cada funcionário e quando aconteceu?

'''
funções de janela:
- ranqueamento
- agregação (soma, contagem, minimo, maximo)
- posição
'''

select distinct
    employee_id,
    first value(order_date) over (partition by employee_id order by order_date) as first_date -- pra cada funcionário, o valor do order_date seja sempre o first value
    first value(product_name) over (partition by employee_id order by order_date) as first_product
from orders
inner join order_details on
    orders.order_id = order_details.order_id
inner join products on
    products.product_id = order_details.product_id


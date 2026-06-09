use airportdb;
select * from airport;

-- verificando os campos da tabela airport
show fields from airport;
show index from airport;

-- conhecendo o comando EXPLAIN
explain select * from airport;
explain select * from airport where airport_id = 500;

-- conhecendo a tabela weatherdata
select count(*) from weatherdata;
explain select count(*) from weatherdata;

-- verificando o desempenho da consulta
select * from weatherdata where weather = "Regen";
explain select * from weatherdata where weather = "Regen";

CREATE INDEX idx_weather ON weatherdata(weather);
-- DROP INDEX idx_weather on weatherdata;

-- Problema da baixa cardinalidade
-- Compensa usar índeces em baixa cardinalidade?
SELECT weather, total, CONCAT(ROUND((total / 4626432) * 100, 2), '%') AS porcentagem 
FROM (
    SELECT weather, COUNT(*) AS total 
    FROM weatherdata 
    GROUP BY weather
) AS dt;

-- Se executar sem o índice = Table Scan; Se executar com índice, então teremos um Index Lookup
-- DROP INDEX idx_weather on weatherdata;
EXPLAIN SELECT * FROM weatherdata WHERE weather = 'Regen';

-- Mesmo existindo índice o SGBD optou por fazer um table scan.alter
-- Resumo: índex só faz sentido se for bem pensado. Deve ser usado para seleções específicas
-- Se vai trazer uma grande quantidade de dados, um table scan pode ser menos custoso.
EXPLAIN SELECT * FROM weatherdata WHERE weather in ('Regen', 'Schneefall', 'Regen-Schneefall', 'Regen-Gewitter');


-- Índice composto
-- O MySQL permite consultas envolvendo diversos campos com índeces. 
SHOW INDEX FROM flight;
DROP INDEX idx_route ON flight;
EXPLAIN SELECT * FROM flight WHERE `from` = 101 AND `to` = 202;

-- Criando um índice composto
CREATE INDEX idx_route ON flight(`from`, `to`);
EXPLAIN SELECT * FROM flight WHERE `from` = 101 AND `to` = 202;

-- No BD tem index para FROM e TO separadamente. Caso não tenha um composto, ele usa o separadamente. 
EXPLAIN SELECT * FROM flight WHERE `from` = 101;
EXPLAIN SELECT * FROM flight WHERE `to` = 202;
-- Se não tiver os índices separados, então a utilização do índice composto será usado parcialmente.


-- Exemplos mais pesados
select count(*) from flight; -- 416429
select count(*) from booking; -- 50831531
-- flight X booking sem ligação = 2,116772362×10¹³
-- Com ligação "ON" = a interseção dos conjuntos
-- Não precisa executar o código para saber se é bom ou ruim, basta ver o plano de execução
select count(*) from booking as b inner join flight as f on f.flight_id = b.flight_id;
explain select count(*) from booking as b inner join flight as f on f.flight_id = b.flight_id;


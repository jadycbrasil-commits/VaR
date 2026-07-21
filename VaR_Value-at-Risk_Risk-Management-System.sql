/*CREATE TABLE precos_ativos (

    data_pregao DATE,

    ultimo NUMERIC(10,2),

    abertura NUMERIC(10,2),

    maxima NUMERIC(10,2),

    minima NUMERIC(10,2),

    volume VARCHAR(20),

    variacao NUMERIC(6,2)

);*/


/*CREATE TABLE precos_ativos (

    id SERIAL PRIMARY KEY,

    data_pregao DATE NOT NULL,

    ultimo NUMERIC(10,2) NOT NULL,

    abertura NUMERIC(10,2) NOT NULL,

    maxima NUMERIC(10,2) NOT NULL,

    minima NUMERIC(10,2) NOT NULL,

    volume VARCHAR(20) NOT NULL,

    variacao NUMERIC(6,2) NOT NULL

);*/

	
/*INSERT INTO precos_ativos
(
    data_pregao,
    ultimo,
    abertura,
    maxima,
    minima,
    volume,
    variacao
)
SELECT
    TO_DATE(data_pregao, 'DD.MM.YYYY'),

    REPLACE(ultimo, ',', '.')::NUMERIC(10,2),

    REPLACE(abertura, ',', '.')::NUMERIC(10,2),

    REPLACE(maxima, ',', '.')::NUMERIC(10,2),

    REPLACE(minima, ',', '.')::NUMERIC(10,2),

    volume,

    REPLACE(
        REPLACE(variacao, '%', ''),
        ',',
        '.'
    )::NUMERIC(6,2)

FROM precos_ativos_staging;*/

/*SELECT *
FROM precos_ativos
LIMIT 10;*/

/*SELECT COUNT(*)
FROM precos_ativos;*/

/*SELECT
    MIN(data_pregao) AS primeira_data,
    MAX(data_pregao) AS ultima_data
FROM precos_ativos;*/

/*SELECT
    MIN(ultimo) AS menor_preco,
    MAX(ultimo) AS maior_preco
FROM precos_ativos;*/

/*SELECT AVG(ultimo)
FROM precos_ativos;*/

/*SELECT STDDEV(ultimo)
FROM precos_ativos;*/

/*SELECT

    data_pregao,

    ultimo,

    LAG(ultimo) OVER (
        ORDER BY data_pregao
    ) AS preco_anterior

FROM precos_ativos

ORDER BY data_pregao;*/



/*SELECT

    data_pregao,

    ultimo,

    LAG(ultimo) OVER (
        ORDER BY data_pregao
    ) AS preco_anterior,

    ROUND(
        (
            ultimo -
            LAG(ultimo) OVER (
                ORDER BY data_pregao
            )
        )
        /
        LAG(ultimo) OVER (
            ORDER BY data_pregao
        ),
        6
    ) AS retorno

FROM precos_ativos

ORDER BY data_pregao;*/


/*WITH precos AS (

    SELECT

        data_pregao,

        ultimo,

        LAG(ultimo) OVER (
            ORDER BY data_pregao
        ) AS preco_anterior

    FROM precos_ativos

)

SELECT

    data_pregao,

    ultimo,

    preco_anterior,

    ROUND(
        (ultimo - preco_anterior) / preco_anterior,
        6
    ) AS retorno

FROM precos

ORDER BY data_pregao;*/

/*CREATE TABLE retornos_diarios (

    id SERIAL PRIMARY KEY,

    data_pregao DATE NOT NULL,

    preco_fechamento NUMERIC(10,2) NOT NULL,

    preco_anterior NUMERIC(10,2),

    retorno NUMERIC(12,8)

);*/

/*INSERT INTO retornos_diarios
(
    data_pregao,
    preco_fechamento,
    preco_anterior,
    retorno
)
WITH precos AS (

    SELECT

        data_pregao,

        ultimo,

        LAG(ultimo) OVER (
            ORDER BY data_pregao
        ) AS preco_anterior

    FROM precos_ativos

)

SELECT

    data_pregao,

    ultimo,

    preco_anterior,

    ROUND(
        (ultimo - preco_anterior) / preco_anterior,
        8
    )

FROM precos

WHERE preco_anterior IS NOT NULL;*/

/*SELECT *
FROM retornos_diarios
ORDER BY data_pregao
LIMIT 250;*/

/*SELECT
    ROUND(AVG(retorno),8) AS media_retorno
FROM retornos_diarios;*/


/*SELECT
    ROUND(STDDEV(retorno),8) AS volatilidade
FROM retornos_diarios;*/


/*SELECT

    ROUND(MAX(retorno),6) AS maior_ganho,

    ROUND(MIN(retorno),6) AS maior_perda

FROM retornos_diarios;*/

/*SELECT

CASE

WHEN retorno > 0 THEN 'Positivo'

WHEN retorno < 0 THEN 'Negativo'

ELSE 'Zero'

END AS situacao,

COUNT(*) AS quantidade

FROM retornos_diarios

GROUP BY situacao;*/

/*SELECT

ROUND(retorno,2) AS faixa,

COUNT(*)

FROM retornos_diarios

GROUP BY faixa

ORDER BY faixa;*/

/*WITH ultima_posicao AS (

    SELECT
        ultimo,
        10000 AS quantidade_cotas,
        ultimo * 10000 AS valor_posicao

    FROM precos_ativos

    ORDER BY data_pregao DESC

    LIMIT 1

),

var_historico AS (

    SELECT

        ABS(
            PERCENTILE_CONT(0.05)
            WITHIN GROUP (ORDER BY retorno)
        )::numeric AS percentual_var

    FROM retornos_diarios

)

SELECT

    quantidade_cotas,

    ultimo AS preco_atual,

    valor_posicao,

    ROUND(percentual_var,6) AS var_percentual,

    ROUND(
        valor_posicao * percentual_var,
        2
    ) AS var_1_dia

FROM ultima_posicao

CROSS JOIN var_historico;*/


/*CREATE TABLE var_historico_diario (

    id SERIAL PRIMARY KEY,

    data_calculo DATE NOT NULL,

    ativo VARCHAR(10) NOT NULL,

    quantidade_cotas INTEGER NOT NULL,

    preco_referencia NUMERIC(10,2) NOT NULL,

    valor_posicao NUMERIC(15,2) NOT NULL,

    nivel_confianca NUMERIC(5,2) NOT NULL,

    horizonte_dias INTEGER NOT NULL,

    metodologia VARCHAR(30),

    var_percentual NUMERIC(10,6),

    var_financeiro NUMERIC(15,2)

);*/


/*SELECT *
FROM var_historico_diario;*/


/*INSERT INTO var_historico_diario
(
    data_calculo,
    ativo,
    quantidade_cotas,
    preco_referencia,
    valor_posicao,
    nivel_confianca,
    horizonte_dias,
    metodologia,
    var_percentual,
    var_financeiro
)

WITH ultima_posicao AS (

    SELECT

        ultimo,

        10000 AS quantidade_cotas,

        ultimo * 10000 AS valor_posicao

    FROM precos_ativos

    ORDER BY data_pregao DESC

    LIMIT 1

),

var_calculo AS (

    SELECT

        ABS(
            PERCENTILE_CONT(0.05)
            WITHIN GROUP (ORDER BY retorno)
        )::numeric AS percentual_var

    FROM retornos_diarios

)

SELECT

    CURRENT_DATE,

    'PETR4',

    quantidade_cotas,

    ultimo,

    valor_posicao,

    95.00,

    1,

    'VaR Historico',

    percentual_var,

    valor_posicao * percentual_var

FROM ultima_posicao

CROSS JOIN var_calculo;*/

/*SELECT *
FROM var_historico_diario;*/


/*CREATE TABLE parametros_risco (

    id SERIAL PRIMARY KEY,

    codigo_ativo VARCHAR(10) NOT NULL,

    quantidade_cotas INTEGER NOT NULL,

    nivel_confianca NUMERIC(5,2) NOT NULL,

    horizonte_dias INTEGER NOT NULL,

    metodologia VARCHAR(30) NOT NULL,

    data_inicio_historico DATE,

    data_fim_historico DATE,

    registro_ativo BOOLEAN DEFAULT TRUE,

    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);*/


/*INSERT INTO parametros_risco
(
    codigo_ativo,
    quantidade_cotas,
    nivel_confianca,
    horizonte_dias,
    metodologia,
    data_inicio_historico,
    data_fim_historico
)

VALUES
(
    'PETR4',
    10000,
    95.00,
    1,
    'VaR Historico',
    '2025-07-21',
    '2026-07-20'
);*/

/*SELECT *
FROM parametros_risco;*/


/*WITH parametros AS (

    SELECT

        codigo_ativo,
        quantidade_cotas,
        nivel_confianca,
        horizonte_dias

    FROM parametros_risco

    WHERE registro_ativo = TRUE

),

ultima_posicao AS (

    SELECT

        ultimo,
        data_pregao

    FROM precos_ativos

    ORDER BY data_pregao DESC

    LIMIT 1

),

calculo_var AS (

    SELECT

        ABS(
            PERCENTILE_CONT(0.05)
            WITHIN GROUP (ORDER BY retorno)
        )::numeric AS percentual_var

    FROM retornos_diarios

)


SELECT

    p.codigo_ativo,

    p.quantidade_cotas,

    u.data_pregao AS data_referencia,

    u.ultimo AS preco_atual,

    p.quantidade_cotas * u.ultimo AS valor_posicao,

    p.nivel_confianca,

    p.horizonte_dias,

    ROUND(c.percentual_var,6) AS var_percentual,

    ROUND(
        (p.quantidade_cotas * u.ultimo) 
        * c.percentual_var,
        2
    ) AS var_financeiro


FROM parametros p

CROSS JOIN ultima_posicao u

CROSS JOIN calculo_var c;*/


/*INSERT INTO var_historico_diario
(
    data_calculo,
    ativo,
    quantidade_cotas,
    preco_referencia,
    valor_posicao,
    nivel_confianca,
    horizonte_dias,
    metodologia,
    var_percentual,
    var_financeiro
)

WITH parametros AS (

    SELECT

        codigo_ativo,
        quantidade_cotas,
        nivel_confianca,
        horizonte_dias,
        metodologia

    FROM parametros_risco

    WHERE registro_ativo = TRUE

),

ultima_posicao AS (

    SELECT

        ultimo,
        data_pregao

    FROM precos_ativos

    ORDER BY data_pregao DESC

    LIMIT 1

),

calculo_var AS (

    SELECT

        ABS(
            PERCENTILE_CONT(0.05)
            WITHIN GROUP (ORDER BY retorno)
        )::numeric AS percentual_var

    FROM retornos_diarios

)

SELECT

    CURRENT_DATE,

    p.codigo_ativo,

    p.quantidade_cotas,

    u.ultimo,

    p.quantidade_cotas * u.ultimo,

    p.nivel_confianca,

    p.horizonte_dias,

    p.metodologia,

    c.percentual_var,

    (p.quantidade_cotas * u.ultimo) 
        * c.percentual_var


FROM parametros p

CROSS JOIN ultima_posicao u

CROSS JOIN calculo_var c;*/


/*SELECT *
FROM var_historico_diario;*/

/*DELETE FROM var_historico_diario
WHERE id = 2;*/

SELECT *
FROM var_historico_diario;


/*ALTER TABLE var_historico_diario
ADD CONSTRAINT unique_var_diario
UNIQUE
(
    data_calculo,
    ativo,
    metodologia,
    horizonte_dias,
    nivel_confianca
);*/




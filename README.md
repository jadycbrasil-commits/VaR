# Market Risk Analytics Engine

### SQL-Based Historical Value at Risk (VaR) using PostgreSQL

---

## Sobre o Projeto

Este projeto implementa um pipeline completo para cálculo do **Historical Value at Risk (VaR)** utilizando **PostgreSQL**.

A solução contempla desde a importação da série histórica de preços até o armazenamento diário das métricas de risco, reproduzindo uma estrutura simplificada semelhante às utilizadas em áreas de **Risco de Mercado**, **Asset Management** e **Instituições Financeiras**.

O objetivo principal é demonstrar a aplicação de SQL em problemas reais de análise financeira, utilizando modelagem relacional, estatística e boas práticas de organização de dados.

---

# Arquitetura

```text
CSV (Historical Prices)
        │
        ▼
precos_ativos
        │
        ▼
retornos_diarios
        │
        ▼
parametros_risco
        │
        ▼
var_historico_diario
```

Cada camada possui uma responsabilidade específica:

| Tabela | Finalidade |
|---------|------------|
| **precos_ativos** | Armazena a série histórica de preços do ativo. |
| **retornos_diarios** | Calcula os retornos diários utilizando Window Functions. |
| **parametros_risco** | Define ativo, posição, horizonte e nível de confiança do modelo. |
| **var_historico_diario** | Armazena os resultados diários do cálculo do VaR. |

---

# Tecnologias Utilizadas

- PostgreSQL
- SQL
- Window Functions (`LAG`)
- Common Table Expressions (CTEs)
- PERCENTILE_CONT()
- ETL
- Estatística aplicada ao Mercado Financeiro

---

# Metodologia

O projeto implementa o **VaR Histórico** utilizando:

- Horizonte de **1 dia**
- Nível de confiança de **95%**
- Percentil histórico de **5%**
- Posição parametrizada em **10.000 cotas**

Fluxo do cálculo:

1. Importação dos preços históricos.
2. Cálculo dos retornos diários.
3. Determinação do percentil de perdas.
4. Cálculo do VaR financeiro.
5. Registro do cálculo para auditoria e acompanhamento.

---

# Exemplo de Implementação

O trecho abaixo representa a etapa central do projeto: a execução do cálculo do **Value at Risk (VaR) Histórico** utilizando parâmetros previamente configurados e o registro automático do resultado na base histórica.

Essa abordagem demonstra uma arquitetura em que o modelo de risco é **parametrizado**, **reproduzível** e **auditável**, princípios amplamente utilizados em ambientes de Risco de Mercado.

```sql
INSERT INTO var_historico_diario
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

    (p.quantidade_cotas * u.ultimo) * c.percentual_var

FROM parametros p

CROSS JOIN ultima_posicao u

CROSS JOIN calculo_var c;
```

 **Resultado da execução**

> <img width="1920" height="993" alt="image" src="https://github.com/user-attachments/assets/240ed480-6ba3-4b2b-9360-693332fce905" />



---

# Resultado do Modelo

| Indicador | Resultado |
|-----------|----------:|
| Ativo | PETR4 |
| Quantidade | 10.000 cotas |
| Valor da posição | R$ 411.500,00 |
| Horizonte | 1 dia |
| Nível de confiança | 95% |
| VaR Histórico | **R$ 10.288,90** |

**Interpretação**

> Considerando uma posição de **10.000 cotas**, o modelo estima, com **95% de confiança**, que a perda diária da posição não deverá ultrapassar **R$ 10.288,90**, assumindo que o comportamento futuro dos retornos seja consistente com o histórico observado.

---

# Próximas Evoluções

- Implementação do **VaR Paramétrico**
- Backtesting do modelo
- Stress Testing
- Carteiras com múltiplos ativos
- Dashboard em Power BI
- Automação das rotinas com Python

---

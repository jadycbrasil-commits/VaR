# Value at Risk (VaR) | PostgreSQL

> Este projeto demonstra a implementação de um fluxo completo de análise de risco de mercado utilizando PostgreSQL, desde a ingestão de séries históricas de preços até o cálculo e armazenamento do Value at Risk (VaR) Histórico.

> O objetivo é reproduzir, em escala reduzida, parte da arquitetura de dados utilizada por áreas de Risco de Mercado, Asset Management, Tesouraria e Instituições Financeiras, aplicando conceitos de modelagem de dados, estatística descritiva e SQL analítico.

> O projeto foi desenvolvido com foco na construção de um pipeline estruturado para cálculo de métricas de risco, priorizando organização, rastreabilidade e reutilização dos dados.

# Objetivos
Importar séries históricas de preços para o PostgreSQL.
Estruturar um fluxo de ETL para tratamento dos dados.
Calcular retornos diários utilizando Window Functions (LAG).
Construir uma base consolidada de retornos.
Parametrizar cenários de risco.
Calcular o Value at Risk (VaR) Histórico.
Armazenar os resultados em uma tabela histórica para auditoria e acompanhamento.

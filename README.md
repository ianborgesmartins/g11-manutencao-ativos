# G11 - Sistema de Manutencao de Ativos e Equipamentos

Aplicacao fullstack (Spring Boot + SPA + PostgreSQL 16) para controle de maquinas, tecnicos, ordens de servico e pecas.

## Como executar

    docker-compose up --build

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api/maquinas

Pra recriar o banco do zero: `docker-compose down -v`

## Usuarios da aplicacao

| login     | senha       | perfil   |
|-----------|-------------|----------|
| admin     | admin123    | ADMIN    |
| operador1 | operador123 | OPERADOR |

## Usuarios do banco

| usuario       | role        | senha         |
|---------------|-------------|---------------|
| app_backend   | rl_escritor | Backend@2026  |
| app_relatorio | rl_leitor   | Relat@2026    |
| postgres      | superuser   | Postgres@2026 |

## Demonstracao dos recursos do banco

    docker exec -it -u postgres manutencao_db psql -d manutencao

- Timeout: `SELECT pg_sleep(40);` (cancela em 30s)
- Auditoria: `UPDATE financeiro.peca SET custo_unitario = 99 WHERE id = 1;` e depois `SELECT * FROM audit.log_alteracoes;`
- pgaudit: `docker logs manutencao_db | grep AUDIT`
- Procedure: `CALL financeiro.sp_aprovar_os(2, 1);`
- Function: `SELECT financeiro.fn_custo_total_os(1);`
- RLS: `docker exec -it manutencao_db psql -U app_relatorio -d manutencao` e `SELECT * FROM financeiro.aprovacao_os;` (so aparecem as aprovadas)

## Estrutura

- `/bd`: Dockerfile, postgresql.conf, pg_hba.conf e backup.sql
- `/backend`: API Spring Boot
- `/frontend`: SPA com nginx

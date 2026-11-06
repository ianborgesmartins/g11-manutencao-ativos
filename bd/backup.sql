CREATE SCHEMA operacional;
CREATE SCHEMA financeiro;
CREATE SCHEMA audit;
CREATE SCHEMA ext;

CREATE EXTENSION pgcrypto SCHEMA ext;

CREATE TABLE operacional.operador (
    id SERIAL PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil VARCHAR(20) NOT NULL DEFAULT 'OPERADOR'
);

CREATE TABLE operacional.maquina (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    setor VARCHAR(60),
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVA',
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE operacional.tecnico (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(60),
    ativo BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE financeiro.peca (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(150) NOT NULL,
    custo_unitario NUMERIC(12,2) NOT NULL CHECK (custo_unitario >= 0)
);

CREATE TABLE operacional.ordem_servico (
    id SERIAL PRIMARY KEY,
    maquina_id INT NOT NULL REFERENCES operacional.maquina(id),
    tecnico_id INT REFERENCES operacional.tecnico(id),
    descricao TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
    aberta_em TIMESTAMPTZ NOT NULL DEFAULT now(),
    concluida_em TIMESTAMPTZ
);

CREATE TABLE operacional.os_peca (
    id SERIAL PRIMARY KEY,
    os_id INT NOT NULL REFERENCES operacional.ordem_servico(id) ON DELETE CASCADE,
    peca_id INT NOT NULL REFERENCES financeiro.peca(id),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    custo_aplicado NUMERIC(12,2)
);

CREATE TABLE financeiro.aprovacao_os (
    id SERIAL PRIMARY KEY,
    os_id INT NOT NULL UNIQUE REFERENCES operacional.ordem_servico(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    aprovado_por INT REFERENCES operacional.operador(id),
    aprovado_em TIMESTAMPTZ
);

CREATE TABLE audit.log_alteracoes (
    id BIGSERIAL PRIMARY KEY,
    tabela TEXT NOT NULL,
    operacao TEXT NOT NULL,
    usuario TEXT NOT NULL DEFAULT session_user,
    dados_antigos JSONB,
    dados_novos JSONB,
    data_hora TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO operacional.operador (login, senha_hash, perfil) VALUES
('admin', ext.crypt('admin123', ext.gen_salt('bf')), 'ADMIN'),
('operador1', ext.crypt('operador123', ext.gen_salt('bf')), 'OPERADOR');

INSERT INTO operacional.maquina (codigo, nome, setor) VALUES
('MQ-001', 'Torno CNC', 'Usinagem'),
('MQ-002', 'Prensa Hidraulica', 'Estamparia'),
('MQ-003', 'Compressor de Ar', 'Utilidades');

INSERT INTO operacional.tecnico (nome, especialidade) VALUES
('Carlos Silva', 'Mecanica'),
('Ana Souza', 'Eletrica');

INSERT INTO financeiro.peca (codigo, descricao, custo_unitario) VALUES
('PC-100', 'Rolamento 6205', 45.90),
('PC-101', 'Correia dentada', 78.50),
('PC-102', 'Filtro hidraulico', 120.00);

INSERT INTO operacional.ordem_servico (maquina_id, tecnico_id, descricao, status) VALUES
(1, 1, 'Ruido no eixo principal', 'CONCLUIDA'),
(2, 2, 'Vazamento de oleo', 'ABERTA');

INSERT INTO operacional.os_peca (os_id, peca_id, quantidade, custo_aplicado) VALUES
(1, 1, 2, 45.90),
(2, 3, 1, 120.00);

INSERT INTO financeiro.aprovacao_os (os_id, status, aprovado_por, aprovado_em) VALUES
(1, 'APROVADA', 1, now()),
(2, 'PENDENTE', NULL, NULL);

CREATE ROLE rl_leitor NOLOGIN;
CREATE ROLE rl_escritor NOLOGIN;

CREATE ROLE app_backend LOGIN PASSWORD 'Backend@2026' IN ROLE rl_escritor;
CREATE ROLE app_relatorio LOGIN PASSWORD 'Relat@2026' IN ROLE rl_leitor;

ALTER ROLE app_backend SET statement_timeout = '15s';
ALTER ROLE app_relatorio SET statement_timeout = '10s';

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON DATABASE manutencao FROM PUBLIC;
GRANT CONNECT ON DATABASE manutencao TO rl_leitor, rl_escritor;

GRANT USAGE ON SCHEMA operacional, financeiro, ext TO rl_leitor, rl_escritor;

GRANT SELECT ON ALL TABLES IN SCHEMA operacional, financeiro TO rl_leitor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA operacional, financeiro TO rl_escritor;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA operacional, financeiro TO rl_escritor;
REVOKE ALL ON operacional.operador FROM rl_leitor;

-- hardening do catalogo
REVOKE ALL ON pg_catalog.pg_user FROM PUBLIC;
REVOKE ALL ON pg_catalog.pg_roles FROM PUBLIC;
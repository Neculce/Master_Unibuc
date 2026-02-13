ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

create table TickLy_DW.dim_client (
   client_key         NUMBER GENERATED ALWAYS AS IDENTITY,
   client_id          NUMBER NOT NULL,
   email              VARCHAR2(100),
   phone              VARCHAR2(20),
   registration_date  DATE,
   client_type        CHAR(1),
   nume               VARCHAR2(50),
   prenume            VARCHAR2(50),
   cnp                VARCHAR2(13),
   denumire           VARCHAR2(200),
   cui                VARCHAR2(20),
   sediu_social       VARCHAR2(200),
   reprezentant_legal VARCHAR2(100),
   is_active          CHAR(1) DEFAULT 'Y',
   valid_from         DATE DEFAULT SYSDATE,
   valid_to           DATE,
   is_current         CHAR(1) DEFAULT 'Y',
   load_date          DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_client PRIMARY KEY (client_key) RELY,
   CONSTRAINT uk_dim_client_id UNIQUE ( client_id, valid_from )
);

create table TickLy_DW.dim_agent (
   agent_key      NUMBER GENERATED ALWAYS AS IDENTITY,
   agent_id       NUMBER NOT NULL,
   nume           VARCHAR2(50),
   prenume        VARCHAR2(50),
   nume_complet   VARCHAR2(101),
   email          VARCHAR2(100),
   telefon        VARCHAR2(20),
   hire_date      DATE,
   is_active      CHAR(1),
   ani_experienta NUMBER,
   valid_from     DATE DEFAULT SYSDATE,
   valid_to       DATE,
   is_current     CHAR(1) DEFAULT 'Y',
   load_date      DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_agent PRIMARY KEY (agent_key) RELY,
   CONSTRAINT uk_dim_agent_id UNIQUE ( agent_id, valid_from )
);

create table TickLy_DW.dim_departament (
   departament_key NUMBER GENERATED ALWAYS AS IDENTITY,
   departament_id  NUMBER NOT NULL,
   nume            VARCHAR2(100),
   descriere       VARCHAR2(500),
   manager_nume    VARCHAR2(101),
   manager_email   VARCHAR2(100),
   numar_agenti    NUMBER,
   valid_from      DATE DEFAULT SYSDATE,
   valid_to        DATE,
   is_current      CHAR(1) DEFAULT 'Y',
   load_date       DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_departament PRIMARY KEY (departament_key) RELY,
   CONSTRAINT uk_dim_departament_id UNIQUE ( departament_id, valid_from )
);

create table TickLy_DW.dim_categorie (
   categorie_key          NUMBER GENERATED ALWAYS AS IDENTITY,
   categorie_id           NUMBER NOT NULL,
   nume                   VARCHAR2(100),
   descriere              VARCHAR2(500),
   categorie_parinte_id   NUMBER,
   categorie_parinte_nume VARCHAR2(100),
   nivel_ierarhie         NUMBER,
   categorie_completa     VARCHAR2(500),
   load_date              DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_categorie PRIMARY KEY (categorie_key) RELY,
   CONSTRAINT uk_dim_categorie_id UNIQUE ( categorie_id )
);

create table TickLy_DW.dim_topic (
   topic_key       NUMBER GENERATED ALWAYS AS IDENTITY,
   topic_id        NUMBER NOT NULL,
   nume            VARCHAR2(100),
   descriere       VARCHAR2(500),
   topic_type      CHAR(1),
   tip_serviciu    VARCHAR2(50),
   durata_estimata NUMBER,
   tarif           NUMBER(10,2),
   versiune        VARCHAR2(20),
   pret            NUMBER(10,2),
   stoc            NUMBER,
   load_date       DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_topic PRIMARY KEY (topic_key) RELY,
   CONSTRAINT uk_dim_topic_id UNIQUE ( topic_id )
);

create table TickLy_DW.dim_tag (
   tag_key   NUMBER GENERATED ALWAYS AS IDENTITY,
   tag_id    NUMBER NOT NULL,
   nume      VARCHAR2(50),
   culoare   VARCHAR2(20),
   descriere VARCHAR2(200),
   load_date DATE DEFAULT SYSDATE,
   CONSTRAINT pk_dim_tag PRIMARY KEY (tag_key) RELY,
   CONSTRAINT uk_dim_tag_id UNIQUE ( tag_id )
);

create table TickLy_DW.dim_time (
   date_key          NUMBER,
   data_completa     DATE NOT NULL,
   an                NUMBER(4) NOT NULL,
   trimestru         NUMBER(1) NOT NULL CHECK ( trimestru BETWEEN 1 AND 4 ),
   luna              NUMBER(2) NOT NULL CHECK ( luna BETWEEN 1 AND 12 ),
   luna_nume         VARCHAR2(20) NOT NULL,
   luna_abrev        VARCHAR2(3) NOT NULL,
   zi                NUMBER(2) NOT NULL CHECK ( zi BETWEEN 1 AND 31 ),
   saptamana_an      NUMBER(2) NOT NULL CHECK ( saptamana_an BETWEEN 1 AND 53 ),
   zi_saptamana      NUMBER(1) NOT NULL CHECK ( zi_saptamana BETWEEN 1 AND 7 ),
   zi_saptamana_nume VARCHAR2(20) NOT NULL,
   este_weekend      CHAR(1) DEFAULT 'N' CHECK ( este_weekend IN ( 'Y', 'N' ) ),
   CONSTRAINT pk_dim_time PRIMARY KEY (date_key) RELY,
   CONSTRAINT uk_dim_time_data UNIQUE ( data_completa )
);

CREATE TABLE TickLy_DW.fact_ticket (
   fact_ticket_id              NUMBER GENERATED ALWAYS AS IDENTITY,
   ticket_id                   NUMBER NOT NULL,
   client_key                  NUMBER NOT NULL,
   agent_key                   NUMBER NOT NULL,
   departament_key             NUMBER NOT NULL,
   categorie_key               NUMBER,
   topic_key                   NUMBER NOT NULL,
   date_creare_key             NUMBER NOT NULL,
   date_rezolvare_key          NUMBER,
   date_inchidere_key          NUMBER,
   status_id                   NUMBER NOT NULL,
   status_nume                 VARCHAR2(30) NOT NULL,
   status_este_final           CHAR(1),
   prioritate_id               NUMBER NOT NULL,
   prioritate_nume             VARCHAR2(20) NOT NULL,
   cost_estimativ              NUMBER(10,2),
   timp_rezolvare_ore          NUMBER,
   load_date                   DATE DEFAULT SYSDATE,
   CONSTRAINT pk_fact_ticket PRIMARY KEY (fact_ticket_id) RELY,
   CONSTRAINT fk_fact_client FOREIGN KEY (client_key) REFERENCES TickLy_DW.dim_client (client_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_agent FOREIGN KEY (agent_key) REFERENCES TickLy_DW.dim_agent (agent_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_dept FOREIGN KEY (departament_key) REFERENCES TickLy_DW.dim_departament (departament_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_cat FOREIGN KEY (categorie_key) REFERENCES TickLy_DW.dim_categorie (categorie_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_topic FOREIGN KEY (topic_key) REFERENCES TickLy_DW.dim_topic (topic_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_dt_cr FOREIGN KEY (date_creare_key) REFERENCES TickLy_DW.dim_time (date_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT uk_fact_ticket_id UNIQUE (ticket_id)
);

PARTITION BY RANGE (date_creare_key)
SUBPARTITION BY HASH (topic_key) SUBPARTITIONS 4
(
   PARTITION fact_tickets_2023 VALUES LESS THAN (20240000), 
   PARTITION fact_tickets_2024 VALUES LESS THAN (20250000), 
   PARTITION fact_tickets_2025 VALUES LESS THAN (20260000), 
   PARTITION fact_tickets_2026 VALUES LESS THAN (20270000),
   PARTITION fact_tickets_2027 VALUES LESS THAN (20280000),
   PARTITION fact_tickets_2028 VALUES LESS THAN (20290000),
   PARTITION fact_tickets_2029 VALUES LESS THAN (20300000),
   PARTITION fact_tickets_2030 VALUES LESS THAN (20310000),
   PARTITION fact_tickets_viitor VALUES LESS THAN (MAXVALUE) 
);

CREATE TABLE TickLy_DW.bridge_ticket_tag (
    bridge_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fact_ticket_id  NUMBER NOT NULL,
    tag_key         NUMBER NOT NULL,
    weight_factor   NUMBER DEFAULT 1,
    CONSTRAINT fk_bridge_fact FOREIGN KEY (fact_ticket_id) REFERENCES TickLy_DW.fact_ticket (fact_ticket_id) RELY DISABLE NOVALIDATE,
    CONSTRAINT fk_bridge_dim FOREIGN KEY (tag_key) REFERENCES TickLy_DW.dim_tag (tag_key) RELY DISABLE NOVALIDATE
);

COMMIT;

ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

create table TickLy_DW.dim_client (
   client_key         number generated always as identity,
   client_id          number not null,
   email              varchar2(100),
   phone              varchar2(20),
   registration_date  date,
   client_type        char(1),
   nume               varchar2(50),
   prenume            varchar2(50),
   cnp                varchar2(13),
   denumire           varchar2(200),
   cui                varchar2(20),
   sediu_social       varchar2(200),
   reprezentant_legal varchar2(100),
   is_active          char(1) default 'Y',
   valid_from         date default sysdate,
   valid_to           date,
   is_current         char(1) default 'Y',
   load_date          date default sysdate,
   CONSTRAINT pk_dim_client PRIMARY KEY (client_key) RELY,
   constraint uk_dim_client_id unique ( client_id, valid_from )
);

create table TickLy_DW.dim_agent (
   agent_key      number generated always as identity,
   agent_id       number not null,
   nume           varchar2(50),
   prenume        varchar2(50),
   nume_complet   varchar2(101),
   email          varchar2(100),
   telefon        varchar2(20),
   hire_date      date,
   is_active      char(1),
   ani_experienta number,
   valid_from     date default sysdate,
   valid_to       date,
   is_current     char(1) default 'Y',
   load_date      date default sysdate,
   CONSTRAINT pk_dim_agent PRIMARY KEY (agent_key) RELY,
   constraint uk_dim_agent_id unique ( agent_id, valid_from )
);

create table TickLy_DW.dim_departament (
   departament_key number generated always as identity,
   departament_id  number not null,
   nume            varchar2(100),
   descriere       varchar2(500),
   manager_nume    varchar2(101),
   manager_email   varchar2(100),
   numar_agenti    number,
   valid_from      date default sysdate,
   valid_to        date,
   is_current      char(1) default 'Y',
   load_date       date default sysdate,
   CONSTRAINT pk_dim_departament PRIMARY KEY (departament_key) RELY,
   constraint uk_dim_departament_id unique ( departament_id, valid_from )
);

create table TickLy_DW.dim_categorie (
   categorie_key          number generated always as identity,
   categorie_id           number not null,
   nume                   varchar2(100),
   descriere              varchar2(500),
   categorie_parinte_id   number,
   categorie_parinte_nume varchar2(100),
   nivel_ierarhie         number,
   categorie_completa     varchar2(500),
   load_date              date default sysdate,
   CONSTRAINT pk_dim_categorie PRIMARY KEY (categorie_key) RELY,
   constraint uk_dim_categorie_id unique ( categorie_id )
);

create table TickLy_DW.dim_topic (
   topic_key       number generated always as identity,
   topic_id        number not null,
   nume            varchar2(100),
   descriere       varchar2(500),
   topic_type      char(1),
   tip_serviciu    varchar2(50),
   durata_estimata number,
   tarif           number(10,2),
   versiune        varchar2(20),
   pret            number(10,2),
   stoc            number,
   load_date       date default sysdate,
   CONSTRAINT pk_dim_topic PRIMARY KEY (topic_key) RELY,
   constraint uk_dim_topic_id unique ( topic_id )
);

create table TickLy_DW.dim_tag (
   tag_key   number generated always as identity,
   tag_id    number not null,
   nume      varchar2(50),
   culoare   varchar2(20),
   descriere varchar2(200),
   load_date date default sysdate,
   CONSTRAINT pk_dim_tag PRIMARY KEY (tag_key) RELY,
   constraint uk_dim_tag_id unique ( tag_id )
);

create table TickLy_DW.dim_time (
   date_key          number,
   data_completa     date not null,
   an                number(4) not null,
   trimestru         number(1) not null check ( trimestru between 1 and 4 ),
   luna              number(2) not null check ( luna between 1 and 12 ),
   luna_nume         varchar2(20) not null,
   luna_abrev        varchar2(3) not null,
   zi                number(2) not null check ( zi between 1 and 31 ),
   saptamana_an      number(2) not null check ( saptamana_an between 1 and 53 ),
   zi_saptamana      number(1) not null check ( zi_saptamana between 1 and 7 ),
   zi_saptamana_nume varchar2(20) not null,
   este_weekend      char(1) default 'N' check ( este_weekend in ( 'Y', 'N' ) ),
   CONSTRAINT pk_dim_time PRIMARY KEY (date_key) RELY,
   constraint uk_dim_time_data unique ( data_completa )
);

CREATE TABLE TickLy_DW.fact_ticket (
   fact_ticket_id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
   CONSTRAINT fk_fact_client FOREIGN KEY (client_key) REFERENCES TickLy_DW.dim_client (client_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_agent FOREIGN KEY (agent_key) REFERENCES TickLy_DW.dim_agent (agent_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_dept FOREIGN KEY (departament_key) REFERENCES TickLy_DW.dim_departament (departament_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_cat FOREIGN KEY (categorie_key) REFERENCES TickLy_DW.dim_categorie (categorie_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_topic FOREIGN KEY (topic_key) REFERENCES TickLy_DW.dim_topic (topic_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT fk_fact_dt_cr FOREIGN KEY (date_creare_key) REFERENCES TickLy_DW.dim_time (date_key) RELY DISABLE NOVALIDATE,
   CONSTRAINT uk_fact_ticket_id UNIQUE (ticket_id)
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

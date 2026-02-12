ALTER SESSION SET CONTAINER = orclpdb1;
WHENEVER SQLERROR EXIT FAILURE;

/* tabela main focused: ticket */
/* deoarece este tabela principala, se vor crea indecsi pe toate coloanele care sunt FK */
/* riscul este sa se faca table scan pe tabelele children si se ajunge la Table Lock-uri */
CREATE INDEX TickLy.idx_ticket_client ON TickLy.ticket(client_id);
CREATE INDEX TickLy.idx_ticket_dept ON TickLy.ticket(departament_id);
CREATE INDEX TickLy.idx_ticket_status ON TickLy.ticket(status_id);
CREATE INDEX TickLy.idx_ticket_prioritate ON TickLy.ticket(prioritate_id);
CREATE INDEX TickLy.idx_ticket_categ ON TickLy.ticket(categorie_id);
CREATE INDEX TickLy.idx_comm_client_tid ON TickLy.comment_client(ticket_id);
CREATE INDEX TickLy.idx_comm_agent_tid ON TickLy.comment_agent(ticket_id);
CREATE INDEX TickLy.idx_hist_ticket_tid ON TickLy.ticket_history(ticket_id);

/* tabela main focused: ticket */
/* Index B*Tree pentru a indexa rapid coloana data_creare */
CREATE INDEX TickLy.idx_ticket_data_creare ON TickLy.ticket(data_creare);

/* tabele client_fizica si client_juridica  */
/* acestia sunt indexi care sunt nevoiti pentru a face căutări case-insensitive */
CREATE INDEX TickLy.idx_client_nume_upper ON TickLy.client_fizica(UPPER(nume));
CREATE INDEX TickLy.idx_client_prenume_upper ON TickLy.client_fizica(UPPER(prenume));
CREATE INDEX TickLy.idx_juridic_denumire_upper ON TickLy.client_juridica(UPPER(denumire));

/* tabela ticket_agent */
/* pentru a afisa toate tichetele alocate unui agent specific */
CREATE INDEX TickLy.idx_ticket_agent_rev ON TickLy.ticket_agent(agent_id);

/* tabela ticket_tag */
/* pentru a afisa toate tichetele cu un tag specific */
CREATE INDEX TickLy.idx_ticket_tag_rev ON TickLy.ticket_tag(tag_id);

/* tabela atasament */
CREATE INDEX TickLy.idx_atasament_ticket_id ON TickLy.atasament(ticket_id);

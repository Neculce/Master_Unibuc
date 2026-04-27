ALTER SESSION SET CONTAINER = PDB1;

CREATE OR REPLACE VIEW TickLy.v_agent_global AS
SELECT 
    p.agent_id, p.nume, p.prenume, p.telefon,
    s.email, s.is_active
FROM TickLy.agent_profil p
JOIN TickLy.agent_sec@link_sv3 s ON p.agent_id = s.agent_id;

CREATE OR REPLACE VIEW TickLy.v_toate_tichetele AS
SELECT ticket_id, client_id, 'FIZIC' AS tip, titlu, data_creare FROM TickLy.ticket_fizic
UNION ALL
SELECT ticket_id, client_id, 'JURIDIC' AS tip, titlu, data_creare FROM TickLy.ticket_juridic@link_sv2;
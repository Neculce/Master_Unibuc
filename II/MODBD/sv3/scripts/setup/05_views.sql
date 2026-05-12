ALTER SESSION SET CONTAINER = PDB3;

CREATE OR REPLACE VIEW TICKLY.v_client_fizic_auth AS
SELECT s.client_id, p.prenume || ' ' || p.nume AS display_name, s.email, s.password_hash, s.is_active
FROM TICKLY.client_fizic_sec s
JOIN TICKLY.client_fizic@LINK_SV1 p ON s.client_id = p.client_id;

CREATE OR REPLACE VIEW TICKLY.v_client_juridic_auth AS
SELECT s.client_id, p.denumire AS display_name, s.email, s.password_hash, s.is_active
FROM TICKLY.client_juridic_sec s
JOIN TICKLY.client_juridic@LINK_SV2 p ON s.client_id = p.client_id;

CREATE OR REPLACE VIEW TICKLY.v_agent_auth AS
SELECT s.agent_id, 
       NVL(p1.prenume || ' ' || p1.nume, p2.prenume || ' ' || p2.nume) AS display_name, 
       s.email, s.password_hash, s.is_active
FROM TICKLY.agent_sec s
LEFT JOIN TICKLY.agent_profil@LINK_SV1 p1 ON s.agent_id = p1.agent_id
LEFT JOIN TICKLY.agent_profil@LINK_SV2 p2 ON s.agent_id = p2.agent_id;

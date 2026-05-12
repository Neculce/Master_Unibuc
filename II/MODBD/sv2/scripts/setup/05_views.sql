ALTER SESSION SET CONTAINER = PDB2;

CREATE OR REPLACE VIEW TICKLY.V_CLIENT_JURIDIC_AUTH AS
SELECT c.client_id, c.denumire AS display_name, s.email, s.password_hash
FROM TICKLY.client_juridic c
INNER JOIN TICKLY.client_juridic_sec@LINK_SV3 s ON c.client_id = s.client_id
WHERE s.is_active = 'Y';

CREATE OR REPLACE VIEW TICKLY.V_TICKET_B2B AS
SELECT ticket_id, client_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare, data_rezolvare
FROM TICKLY.ticket_juridic;
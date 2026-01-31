-- Rulare ca SYSTEM: inserări în schema TickLy.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

-- Prioritate (nivel 1-5) --
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (1, 'Critică', 'Intervenție imediată', 1);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (2, 'Înaltă', 'În aceeași zi', 4);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (3, 'Medie', 'În 24-48 ore', 24);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (4, 'Scăzută', 'În 3-5 zile', 72);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (5, 'Minimă', 'Când este posibil', 120);

-- Status --
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Deschis', 'Ticket nou, nepreluat', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('În desfășurare', 'Lucrat de agent', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('În așteptare', 'Așteaptă răspuns client', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Rezolvat', 'Soluție aplicată', 'Y');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Închis', 'Ticket închis', 'Y');

-- Agent --
INSERT INTO TickLy.agent (nume, prenume, email, telefon, hire_date, is_active)
VALUES ('Popescu', 'Maria', 'maria.popescu@tickly.ro', '0722111001', DATE '2022-01-15', 'Y');
INSERT INTO TickLy.agent (nume, prenume, email, telefon, hire_date, is_active)
VALUES ('Ionescu', 'Andrei', 'andrei.ionescu@tickly.ro', '0722111002', DATE '2022-06-01', 'Y');
INSERT INTO TickLy.agent (nume, prenume, email, telefon, hire_date, is_active)
VALUES ('Marinescu', 'Elena', 'elena.marinescu@tickly.ro', '0722111003', DATE '2023-02-10', 'Y');
INSERT INTO TickLy.agent (nume, prenume, email, telefon, hire_date, is_active)
VALUES ('Dumitrescu', 'Alexandru', 'alex.dumitrescu@tickly.ro', '0722111004', DATE '2023-09-01', 'Y');
INSERT INTO TickLy.agent (nume, prenume, email, telefon, hire_date, is_active)
VALUES ('Stan', 'Ioana', 'ioana.stan@tickly.ro', '0722111005', DATE '2024-01-15', 'Y');

-- Client (F = fizică, J = juridică) --
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('ion.vasile@gmail.com', '0733123456', DATE '2023-01-10', 'F');
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('ana.mihai@yahoo.ro', '0744234567', DATE '2023-03-20', 'F');
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('contact@softtech.ro', '0213123456', DATE '2023-05-01', 'J');
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('george.radu@outlook.com', '0755345678', DATE '2023-07-15', 'F');
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('office@constructii-abc.ro', '0264123456', DATE '2023-09-01', 'J');
INSERT INTO TickLy.client (email, phone, registration_date, client_type)
VALUES ('cristina.negru@gmail.com', '0766456789', DATE '2024-01-05', 'F');

-- Client fizică (pentru client_type = 'F') --
INSERT INTO TickLy.client_fizica (client_id, cnp, nume, prenume, data_nasterii)
SELECT client_id, '1890101123456', 'Vasile', 'Ion', DATE '1989-01-01' FROM TickLy.client WHERE email = 'ion.vasile@gmail.com';
INSERT INTO TickLy.client_fizica (client_id, cnp, nume, prenume, data_nasterii)
SELECT client_id, '2950515234567', 'Mihai', 'Ana', DATE '1995-05-15' FROM TickLy.client WHERE email = 'ana.mihai@yahoo.ro';
INSERT INTO TickLy.client_fizica (client_id, cnp, nume, prenume, data_nasterii)
SELECT client_id, '1880707345678', 'Radu', 'George', DATE '1988-07-07' FROM TickLy.client WHERE email = 'george.radu@outlook.com';
INSERT INTO TickLy.client_fizica (client_id, cnp, nume, prenume, data_nasterii)
SELECT client_id, '2981212456789', 'Negru', 'Cristina', DATE '1998-12-12' FROM TickLy.client WHERE email = 'cristina.negru@gmail.com';

-- Client juridică (pentru client_type = 'J') --
INSERT INTO TickLy.client_juridica (client_id, cui, denumire, sediu_social, numar_inregistrare, reprezentant_legal)
SELECT client_id, 'RO12345678', 'SoftTech SRL', 'București, Str. Tehnologiei 10', 'J40/123/2023', 'Mihai Popescu'
FROM TickLy.client WHERE email = 'contact@softtech.ro';
INSERT INTO TickLy.client_juridica (client_id, cui, denumire, sediu_social, numar_inregistrare, reprezentant_legal)
SELECT client_id, 'RO87654321', 'Constructii ABC SA', 'Cluj-Napoca, Calea Dorobanților 5', 'J12/456/2020', 'Andrei Ionescu'
FROM TickLy.client WHERE email = 'office@constructii-abc.ro';

-- Adresă --
INSERT INTO TickLy.adresa (client_id, tip_adresa, strada, numar, oras, judet, cod_postal, tara, este_principala)
SELECT client_id, 'LIVRARE', 'Str. Florilor', '15', 'București', 'București', '012345', 'Romania', 'Y'
FROM TickLy.client WHERE email = 'ion.vasile@gmail.com';
INSERT INTO TickLy.adresa (client_id, tip_adresa, strada, numar, oras, judet, cod_postal, este_principala)
SELECT client_id, 'FACTURARE', 'Str. Tehnologiei', '10', 'București', 'București', '012346', 'Y'
FROM TickLy.client WHERE email = 'contact@softtech.ro';
INSERT INTO TickLy.adresa (client_id, tip_adresa, strada, numar, oras, judet, cod_postal, este_principala)
SELECT client_id, 'SEDIU', 'Calea Dorobanților', '5', 'Cluj-Napoca', 'Cluj', '400123', 'Y'
FROM TickLy.client WHERE email = 'office@constructii-abc.ro';

-- Departament (manager_id = agent) --
INSERT INTO TickLy.departament (nume, descriere, manager_id)
SELECT 'Suport tehnic', 'Suport pentru produse software și infrastructură', agent_id FROM TickLy.agent WHERE email = 'maria.popescu@tickly.ro';
INSERT INTO TickLy.departament (nume, descriere, manager_id)
SELECT 'Vânzări și onboarding', 'Întrebări comerciale și integrare', agent_id FROM TickLy.agent WHERE email = 'andrei.ionescu@tickly.ro';
INSERT INTO TickLy.departament (nume, descriere, manager_id)
SELECT 'Facturare', 'Plăți, facturi, abonamente', agent_id FROM TickLy.agent WHERE email = 'elena.marinescu@tickly.ro';

-- Topic (S = serviciu, P = produs) --
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('Instalare licență', 'Probleme la activare/instalare', 'S');
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('Consultanță implementare', 'Ore de consultanță', 'S');
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('TickLy Standard', 'Produs plan Standard', 'P');
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('TickLy Enterprise', 'Produs plan Enterprise', 'P');
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('Facturare și plăți', 'Întrebări facturare', 'S');

-- Topic serviciu / produs --
INSERT INTO TickLy.topic_serviciu (topic_id, tip_serviciu, durata_estimata, tarif)
SELECT topic_id, 'Instalare la sediu', 4, 500.00 FROM TickLy.topic WHERE nume = 'Instalare licență';
INSERT INTO TickLy.topic_serviciu (topic_id, tip_serviciu, durata_estimata, tarif)
SELECT topic_id, 'Consultant/zi', 8, 1200.00 FROM TickLy.topic WHERE nume = 'Consultanță implementare';
INSERT INTO TickLy.topic_serviciu (topic_id, tip_serviciu, durata_estimata, tarif)
SELECT topic_id, 'Suport facturare', NULL, NULL FROM TickLy.topic WHERE nume = 'Facturare și plăți';
INSERT INTO TickLy.topic_produs (topic_id, versiune, categorie, pret, stoc)
SELECT topic_id, '2024.1', 'Software', 299.00, NULL FROM TickLy.topic WHERE nume = 'TickLy Standard';
INSERT INTO TickLy.topic_produs (topic_id, versiune, categorie, pret, stoc)
SELECT topic_id, '2024.1', 'Software', 899.00, NULL FROM TickLy.topic WHERE nume = 'TickLy Enterprise';

-- Categorie (rădăcini, apoi copii) --
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id) VALUES ('Software', 'Probleme legate de aplicații', NULL);
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id) VALUES ('Licențe', 'Activare, prelungire licențe', NULL);
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id)
SELECT 'Bug', 'Defecte în produs', categorie_id FROM TickLy.categorie WHERE nume = 'Software' AND categorie_parinte_id IS NULL;
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id)
SELECT 'Cerere funcționalitate', 'Feature request', categorie_id FROM TickLy.categorie WHERE nume = 'Software' AND categorie_parinte_id IS NULL;

-- Ticket --
INSERT INTO TickLy.ticket (client_id, departament_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare, data_rezolvare, data_inchidere, timp_rezolvare_ore)
SELECT c.client_id, d.departament_id, pr.prioritate_id, s.status_id, cat.categorie_id,
       'Nu se activează licența', 'După instalare, licența nu este recunoscută.', DATE '2024-06-01', DATE '2024-06-02', DATE '2024-06-02', 24
FROM TickLy.client c, TickLy.departament d, TickLy.prioritate pr, TickLy.status s, TickLy.categorie cat
WHERE c.email = 'ion.vasile@gmail.com' AND d.nume = 'Suport tehnic' AND pr.nivel = 2 AND s.nume = 'Rezolvat'
  AND cat.nume = 'Licențe';

INSERT INTO TickLy.ticket (client_id, departament_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare)
SELECT c.client_id, d.departament_id, pr.prioritate_id, s.status_id, cat.categorie_id,
       'Factură greșită', 'Factura din luna trecută conține un serviciu neachitat.', DATE '2024-06-10'
FROM TickLy.client c, TickLy.departament d, TickLy.prioritate pr, TickLy.status s, TickLy.categorie cat
WHERE c.email = 'contact@softtech.ro' AND d.nume = 'Facturare' AND pr.nivel = 3 AND s.nume = 'În desfășurare'
  AND cat.nume = 'Software' AND cat.categorie_parinte_id IS NULL;

INSERT INTO TickLy.ticket (client_id, departament_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare, data_rezolvare, data_inchidere, timp_rezolvare_ore)
SELECT c.client_id, d.departament_id, pr.prioritate_id, s.status_id, cat.categorie_id,
       'Eroare la export raport', 'Export CSV dă eroare pentru date > 10000 rânduri.', DATE '2024-05-15', DATE '2024-05-17', DATE '2024-05-18', 48
FROM TickLy.client c, TickLy.departament d, TickLy.prioritate pr, TickLy.status s, TickLy.categorie cat
WHERE c.email = 'ana.mihai@yahoo.ro' AND d.nume = 'Suport tehnic' AND pr.nivel = 3 AND s.nume = 'Închis'
  AND cat.nume = 'Bug' AND cat.categorie_parinte_id IS NOT NULL;

INSERT INTO TickLy.ticket (client_id, departament_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare)
SELECT c.client_id, d.departament_id, pr.prioritate_id, s.status_id, NULL,
       'Întrebare despre Enterprise', 'Ce module sunt incluse în Enterprise?', DATE '2024-06-12'
FROM TickLy.client c, TickLy.departament d, TickLy.prioritate pr, TickLy.status s
WHERE c.email = 'george.radu@outlook.com' AND d.nume = 'Vânzări și onboarding' AND pr.nivel = 4 AND s.nume = 'Deschis';

INSERT INTO TickLy.ticket (client_id, departament_id, prioritate_id, status_id, categorie_id, titlu, descriere, data_creare)
SELECT c.client_id, d.departament_id, pr.prioritate_id, s.status_id, cat.categorie_id,
       'Integrare API', 'Documentație pentru API v2.', DATE '2024-06-11'
FROM TickLy.client c, TickLy.departament d, TickLy.prioritate pr, TickLy.status s, TickLy.categorie cat
WHERE c.email = 'office@constructii-abc.ro' AND d.nume = 'Suport tehnic' AND pr.nivel = 3 AND s.nume = 'În așteptare'
  AND cat.nume = 'Software' AND cat.categorie_parinte_id IS NULL;

-- Comment client / agent --
INSERT INTO TickLy.comment_client (ticket_id, client_id, content, created_date, is_internal)
SELECT t.ticket_id, c.client_id, 'Am reinstalat aplicația dar problema persistă.', DATE '2024-06-01', 'N'
FROM TickLy.ticket t, TickLy.client c WHERE c.email = 'ion.vasile@gmail.com' AND t.titlu = 'Nu se activează licența' AND t.client_id = c.client_id;

INSERT INTO TickLy.comment_agent (ticket_id, agent_id, content, created_date, is_internal)
SELECT t.ticket_id, a.agent_id, 'Am trimis cheia de activare pe email. Verificați și spam.', DATE '2024-06-02', 'N'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Nu se activează licența' AND a.email = 'maria.popescu@tickly.ro';

INSERT INTO TickLy.comment_agent (ticket_id, agent_id, content, created_date, is_internal)
SELECT t.ticket_id, a.agent_id, 'Client notificat. Aștept confirmare.', DATE '2024-06-11', 'Y'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Integrare API' AND a.email = 'alex.dumitrescu@tickly.ro';

-- KB Article --
INSERT INTO TickLy.kb_article (agent_id, categorie_id, titlu, content, keywords, vizualizari, rating_mediu, data_creare, este_public)
SELECT a.agent_id, cat.categorie_id, 'Cum activez licența TickLy',
       'Pași: 1) Deschideți Setări > Licență. 2) Introduceți cheia primită pe email. 3) Apăsați Activate.',
       'licență, activare, cheie', 150, 4.5, DATE '2024-01-10', 'Y'
FROM TickLy.agent a, TickLy.categorie cat WHERE a.email = 'maria.popescu@tickly.ro' AND cat.nume = 'Licențe';

INSERT INTO TickLy.kb_article (agent_id, categorie_id, titlu, content, keywords, vizualizari, rating_mediu, data_creare, este_public)
SELECT a.agent_id, NULL, 'Politica de facturare',
       'Facturare lunară la data 1. Plăți acceptate: card, transfer, OP.',
       'facturare, plată, OP', 89, 4.0, DATE '2024-02-01', 'Y'
FROM TickLy.agent a WHERE a.email = 'elena.marinescu@tickly.ro';

-- Atasament (exemplu pe ticket) --
INSERT INTO TickLy.atasament (ticket_id, kb_article_id, file_name, file_path, file_size, file_type, upload_date, uploader_id, uploader_type)
SELECT t.ticket_id, NULL, 'screenshot_eroare.png', '/uploads/ticket/1/screenshot_eroare.png', 125000, 'image/png', DATE '2024-06-01', c.client_id, 'C'
FROM TickLy.ticket t, TickLy.client c WHERE t.titlu = 'Nu se activează licența' AND t.client_id = c.client_id AND c.email = 'ion.vasile@gmail.com';

-- Tag --
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('urgent', '#FF0000', 'Cerere urgentă');
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('licență', '#0066CC', 'Legat de licențe');
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('facturare', '#00AA00', 'Facturare și plăți');
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('bug', '#FF6600', 'Defect confirmat');

-- Feedback --
INSERT INTO TickLy.feedback (ticket_id, rating, comentariu, data_feedback)
SELECT t.ticket_id, 5, 'Rezolvare rapidă, mulțumesc!', DATE '2024-06-03'
FROM TickLy.ticket t WHERE t.titlu = 'Nu se activează licența';

INSERT INTO TickLy.feedback (ticket_id, rating, comentariu, data_feedback)
SELECT t.ticket_id, 4, 'Ok, dar a durat puțin.', DATE '2024-05-19'
FROM TickLy.ticket t WHERE t.titlu = 'Eroare la export raport';

-- Soluție (pentru ticket-uri rezolvate/închise) --
INSERT INTO TickLy.solutie (ticket_id, agent_id, descriere_solutie, pasi_rezolvare, data_rezolvare, timp_rezolvare_minute)
SELECT t.ticket_id, a.agent_id, 'Licența a fost reactivată din backend; clientul a reintrodus cheia.',
       '1) Verificat cheie în admin. 2) Resetat activare. 3) Retrimis email cu instrucțiuni.', DATE '2024-06-02', 45
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Nu se activează licența' AND a.email = 'maria.popescu@tickly.ro';

INSERT INTO TickLy.solutie (ticket_id, agent_id, descriere_solutie, pasi_rezolvare, data_rezolvare, timp_rezolvare_minute)
SELECT t.ticket_id, a.agent_id, 'Patch pentru export > 10000 rânduri; livrat în versiunea 2024.1.1.',
       '1) Reproduct. 2) Fix în cod. 3) Build și notificare client.', DATE '2024-05-17', 120
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Eroare la export raport' AND a.email = 'andrei.ionescu@tickly.ro';

-- Ticket-Agent (asignare) --
INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
SELECT t.ticket_id, a.agent_id, 'PRIMARY', DATE '2024-06-01'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Nu se activează licența' AND a.email = 'maria.popescu@tickly.ro';
INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
SELECT t.ticket_id, a.agent_id, 'PRIMARY', DATE '2024-06-10'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Factură greșită' AND a.email = 'elena.marinescu@tickly.ro';
INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
SELECT t.ticket_id, a.agent_id, 'PRIMARY', DATE '2024-05-15'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Eroare la export raport' AND a.email = 'andrei.ionescu@tickly.ro';
INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
SELECT t.ticket_id, a.agent_id, 'PRIMARY', DATE '2024-06-12'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Întrebare despre Enterprise' AND a.email = 'andrei.ionescu@tickly.ro';
INSERT INTO TickLy.ticket_agent (ticket_id, agent_id, rol, data_asignare)
SELECT t.ticket_id, a.agent_id, 'PRIMARY', DATE '2024-06-11'
FROM TickLy.ticket t, TickLy.agent a WHERE t.titlu = 'Integrare API' AND a.email = 'alex.dumitrescu@tickly.ro';

-- Ticket-Topic --
INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
SELECT t.ticket_id, tp.topic_id, 'DIRECT'
FROM TickLy.ticket t, TickLy.topic tp WHERE t.titlu = 'Nu se activează licența' AND tp.nume = 'Instalare licență';
INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
SELECT t.ticket_id, tp.topic_id, 'DIRECT'
FROM TickLy.ticket t, TickLy.topic tp WHERE t.titlu = 'Factură greșită' AND tp.nume = 'Facturare și plăți';
INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
SELECT t.ticket_id, tp.topic_id, 'DIRECT'
FROM TickLy.ticket t, TickLy.topic tp WHERE t.titlu = 'Eroare la export raport' AND tp.nume = 'TickLy Standard';
INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
SELECT t.ticket_id, tp.topic_id, 'DIRECT'
FROM TickLy.ticket t, TickLy.topic tp WHERE t.titlu = 'Întrebare despre Enterprise' AND tp.nume = 'TickLy Enterprise';
INSERT INTO TickLy.ticket_topic (ticket_id, topic_id, relevanta)
SELECT t.ticket_id, tp.topic_id, 'DIRECT'
FROM TickLy.ticket t, TickLy.topic tp WHERE t.titlu = 'Integrare API' AND tp.nume = 'TickLy Enterprise';

-- Agent-Departament --
INSERT INTO TickLy.agent_departament (agent_id, departament_id, este_principal, data_inceput)
SELECT a.agent_id, d.departament_id, 'Y', DATE '2022-01-15'
FROM TickLy.agent a, TickLy.departament d WHERE a.email = 'maria.popescu@tickly.ro' AND d.nume = 'Suport tehnic';
INSERT INTO TickLy.agent_departament (agent_id, departament_id, este_principal, data_inceput)
SELECT a.agent_id, d.departament_id, 'Y', DATE '2022-06-01'
FROM TickLy.agent a, TickLy.departament d WHERE a.email = 'andrei.ionescu@tickly.ro' AND d.nume = 'Vânzări și onboarding';
INSERT INTO TickLy.agent_departament (agent_id, departament_id, este_principal, data_inceput)
SELECT a.agent_id, d.departament_id, 'Y', DATE '2023-02-10'
FROM TickLy.agent a, TickLy.departament d WHERE a.email = 'elena.marinescu@tickly.ro' AND d.nume = 'Facturare';
INSERT INTO TickLy.agent_departament (agent_id, departament_id, este_principal, data_inceput)
SELECT a.agent_id, d.departament_id, 'N', DATE '2023-09-01'
FROM TickLy.agent a, TickLy.departament d WHERE a.email = 'alex.dumitrescu@tickly.ro' AND d.nume = 'Suport tehnic';
INSERT INTO TickLy.agent_departament (agent_id, departament_id, este_principal, data_inceput)
SELECT a.agent_id, d.departament_id, 'N', DATE '2024-01-15'
FROM TickLy.agent a, TickLy.departament d WHERE a.email = 'ioana.stan@tickly.ro' AND d.nume = 'Vânzări și onboarding';

-- Ticket-Tag --
INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
SELECT t.ticket_id, tg.tag_id FROM TickLy.ticket t, TickLy.tag tg WHERE t.titlu = 'Nu se activează licența' AND tg.nume = 'licență';
INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
SELECT t.ticket_id, tg.tag_id FROM TickLy.ticket t, TickLy.tag tg WHERE t.titlu = 'Nu se activează licența' AND tg.nume = 'urgent';
INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
SELECT t.ticket_id, tg.tag_id FROM TickLy.ticket t, TickLy.tag tg WHERE t.titlu = 'Factură greșită' AND tg.nume = 'facturare';
INSERT INTO TickLy.ticket_tag (ticket_id, tag_id)
SELECT t.ticket_id, tg.tag_id FROM TickLy.ticket t, TickLy.tag tg WHERE t.titlu = 'Eroare la export raport' AND tg.nume = 'bug';

COMMIT;

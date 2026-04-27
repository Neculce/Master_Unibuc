ALTER SESSION SET CONTAINER = PDB4;

INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (1, 'Critica', 'Interventie imediata', 1);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (2, 'Inalta', 'In aceeasi zi', 4);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (3, 'Medie', 'In 24-48 ore', 24);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (4, 'Scazuta', 'In 3-5 zile', 72);
INSERT INTO TickLy.prioritate (nivel, nume, descriere, timp_raspuns_ore) VALUES (5, 'Minima', 'Cand este posibil', 120);

INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Deschis', 'Ticket nou, nepreluat', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('In desfasurare', 'Lucrat de agent', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('In asteptare', 'Asteapta raspuns client', 'N');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Rezolvat', 'Solutie aplicata', 'Y');
INSERT INTO TickLy.status (nume, descriere, este_final) VALUES ('Inchis', 'Ticket inchis', 'Y');

INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id) VALUES ('Software', 'Probleme legate de aplicatii', NULL);
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id) VALUES ('Licente', 'Activare, prelungire licente', NULL);
INSERT INTO TickLy.categorie (nume, descriere, categorie_parinte_id)
SELECT 'Bug', 'Defecte in produs', categorie_id FROM TickLy.categorie WHERE nume = 'Software';

INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('Instalare licenta', 'Probleme la activare', 'S');
INSERT INTO TickLy.topic (nume, descriere, topic_type) VALUES ('TickLy Enterprise', 'Produs plan Enterprise', 'P');

INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('urgent', '#FF0000', 'Cerere urgenta');
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('licenta', '#0066CC', 'Legat de licente');
INSERT INTO TickLy.tag (nume, culoare, descriere) VALUES ('bug', '#FF6600', 'Defect confirmat');

COMMIT;
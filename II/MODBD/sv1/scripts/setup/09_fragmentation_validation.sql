ALTER SESSION SET CONTAINER = PDB1;

/*
VERIFICAREA RECONSTRUCTIEI FRAGMENTARII ORIZONTALE
*/

/*
Reconstruirea relatiei globale TICKET
din fragmentele:

* TICKET_FIZIC
* TICKET_JURIDIC
  */

SELECT *
FROM TICKLY.ticket_fizic

UNION ALL

SELECT *
FROM TICKLY.ticket_juridic@LINK_SV2;

/*
VERIFICAREA DISJUNCTIEI FRAGMENTARII ORIZONTALE
*/

/*
Verificam daca acelasi ticket apare
simultan in ambele fragmente
Rezultatul corect:
no rows selected
*/

SELECT tf.ticket_id
FROM TICKLY.ticket_fizic tf
JOIN TICKLY.ticket_juridic@LINK_SV2 tj
ON tf.ticket_id = tj.ticket_id;
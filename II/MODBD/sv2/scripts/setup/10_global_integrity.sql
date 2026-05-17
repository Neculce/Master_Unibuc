ALTER SESSION SET CONTAINER = PDB2;

/*
   INTEGRITATE GLOBALA PENTRU TICKET_JURIDIC

   Verificam ca status_id si prioritate_id exista in baza master SV4.
*/

CREATE OR REPLACE TRIGGER TICKLY.trg_ticket_juridic_global_integrity
BEFORE INSERT OR UPDATE ON TICKLY.ticket_juridic
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM TICKLY.status@LINK_SV4
    WHERE status_id = :NEW.status_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Statusul nu exista in baza master SV4.'
        );
    END IF;

    SELECT COUNT(*)
    INTO v_count
    FROM TICKLY.prioritate@LINK_SV4
    WHERE prioritate_id = :NEW.prioritate_id;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Prioritatea nu exista in baza master SV4.'
        );
    END IF;
END;
/
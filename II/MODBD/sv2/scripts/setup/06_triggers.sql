ALTER SESSION SET CONTAINER = PDB2;

CREATE OR REPLACE TRIGGER TickLy.trg_fk_global_status
BEFORE INSERT OR UPDATE ON TickLy.ticket_fizic
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM TickLy.status
    WHERE status_id = :NEW.status_id;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Status ID invalid!');
    END IF;
END;
/
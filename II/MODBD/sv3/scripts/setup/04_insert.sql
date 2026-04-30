ALTER SESSION SET CONTAINER = PDB3;

INSERT INTO TICKLY.agent_sec (email, password_hash, is_active)
VALUES ('maria.popescu@TICKLY.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');
INSERT INTO TICKLY.agent_sec (email, password_hash, is_active)
VALUES ('andrei.ionescu@TICKLY.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');
INSERT INTO TICKLY.agent_sec (email, password_hash, is_active)
VALUES ('alex.dumitrescu@TICKLY.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');

COMMIT;
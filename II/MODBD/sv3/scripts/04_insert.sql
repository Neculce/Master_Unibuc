ALTER SESSION SET CONTAINER = PDB3;

INSERT INTO TickLy.agent_sec (email, password_hash, is_active)
VALUES ('maria.popescu@tickly.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');
INSERT INTO TickLy.agent_sec (email, password_hash, is_active)
VALUES ('andrei.ionescu@tickly.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');
INSERT INTO TickLy.agent_sec (email, password_hash, is_active)
VALUES ('alex.dumitrescu@tickly.ro', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Y');

COMMIT;
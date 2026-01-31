-- Rulare ca SYSTEM: indecșii se creează în schema TickLy.
WHENEVER SQLERROR EXIT FAILURE;

CREATE INDEX idx_ticket_client ON TickLy.ticket(client_id);
CREATE INDEX idx_ticket_status ON TickLy.ticket(status_id);
CREATE INDEX idx_ticket_departament ON TickLy.ticket(departament_id);
CREATE INDEX idx_ticket_categorie ON TickLy.ticket(categorie_id);
CREATE INDEX idx_comment_client_ticket ON TickLy.comment_client(ticket_id);
CREATE INDEX idx_comment_client_client ON TickLy.comment_client(client_id);
CREATE INDEX idx_comment_agent_ticket ON TickLy.comment_agent(ticket_id);
CREATE INDEX idx_comment_agent_agent ON TickLy.comment_agent(agent_id);
CREATE INDEX idx_atasament_ticket ON TickLy.atasament(ticket_id);
CREATE INDEX idx_adresa_client ON TickLy.adresa(client_id);

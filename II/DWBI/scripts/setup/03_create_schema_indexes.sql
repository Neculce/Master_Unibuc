WHENEVER SQLERROR EXIT FAILURE;

CREATE INDEX idx_ticket_client ON ticket(client_id);
CREATE INDEX idx_ticket_status ON ticket(status_id);
CREATE INDEX idx_ticket_departament ON ticket(departament_id);
CREATE INDEX idx_ticket_categorie ON ticket(categorie_id);
CREATE INDEX idx_comment_client_ticket ON comment_client(ticket_id);
CREATE INDEX idx_comment_client_client ON comment_client(client_id);
CREATE INDEX idx_comment_agent_ticket ON comment_agent(ticket_id);
CREATE INDEX idx_comment_agent_agent ON comment_agent(agent_id);
CREATE INDEX idx_atasament_ticket ON atasament(ticket_id);
CREATE INDEX idx_adresa_client ON adresa(client_id);

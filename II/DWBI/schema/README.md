# TickLy - Diagrama Conceptuală OLTP (Actualizată)

## 📋 ENTITĂȚI PRINCIPALE (Independente)

### 1. **CLIENT** (entitate părinte)
**PK:** `client_id`  
**Atribute:**
- `client_id` (PK, IDENTITY)
- `email` (UNIQUE, NOT NULL)
- `password_hash` (NOT NULL)
- `phone`
- `registration_date` (DEFAULT SYSDATE)
- `client_type` ('F' sau 'J')

**Relații:**
- 1:M → Ticket, Adresa, Comment_Client

---

### 2. **AGENT**
**PK:** `agent_id`  
**Atribute:**
- `agent_id` (PK, IDENTITY)
- `nume`, `prenume` (NOT NULL)
- `email` (UNIQUE, NOT NULL)
- `password_hash` (NOT NULL)
- `telefon`
- `hire_date` (DEFAULT SYSDATE)
- `is_active` ('Y'/'N')

**Relații:**
- 1:M → KB_Article, Comment_Agent, Solutie, Departament (Manager)
- M:N → Departament (Agent_Departament), Ticket (Ticket_Agent)

---

### 3. **TICKET**
**PK:** `ticket_id`  
**Atribute:**
- `ticket_id` (PK, IDENTITY)
- `titlu` (NOT NULL)
- `descriere` (CLOB)
- `data_creare` (DEFAULT SYSDATE)
- `data_ultima_actualizare`
- `data_rezolvare`, `data_inchidere`
- `timp_rezolvare_ore`

**FK:**
- `client_id` → Client (M:1)
- `departament_id` → Departament (M:1)
- `prioritate_id` → Prioritate (M:1)
- `status_id` → Status (M:1)
- `categorie_id` → Categorie (M:1, nullable)

**Relații:**
- 1:M → Comment_Client, Comment_Agent, Ticket_History, Atasament
- 1:1 → Feedback, Solutie
- M:N → Agent, Topic, Tag

---

## 📋 ENTITĂȚI DE SUPORT & LOGARE

### 4. **COMMENT_CLIENT**
**PK:** `comment_id`  
**FK:** `ticket_id` (Ticket), `client_id` (Client)  
**Atribute:** `content` (CLOB), `created_date`

### 5. **COMMENT_AGENT**
**PK:** `comment_id`  
**FK:** `ticket_id` (Ticket), `agent_id` (Agent)  
**Atribute:** `content` (CLOB), `created_date`, `is_internal` ('Y'/'N')

### 6. **TICKET_HISTORY** (Audit Trail)
**PK:** `history_id`  
**FK:** `ticket_id` (Ticket)  
**Atribute:** `event_type`, `created_date`, `created_by_role` ('CLIENT'/'AGENT'), `created_by_id`, `author_name`, `display_text`

---

## 📋 NOMENCLATOARE & CATEGORII

### 7. **DEPARTAMENT**
**FK:** `manager_id` → Agent (M:1)

### 8. **PRIORITATE** / **STATUS** / **TAG**
Tabele de configurare pentru fluxul de lucru.

### 9. **TOPIC** (Specializare IS-A)
- **TOPIC_SERVICIU**: `tip_serviciu`, `durata_estimata`, `tarif`
- **TOPIC_PRODUS**: `versiune`, `categorie`, `pret`, `stoc`

### 10. **CATEGORIE**
**Atribute:** `categorie_parinte_id` (Auto-referință pentru ierarhii)

---

## 📋 ENTITĂȚI SECUNDARE

### 11. **KB_ARTICLE** (Knowledge Base)
**FK:** `agent_id` (Autor), `categorie_id`  
**Relații:** 1:M → Atasament

### 12. **ATASAMENT**
**FK:** `ticket_id` (M:1, nullable), `kb_article_id` (M:1, nullable)  
**Constraint:** Exclusivitate între Ticket și KB_Article.

### 13. **FEEDBACK** / **SOLUTIE**
Relații 1:1 cu Ticket-ul pentru finalizarea procesului de suport.

---

## 🔗 REZUMAT RELAȚII CHEIE

### Relații 1:M (One-to-Many):
- **Client** → Ticket / Adresa / Comment_Client
- **Agent** → KB_Article / Comment_Agent / Solutie / Departament (Manager)
- **Ticket** → Comment_Client / Comment_Agent / Ticket_History / Atasament
- **Departament / Prioritate / Status** → Ticket
- **Categorie** → Ticket / KB_Article / Categorie (Hierarhie)

### Relații 1:1 (One-to-One):
- **Ticket** ↔ Feedback
- **Ticket** ↔ Solutie

### Relații M:N (Many-to-Many):
- **Ticket** ↔ **Agent** (prin Ticket_Agent) - *Roluri: PRIMARY, SECONDARY, OBSERVER*
- **Ticket** ↔ **Topic** (prin Ticket_Topic)
- **Ticket** ↔ **Tag** (prin Ticket_Tag)
- **Agent** ↔ **Departament** (prin Agent_Departament)

### Specializări (IS-A / Inheritance):
- **Client** → Client_Fizica / Client_Juridica
- **Topic** → Topic_Serviciu / Topic_Produs
# TickLy App

Next.js frontend + API that connects to the TickLy Oracle OLTP/DW database.

## Setup

1. **Copy env and set Oracle connection:**

   ```bash
   cp .env.local.example .env.local
   ```

   Edit `.env.local`:

   ```
   ORACLE_USER=TickLy
   ORACLE_PASSWORD=itdev123
   ORACLE_CONNECT_STRING=10.80.0.40:1515/orclpdb1
   ```

2. **Install and run:**

   ```bash
   npm install
   npm run dev
   ```

   Open [http://localhost:3000](http://localhost:3000).

## Features

- **Login** (`/login`) – Sign in as client or agent (email + password from OLTP).
- **Dashboard** (`/`) – Tickets list: clients see only their tickets, agents see all. Open a ticket for details, comments, attachments.

## Tech

- Next.js 14 (App Router), React 18, TypeScript, Tailwind CSS.
- Oracle DB via `oracledb` in API routes only (server-side).
- UI matches the mock style (primary `#207fdf`, Inter, Material Symbols icons).

## Build

```bash
npm run build
npm start
```

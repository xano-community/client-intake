# Client Intake

A lightweight client-intake app for financial advisors, built on Xano. Backend is XanoScript you push to your own Xano instance; frontend is a single-file HTML app that asks for your instance's base URL the first time it loads.

Captures the basics of each client relationship — contact info, risk tolerance, investment objective, advisor notes — and tracks follow-up tasks against each one. Email uniqueness is enforced at the DB and at the API layer.

## Repo layout

```
backend/            # XanoScript — push to your Xano workspace
  workspace/
  table/            # clients, client_tasks
  api/
    clients/        # Clients group: list, create, detail, update,
                    # task list, task create, task complete
frontend/
  index.html        # single-file static app
```

## Quick start

### 1. Push the backend to your Xano instance

```bash
npm install -g @xano/cli
xano profile:wizard

cd backend
xano workspace:push
```

This creates 2 tables (`clients`, `client_tasks`) and one API group (`Clients`, canonical `client-intake`) in your workspace.

### 2. Run the frontend

```bash
cd frontend
python3 -m http.server 8000
# open http://localhost:8000
```

On first load the page asks for your **Xano base URL** (e.g. `https://xxxx-xxxx-xxxx.n7d.xano.io`). Stored in `localStorage`; reconfigure any time from the header.

## What the frontend can do

- Browse clients with sortable columns and pagination
- Add a new client (validates required fields and email uniqueness)
- Drill into a client to see contact info, risk profile, objective, and advisor notes
- Edit any client field
- Add follow-up tasks per client with a due date and status
- Mark a task complete in one click

## API surface

No auth — this template is intentionally minimal. Add auth as needed.

```
GET    /api:client-intake/list                            ?page&per_page&sort_by&sort_order
POST   /api:client-intake/create                          { name, email, phone?, risk_tolerance, investment_objective, advisor_notes? }
GET    /api:client-intake/by-id/{id}
PATCH  /api:client-intake/by-id/{id}                      partial update
GET    /api:client-intake/by-id/{client_id}/tasks
POST   /api:client-intake/by-id/{client_id}/tasks         { title, due_date, status?, notes? }
PATCH  /api:client-intake/tasks/{task_id}/complete
```

## Schema

- **`clients`** — id, name, email (unique), phone, risk_tolerance (`low`/`medium`/`high`), investment_objective, advisor_notes, created_at, updated_at
- **`client_tasks`** — id, client_id → clients, title, due_date, status (`pending`/`in_progress`/`completed`), notes, created_at, updated_at

## License

MIT.

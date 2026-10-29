# CaseDesk

[![CI](https://github.com/MattSi/casedesk/actions/workflows/ci.yml/badge.svg)](https://github.com/MattSi/casedesk/actions/workflows/ci.yml)

A case management app for law firms, inspired by A Company's Today page.

Built with Rails 8, Hotwire, Tailwind CSS and MySQL.

## What's inside

- **Today page**: overdue tasks in Top priority, then the next 7 days of tasks and calendar events grouped by day
- **Mark complete without a page reload**: a Turbo Stream removes the card, and shows "Nothing overdue" when the last one is gone
- **Multi-tenant**: every record belongs to a firm, and lookups go through the signed-in user
  (`Current.user.assigned_tasks.find`), so one firm can never load another firm's data
- **Time zones**: each firm has its own time zone, and "today", "overdue" and day grouping use it
- **Tested**: Minitest for models, controllers and helpers, run on GitHub Actions with RuboCop and Brakeman

## Run locally

You need Ruby 3.4.12 and MySQL 8.

```bash
git clone https://github.com/MattSi/casedesk.git
cd casedesk
bin/setup
```

`bin/setup` installs gems, creates the database, loads the demo data and starts the server at
http://localhost:3000. Sign in as **demo@example.com** / **password**.

By default it connects to MySQL as your system user with no password.
Set `DB_USERNAME` and `DB_PASSWORD` to use a different account.

Other commands:

```bash
bin/rails db:seed   # reset the demo data, with dates relative to now
bin/rails test      # run the tests
bin/dev             # start the server again later
```

## Performance

Benchmarked with 1M tasks and 200K calendar events (`bin/rails perf:seed`, then `bin/rails perf:today`).
The busiest user has about 70K tasks, most of them completed. Median of 20 runs.

| Query | Before | After |
|---|---|---|
| Top priority (10 oldest overdue tasks) | 358 ms | 0.4 ms |
| Upcoming tasks (next 7 days) | 377 ms | 4.1 ms |
| Upcoming events (next 7 days) | 10.5 ms | 1.1 ms |

Before, MySQL used the single-column `assignee_id` index, read about 140K rows for the user,
filtered out 97% of them and sorted the rest (`Using filesort`).
A composite index on `(assignee_id, status, due_at)` lets it jump straight to the user's open
tasks, already sorted by due date, so it reads only the rows it returns and stops at `LIMIT 10`.
The old single-column indexes were removed because the new indexes cover them.
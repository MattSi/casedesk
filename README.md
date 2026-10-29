# CaseDesk

[![CI](https://github.com/MattSi/casedesk/actions/workflows/ci.yml/badge.svg)](https://github.com/MattSi/casedesk/actions/workflows/ci.yml)

A case management app for law firms, inspired by A Company's Today page.

Built with Rails 8, Hotwire, Tailwind CSS and MySQL.

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
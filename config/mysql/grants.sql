-- Runs once, when the MySQL data directory is first created.
-- Lets the app user create and use the four production databases (primary, cache, queue, cable).
GRANT ALL PRIVILEGES ON `casedesk\_production%`.* TO 'casedesk'@'%';
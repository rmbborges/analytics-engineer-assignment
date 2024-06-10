.DEFAULT_GOAL := run

task-00-create-event-raw:
	@echo "Creating event_raw table into the database"
	@sqlite3 db/assignment.db ".read sql/000-create-event-raw.sql"
	@echo "Finished the first task - created event_raw table"

task-01-import data:task-00-create-event-raw
	@echo "Before importing, creating a temporary single file for data from all files in the landing zone"
	@sqlite3 db/assignment.db ".read sql/010-import-data.sql"
	@echo "Finished the first task - created event_raw and imported both files data"

task-02-clean-data:task-01-import
	@echo "Importing all data into event_clean table"
	@sqlite3 db/assignment.db ".read sql/020-clean-data.sql"
	@echo "Finished the second task - generated event_clean table"

task-03-daily-sales:task-02-clean-data
	@echo "Generating the daily sales table"
	@sqlite3 db/assignment.db ".read sql/030-daily-sales.sql"
	@echo "Finished the third task - generated the daily sales table"

task-04-daily-stats:task-03-daily-sales
	@echo "Generating the daily stats table"
	@sqlite3 db/assignment.db ".read sql/040-daily-stats.sql"
	@echo "Finished the fourth task - generated the daily stats table"

task-05-daily-funnel:task-04-daily-stats
	@echo "Generating the daily funnel table"
	@sqlite3 db/assignment.db ".read sql/050-daily-funnel.sql"
	@echo "Finished the fifth task - generated the daily funnel talbe"

task-06-daily-ticket:task-05-daily-funnel
	@echo "Generating the daily ticket table"
	@sqlite3 db/assignment.db ".read sql/060-daily-ticket.sql"
	@echo "Finished the sixth task - generated the daily ticket table"

run: task-06-daily-ticket
	@echo "Finished all tasks"

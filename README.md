# DVD Rental Database Exploration

## Overview

This repository is dedicated to the exploration and utilization of the DVD rental sample database. It contains an Entity-Relationship Diagram (ERD) that outlines the structure of a DVD rental business and SQL scripts for querying the database.

## Contents

- `dvd-rental-sample-database-diagram.png` - An ERD of the DVD rental database, showcasing the relationships and structure of the database tables.
- `SQL_SELECT.sql` and `SQL_SELECT_1.sql` - A collection of SQL `SELECT` statements used to query the DVD rental database, perfect for practicing and learning SQL queries.
- `dvdrental` - The actual backup file of the DVD rental database which can be restored in a PostgreSQL environment.

## Database Diagram

The diagram provides a visual representation of the database schema, including tables such as `film`, `actor`, `inventory`, `rental`, `payment`, `customer`, and `staff`, along with their relationships. It is a valuable resource for understanding how the database is constructed and how the tables relate to one another.

## Using the Database and Scripts

To fully utilize this repository:

1. Restore the `dvdrental` database from the provided backup file to your PostgreSQL instance.
2. Refer to the `dvd-rental-sample-database-diagram.png` for an overview of the schema and table relationships.
3. Execute the queries in the `SQL_SELECT.sql` file to interact with the database, retrieve data, and practice SQL skills.

### Restoring the Database

To restore the database, you will need PostgreSQL installed on your system. Use the following command to restore the database:

```bash
pg_restore -U [username] -d dvdrental [path_to_backup_file]

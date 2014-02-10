I Owe YOU! (backend)
===============

I Owe YOU! is an app that is used to track the debts. Based on Node.js (Express Framework), and Postgres/Redis databases.

[![Build Status](https://travis-ci.org/piotrkowalczuk/ioweyou-backend.png?branch=develop)](https://travis-ci.org/piotrkowalczuk/ioweyou-backend)

Setup
------------
1. Install dependencies `npm install`.
2. Create `config.coffee` based on `config.coffee.dist`.
3. Create database in PostgreSQL based on what you wrote into config file.
3. Run task that create tables in database `grunt migration:syncdb`.

Dependencies
------------
- PostgreSQL
- Redis

# Testing Zen

Zen comes with a wide variety of tests to ensure that the various parts of Zen
work as expected. These tests can be configured to use different databases
and/or features. Regardless of the configuration you should first migrate the
database and set up a test user, this can be done by running the following
commands:

    $ cd spec
    $ rake db:migrate
    $ rake db:test_user

Once migrated you can run the tests as following:

    $ ruby zen/all.rb

## Requirements

* Ruby 1.9.2 or newer
* Firefox
* Selenium

Based on your configuration you may also need extra gems such as the sqlite3 gem
or the mysql2 gem.

## Environment Variables

* ADAPTER: the database adapter to use. For SQLite3 this should be set to
  "sqlite", for MySQL to "mysql2" and for PostgreSQL to "postgres".
* DATABASE: the name or file (in case of SQLite3) of the database.
* USERNAME: the username to use for connecting to a PostgreSQL or MySQL
  database.
* PASSWORD: the password to use for connecting to a PostgreSQL or MySQL
  database.
* LRU: when set to a non empty value the cache for sessions is set to
  Ramaze::Cache::LRU.
* COVERAGE: when set to a non empty value code coverage will be generated using
  SimpleCov.

## Examples

Testing MySQL:

    $ cd spec
    $ export ADAPTER=mysql2 DATABASE=zen_dev USERNAME=root
    $ rake db:migrate
    $ rake db:test_user
    $ ruby zen/all.rb

Testing PostgreSQL:

    $ cd spec
    $ export ADAPTER=postgres DATABASE=zen_dev USERNAME=postgres
    $ rake db:migrate
    $ rake db:test_user
    $ ruby zen/all.rb

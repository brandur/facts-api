Facts API
=========

Development
-----------

Migrate:

    sequel -m db/migrations postgres://localhost/facts-api-development
    heroku run 'sequel -m db/migrations $DATABASE_URL'

Run tests:

    bundle exec rake test

Run a particular test:

    bundle exec m test test/api/v0_categories_test.rb:55

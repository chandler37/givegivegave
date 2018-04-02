# givegivegave

The word "give" should make you think of a charity database.

This is Ruby on Rails (Ruby 2.5, Rails 5.1) on Heroku. See
https://devcenter.heroku.com/articles/getting-started-with-rails5
regarding running `bundle install`, `bundle exec rake db:create`, `bundle exec rake db:migrate`, `bundle exec rails server`, `git
push heroku my_topic_branch:master`, etc.

TODO: read the above again regarding setting up puma.

For seeing your heroku logs you might like to install the free papertrail add-on.

If you are on OS X you can use homebrew and rbenv to install ruby.

TODO: Integrate further with
https://www.charitynavigator.org/index.cfm?bay=content.view&cpid=1397 -- see
lib/charity_navigator.

TODO: Integrate the charitynavigator API with the Charity model -- it has some
fields for star ratings already; populate them at creation time

TODO: Integrate with Sendgrid for devise's emails

MAYBE: Integrate with Sentry (Raven) for stack traces

MAYBE: remove the new/edit Charity actions, requiring rails_admin to do that?

## Git workflow

Fork this repo, make your change on a topic branch (a.k.a. feature branch), and
submit a pull request against this repo to get a code review started.

```
git checkout -b do_something
edits...
git commit -a -m 'did something'
git push origin do_something
create a pull request on givegivegave repo against your new branch
```

## Authentication and Authorization

We use devise and cancancan.

## Superusers a.k.a. Admins

We use rails_admin to manage things, so you can use it to edit Users to give
the 'admin' attribute to a user. But you need your first superuser. For that,

Use `bundle exec rails c` locally or `heroku run bundle exec rails c`:

`User.find_by(email: blah).update_attributes!(admin: true)`

## Admin Interface

You can use the /admin URL to manage database objects and users if you are a
superuser.

## Debugging the Database

Using `psql`:

```
username=# \l
\l
      List of databases
       Name           |   Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
--------------------------+-----------+----------+-------------+-------------+-----------------------
 givegivegave_development | username | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 givegivegave_test        | username | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 

username=# \c givegivegave_development
\c givegivegave_development
psql (10.1, server 10.3)
You are now connected to database "givegivegave_development" as user "username".
givegivegave_development=# \dt
\dt
     List of relations
 Schema |         Name         | Type  |   Owner   
--------+----------------------+-------+-----------
 public | ar_internal_metadata | table | username
 public | charities            | table | username
 public | schema_migrations    | table | username
 public | users                | table | username
(4 rows)

givegivegave_development=# select * from users;
```

## Running tests

We use VCR to record all HTTP interactions so that you can run unittests
without an internet connection. TODO: delete the test::unit tests; we only use
rspec.

Changing some code? Delete all the relevant cassette YAML files (.yml) and run
the tests.

Run the rspec test suite with `bundle exec rspec`

You must run postgres; see
https://devcenter.heroku.com/articles/getting-started-with-rails5 regarding
installing it.

Before tests will work you must create the test database with the following:

`bundle exec rake db:create db:migrate`

TODO: make the tests pass. spec/lib/**/*.rb should already work.

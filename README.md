# givegivegave

The word "give" should make you think of a charity database.

This is Ruby on Rails (Ruby 2.5, Rails 5.1) on Heroku. See
https://devcenter.heroku.com/articles/getting-started-with-rails5
regarding running `bundle install`, `rake db:create`, `rake db:migrate`, `rails server`, `git
push heroku my_topic_branch:master`, etc.

If you are on OS X you can use homebrew and rbenv to install ruby.

TODO: Integrate further with
https://www.charitynavigator.org/index.cfm?bay=content.view&cpid=1397 -- see
lib/charity_navigator

TODO: write a view of a charity that uses a Charity model with details from the
charitynavigator API.

## Running tests

We use VCR to record all HTTP interactions so that you can run unittests
without an internet connection. TODO: delete the test::unit tests; we only use
rspec.

Changing some code? Delete all the relevant cassette YAML files (.yml) and run
the tests.

Run the rspec test suite with `bundle exec rspec`

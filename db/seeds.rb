# This file contains all the record creation needed to seed the database with its default values.
#
# The data can then be loaded with the `bundle exec rake db:seed` command.

ActiveRecord::Base.transaction do # helps when altering this file so you don't have to drop the development database after a mistake
  User.create!(
    email: "chandler37@chandler37.chandler37",
    password: "v"*71,
    admin: true
  )

  Charity.create!(
    name: "American Red Cross",
    ein: "53-0196605"
  )
end

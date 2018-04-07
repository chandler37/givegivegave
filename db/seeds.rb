# This file contains all the record creation needed to seed the database with its default values.
#
# The data can then be loaded with the `bundle exec rake db:seed` command.

# A transaction helps when altering this file so you don't have to drop the
# development database after a mistake:
ActiveRecord::Base.transaction do
  unless Rails.env.production?
    unless User.find_by(email: "admin@givegivegave.org")
      User.create!(
        email: "admin@givegivegave.org",
        password: "adminadmin",
        admin: true
      ).confirm
    end
  end

  Charity.some_golden_data_by_ein.each do |ein, hsh|
    result = DecorateCharityViaCharitynavigator.call!(ein: ein)
    unless result.charity.name =~ /\A[^?]/
      raise "oh noes! #{result.charity.attributes}"
    end
    if hsh[:correct_website].present?
      result.charity.update_attributes!(website: hsh[:correct_website])
    end
  end

  # Note that the above has created Cachelines as well. If you run rake db:seed
  # again it will use those, doing no HTTP calls.
end

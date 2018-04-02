class NonRailsAdminApplicationController < ::ApplicationController
  check_authorization :unless => :devise_controller?
end

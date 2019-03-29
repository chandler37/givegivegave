class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: {exception.param => "is required"}, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: {"error" => exception.message}, status: 404
  end

  before_action :authenticate_user!

  # I'm not clueful enough to exclude rails_admin as well as devise like so:g
  #   check_authorization :unless => :devise_controller?
  # Therefore please subclass NonRailsAdminApplicationController instead of this one.
end

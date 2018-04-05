class RegistrationsController < Devise::RegistrationsController

  private

  def after_inactive_sign_up_path_for(resource)
    # The flash message will be destroyed if we redirect to the root.
    new_user_session_path
  end
end

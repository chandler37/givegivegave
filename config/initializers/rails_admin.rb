module RailsAdmin
  module Extensions
    module CanCanCan2
      class AuthorizationAdapter < RailsAdmin::Extensions::CanCanCan::AuthorizationAdapter
        def authorize(action, abstract_model = nil, model_object = nil)
          return unless action
          reaction, subject = fetch_action_and_subject(action, abstract_model, model_object)
          @controller.current_ability.authorize!(reaction, subject)
        end

        def authorized?(action, abstract_model = nil, model_object = nil)
          return unless action
          reaction, subject = fetch_action_and_subject(action, abstract_model, model_object)
          @controller.current_ability.can?(reaction, subject)
        end

        def fetch_action_and_subject(action, abstract_model, model_object)
          reaction = action
          subject = model_object || abstract_model.try(:model)
          unless subject
            subject = reaction
            reaction = :read
          end
          return reaction, subject
        end
      end
    end
  end
end

RailsAdmin.add_extension(:cancancan2, RailsAdmin::Extensions::CanCanCan2, authorization: true)

RailsAdmin.config do |config|
  config.parent_controller = 'ApplicationController'

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  config.authorize_with :cancancan2

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end

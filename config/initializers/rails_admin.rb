require Rails.root.join('lib', 'RailsAdminModifications.rb')

  # Load the class in lib/RailsAdminModifications.rb
  module RailsAdmin
    module Config
      module Actions
        class ClearUserThings < RailsAdmin::Config::Actions::Base
          RailsAdmin::Config::Actions.register(self)
        end
      end
    end
  end

RailsAdmin.config do |config|
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ClearUserThings)
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::BlastMail)
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ClearUserThingsAll)
  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::BlastMailAll)

  config.authenticate_with do
    redirect_to(main_app.root_path, flash: {warning: 'You must be signed-in as an administrator to access that page'}) unless signed_in? && current_user.admin?
  end

  config.actions do
    # root actions
    dashboard                     # mandatory
    # collection actions 
    index                         # mandatory
    new
    export
    history_index
    bulk_delete
    # member actions
    show
    edit
    delete
    history_show
    show_in_app
    clear_user_things do	#Custom "thingy" for resetting. The 'only' section designates where specifically this button can appear.
		only ['User']
	end
	clear_user_things_all do
		only ['User']
	end
	blast_mail do	#Custom "thingy" for sending large e-mail chains.
		only ['User']
	end
	blast_mail_all do
		only ['User']
	end 
  end  
end

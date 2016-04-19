module RailsAdmin
  module Config
    module Actions
      class ClearUserThings < RailsAdmin::Config::Actions::Base
      	# There are several options that you can set here. Check https://github.com/sferik/rails_admin/blob/master/lib/rails_admin/config/actions/base.rb for more info.
		# This one designates this button to be functional for large data structures as opposed to a single target.
		register_instance_option :collection do
		  true
		end
		# Goes with the above to insure everything works.
		register_instance_option :bulkable? do
          true
        end
		# I have a general understanding as to what this does; though I really don't know the ins and outs.
		register_instance_option :http_methods do
		  [:post, :delete]
		end
		# Determines where the button is visible. In this case I just check if it is authorized. This can be set in the rails_admin.rb section.
		register_instance_option :visible? do
			authorized?
		end
		# What icon this has on the list. Apparently there are quite a few choices, though I wouldn't know.
		register_instance_option :link_icon do
          'icon-refresh' 
        end
		register_instance_option :authorization_key do
          :destroy
        end
		
		# This is where the actual program goes. Or at least how this particular button works.
		register_instance_option :controller do
		  proc do
			if request.post?
		      # Get all selected rows. I think this is required to get this program to work.
			  @objects = list_entries(@model_config, :destroy)
			  render @action.template_name
		    elsif request.delete?	# I dunno why this is called delete. For some reason it only worked when I named it delete. I guess there is some deleting going on so; it's alright I guess.
			  @objects = list_entries(@model_config, :destroy)	# I noticed this used twice in the base files I looked at to design this. It seems like this isn't an oversight though.
		      @objects.each do |user|
			    unless @objects.blank? || user.id == 1  # This specific ID is registered exclusively to the primary admin account. They own things 1 and 2; which are hidden/unclearable.
			      if user.things.first != nil
				    user.things.each do |thing|
		  		      thing.update_attribute(:user_id, nil)
		  		      thing.update_attribute(:name, nil)
					end
		  	      elsif user.admin == false
				    ThingMailer.reregister(user).deliver
				    user.destroy
		  		  end
		  	    end
		  	  end
			  flash[:success] = t('admin.actions.clear_user_things.done')
			  reminder = Reminder.create(from_user_id: 1, thing_id: 2, to_user_id: 2)	# This requires you to have user 1 and user 2 reserved as "administrator" and "everyone" respectively.
			  reminder.save
			  reminder.update_attribute(:sent, true)
		      redirect_to back_or_index
			end
		  end
		end
      end
	  
	  class BlastMail < RailsAdmin::Config::Actions::Base

		register_instance_option :collection do
		  true
		end
		
		register_instance_option :bulkable? do
          true
        end

		register_instance_option :http_methods do
		  [:post, :delete]
		end

		register_instance_option :visible? do
			authorized?
		end
		
		register_instance_option :link_icon do
          'icon-envelope' 
        end
		
		register_instance_option :controller do
		  proc do
		    if request.post?
		  	  # Get all selected rows
		  	  @objects = list_entries(@model_config, :destroy)
			  render @action.template_name
			elsif request.delete?	# Once again, called delete for some reason. This time it really doens't make sense; but I can't make up my own details for some reason.
		  	# Establish a loop of sorts
        	  @objects = list_entries(@model_config, :destroy)
        	  @objects.each do |user| 
        	    unless @objects.blank? || user.id == 1
        		  # Send Reminders Here
        		  if user.things.first != nil 
				    ThingMailer.reminder(user.things.first).deliver
				  #else
        		  #  render(json: {errors: reminder.errors}, status: 500)
				  end
			    end
        	  end
			  reminder = Reminder.create(from_user_id: 1, thing_id: 1, to_user_id: 2)	# This requires you to have user 1 and user 2 reserved as "administrator" and "everyone" respectively.
			  reminder.save
			  reminder.update_attribute(:sent, true)
		      flash[:success] = t('admin.actions.blast_mail.done')
		      redirect_to back_or_index
			end
		  end
		end
      end
	  
	  # This is a good example of why rails is irritating. Apparently making seperate functionalities for the ALL and the SELECTED FEW tabs is not a thing I can figure out how to do without making more classes. Lucky for us Ruby has decent implentation capabilities. (As far as classes go)
	  class ClearUserThingsAll < RailsAdmin::Config::Actions::ClearUserThings
	    register_instance_option :http_methods do
		  [:post, :delete, :get]
		end
		
	    register_instance_option :bulkable? do
          false
        end
	  end
	  class BlastMailAll < RailsAdmin::Config::Actions::BlastMail
	    register_instance_option :http_methods do
		  [:post, :delete, :get]
		end
		register_instance_option :bulkable? do
          false
        end
	  end
    end
  end
end

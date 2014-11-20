class ProfilesController < ApplicationController
  before_action :require_admin_or_owner, only: [:show]
  before_action :require_owner, only: [:edit, :update]
#validate is user editing


  #show the profile to the user
  def show
    @profile=User.find(params[:id]).profile
  end
  #create a default profile

  def edit
    @profile=User.find(params[:id]).profile
  end

  def update
    @profile = Profile.find(params[:id])
    @profile.update_attributes(profile_params)
    redirect_to profile_path(@profile), flash: { success: "Profile was updated" }
  end

  def destroy
  end


  def profile_params
    params[:profile].permit(:food_pref, :location, :notification_settings, :other_food)
  end

  def require_admin_or_owner
    # need better way to find event
    if !params[:id]==current_user.id && !current_user.admin
       redirect_to :calendar, flash: { error: 'You do not have permission to view this profile' }
    end
  end

  def require_owner
    if !params[:id]==current_user.id
       redirect_to :calendar, flash: { error: 'You do not have permission to edit this profile' }
    end
  end

end

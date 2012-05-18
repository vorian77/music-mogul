class UsersController < ApplicationController
  
  before_filter :authenticate_user!
  
  def edit
  end
  
  def update
    ['landscape','square'].each do |type|
      params[:user]["remove_profile_photo_#{type}".to_sym] = nil if params[:user] && params[:user]["profile_photo_#{type}".to_sym]
    end
    respond_with current_user do |format|
      if current_user.update_attributes(params[:user])
        notice = current_user.pending_reconfirmation? ? 'Your new email address is pending confirmation' : 'Your account has been successfully saved'
        format.html { redirect_to account_path, :notice => notice }
        format.json { render :json => { :notice => notice } }
      else
        format.html { render :action => 'edit', :alert => 'Sorry, there was an error in the form' }
        format.json { render :json => { :errors => current_user.errors }, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_profile_video
    raise unless params[:s3_key]
    current_user.update_attribute(:profile_video,params[:s3_key])
    render :nothing => true
  end
  
  def create_entry_performance_video
    raise unless params[:s3_key]
    current_user.entry.update_attribute(:performance_video,params[:s3_key])
    render :nothing => true
  end

  def edit_thumbnail
    render 'edit_thumbnail', :layout => 'basic'
  end

  def update_thumbnail
    current_user.tap do |u|
      u.thumb_x = params[:user][:thumb_x]
      u.thumb_y = params[:user][:thumb_y]
      u.thumb_w = params[:user][:thumb_w]
      u.save(:validate => false)
    end
    current_user.profile_photo_square.recreate_versions!
    render :nothing => true
  end

  def upload
  end

end

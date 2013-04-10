class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :verify_email]
  before_filter :ensure_contest_running!, only: [:leaderboard]
  load_and_authorize_resource except: [:new, :verify_email]

  def edit
    render current_user.fan? ? "mogul" : "musician"
  end

  def update
    respond_to do |format|
      format.html do
        if params[:user][:password].blank?
          params[:user].delete("password")
          params[:user].delete("password_confirmation")
        end
        if @user.update_attributes(params[:user])
          sign_in(@user, :bypass => true)
          redirect_to edit_user_path(current_user)
        else
          render current_user.fan? ? "mogul" : "musician"
        end
      end

      format.js do
        @user.assign_attributes(params[:user])
        if @user.save(validate: false)
          render json: @user.as_json(include: :entries)
        else
          render json: @user.errors
        end
      end
    end
  end

  def leaderboard
    redirect_to root_path unless Contest.active.try(:show_leaderboard_nav?)
    musician_ids = Entry.with_contest.finished.pluck(:user_id)
    respond_to do |format|
      format.html do
        @musicians = User.non_admin.where("id in (?)", musician_ids).order("cached_points desc, id").page(params[:musician_page]).per(10)
        @fans = User.non_admin.fan.order("cached_points desc, id").page(params[:fan_page]).per(10)
      end
      format.js do
        if params[:musician_page].present?
          @musicians = User.non_admin.where("id in (?)", musician_ids).order("cached_points desc, id").page(params[:musician_page]).per(10)
          render json: {musicians: render_to_string(partial: "users/leaderboard/musicians", locals: {musicians: @musicians})}
        elsif params[:fan_page].present?
          @fans = User.non_admin.fan.order("cached_points desc, id").page(params[:fan_page]).per(10)
          render json: {fans: render_to_string(partial: "users/leaderboard/fans", locals: {fans: @fans})}
        end
      end
    end
  end

  def my_data
    @user = current_user
    @entry = @user.entries.first
  end

  def fan_email_list
    @user = current_user
    @entry = @user.entries.first
    csv = CSV.generate({}) do |csv|
      csv << %w(username email)
      @entry.shared_email_users.each do |user|
        csv << [user.username, user.email]
      end
    end
    send_data csv, filename: "Music Mogul Fan List for #{@entry.stage_name} - #{Date.today.strftime("%y%m%d")}.csv"
  end

  def scorecard
    render json: {scorecard: render_to_string(partial: "users/score")}
  end
end

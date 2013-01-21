class EntriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def finish
    @entry = current_user.entries.first
    if request.request_method == "PUT"
      respond_to do |format|
        format.html do
          if @entry.update_attributes(params[:entry])
            if @entry.finished?
              redirect_to root_path
            else
              render "entries/finish"
            end
          end
        end
        format.js do
          @entry.assign_attributes(params[:entry])
          if @entry.save(validate: false)
            render json: @entry
          else
            render json: @entry.errors
          end
        end
      end
    end
  end

  def show
    @evaluation = current_user.evaluations.where(entry_id: @entry.id).first || @entry.evaluations.new
  end

  def update
    if @entry.update_attributes(params[:entry])
      redirect_to edit_entry_path(@entry)
    else
      render "entries/edit"
    end
  end

  def leaderboard
    @entries = Entry.where("points > 0").order("points desc")
  end
end
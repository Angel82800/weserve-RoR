class NotificationsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  PER_LOAD_COUNT = 10

  def index
    @notifications = current_user.notifications.includes(:source_model).order(created_at: :desc).limit(PER_LOAD_COUNT)
    @notifications.update_all(read: true)
  end

  def load_older
    @last_page = false
    @notifications = current_user.notifications.order(id: :desc).includes(:source_model).where("id < ?", params[:first_notification_id]).limit(PER_LOAD_COUNT)
    @notifications.update_all(read: true)
    @last_page = true if @notifications.empty? || @notifications.first == current_user.notifications.first
  end

  def mark_all_as_read
    if current_user.notifications.update_all(read: true)
      flash[:notice] = "All notifications have been marked as read."
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    respond_to do |format|
      if @notification.destroy
        format.json { render json: @notification.id, status: :ok }
      else
        format.json { render status: :internal_server_error }
      end
    end
  end
end

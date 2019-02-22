class Admin::NotificationsController < Admin::ApplicationController
  def index
    @visitor_notifications = Notification.where(notifiable_type: 'Visitor').order(id: :desc)
    @comment_notifications = Notification.where(notifiable_type: 'Comment').order(id: :desc)
  end

  def destroy
    @notifiable = Notification.find(params[:id])
    @notifiable.destroy
    flash[:notice] = 'Notification was deleted successfully'
    redirect_back(fallback_location: root_path)
  end

  def delete_all
    Notification.delete_all
    flash[:notice] = 'All notifications deleted successfully'
    redirect_back(fallback_location: root_path) 
  end
end

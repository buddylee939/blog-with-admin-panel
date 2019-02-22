class Admin::MessagesController < Admin::ApplicationController
  def index
    if params[:search].present?
      @messages = Message.matching_fullname_or_content(params[:search]).page params[:page]
    else
      @messages = Message.all.order(id: :desc).page params[:page]
    end
  end

  def show
    @message = Message.find(params[:id])
    @message.mark_read
  end

  def update
    @message = Message.find(params[:id])
    @message.update(status: params[:status])
    flash[:notice] = 'Successfully updated message'
    redirect_back(fallback_location: root_path)
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    flash[:notice] = 'Message was successfully deleted'
    redirect_back(fallback_location: root_path)
  end
end

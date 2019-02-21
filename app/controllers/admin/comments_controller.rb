class Admin::CommentsController < Admin::ApplicationController
  def index
    if params[:search].present?
      @comments = Comment.matching_fullname_or_message(params[:search]).page params[:page]
    else
      # @comments = Comment.where(status: to_bool(params[:status])).page params[:page]
      # @comments = Comment.all.page params[:page]
      @comments = Comment.where(status: to_bool(params[:status])).page params[:page]
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(status: params[:status])
      flash[:notice] = 'Successfully updated comment'
      redirect_back(fallback_location: root_path)      
    else
      flash[:alert] = 'There was a problem updating comment'
      redirect_back(fallback_location: root_path)         
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:notice] = 'Comment deleted successfully'
    redirect_back(fallback_location: root_path)
  end
end

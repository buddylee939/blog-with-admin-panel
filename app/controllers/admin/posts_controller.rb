class Admin::PostsController < Admin::ApplicationController
  before_action :find_post, only: [:show, :edit, :update, :destroy]

  def index
    if params[:search].present?
      @posts = Post.matching_title_or_content(params[:search]).page params[:page]
      # @posts = Post.where("title LIKE ? OR content LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%").page params[:page]
    else
      @posts = Post.all.order(id: :desc).page params[:page]
    end
  end

  def show    
  end  

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.moderator_id = current_moderator.id
    if @post.save
      redirect_to admin_posts_url, notice: 'Post was successfully created'
    else
      flash[:alert] = 'There was a problem creating post'
      render :new
    end
  end

  def edit
    
  end

  def update    
    if @post.update(post_params)
      redirect_to admin_posts_url, notice: 'Post was successfully updated'
    else
      flash[:alert] = 'There was a problem updating post'
      render :edit
    end
  end

  def destroy    
    @post.destroy
    flash[:notice] = 'Post was successfully deleted'
    redirect_back(fallback_location: root_path)
  end

  private

  def find_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:id, :title, :content, :publish, tag_ids: [])
  end
end

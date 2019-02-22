# Steps

- rails new blog-with-admin 
- showed how to set up the symlink for subl .
- used mysql workbench to diagram out the tables and their relations: in lesson 3
- in gemfile uncomment bcrypt
- bundle
- rails g model Moderator fullname username password_digest
- update models/moderator.rb file

```
has_secure_password
```

- rails db:migrate
- seeding the moderators

```
moderator = Moderator.create(
  fullname: 'Pep Merc',
  username: 'pep@example.com',
  password: 'asdfasdf')
```

- rails db:seed
- rails g model Setting site_name post_per_page:integer under_maintenance:boolean prevent_commenting:boolean tag_visibility:boolean
- rails db:migrate
- rails g model Post title content:text publish:boolean moderator:references
- rails db:migrate
- rails g model Comment message:text status:boolean post:references visitor:references
- rails db:migrate
- rails g model Visitor fullname email
- rails g model Message content:text visitor:references
- rails g model Tag name
- rails db:migrate
- rails g model PostTag post:references tag:references
- rails g model Notification notifiable:references{polymorphic}:index
- rails db:migrate

## creating the associations

- update moderator.rb

```
has_many :posts
```

- update post.rb

```
  has_many :comments
  has_many :post_tags
  has_many :tags, through: :post_tags
  belongs_to :moderator

```

- update tag.rb

```
  has_many :post_tags
  has_many :posts, through: :post_tags
```

- update comment.rb

```
  belongs_to :post
  belongs_to :visitor
  has_many :notifications, as: :notifiable
```

- update visitor.rb

```
has_many :notifications, as: :notifiable
has_many :comments
has_many :messages
```

## Lesson 8, 9, 10, 15, 16 - Ruby Lessons

- these 2 blocks are the same

```
student do |s|
	s.introduce name: :dave
	s.study
end

student {|s| s.introduce}
```

## Creating the routes

- update routes

```
  namespace :admin do
    resources :moderators, only: [:index, :edit, :update]
  end
```

- if you dont want it to be admin/moderators on the address bar then do this instead

```
resources :moderators, module: 'admin'
```

- create the folder controllers/admin
- create a file there moderators_controller.rb

```
class Admin::ModeratorsController < ApplicationController
  before_action :find_moderator, only: [:edit, :update]
  def index
    @moderators = Moderator.all
  end

  def edit
  end

  def update    
    if @moderator.update(moderator_params)
      flash[:notice] = "Moderator was successfully updated"
      redirect_to admin_moderators_url
    else
      flash[:alert] = "There was a problem updating moderator"
      render 'edit'
    end
  end

  private

  def find_moderator
    @moderator = Moderator.find(params[:id])
  end

  def moderator_params
    params.require(:moderator).permit(:id, :fullname, :username, :password)
  end
end
```

- create the folder views/admin
- create the folder views/admin/moderators
- create the file index.html.erb

```
<h1>Moderator's Index</h1>

<table class="table table-bordered table-hover">
	<thead>
		<tr>
			<th>fullname</th>
			<th>username</th>
			<th>created</th>
			<th>actions</th>
		</tr>
	</thead>
	<tbody>
		<% @moderators.each do |moderator| %>
			<tr>
				<td><%= moderator.fullname %></td>
				<td><%= moderator.username %></td>
				<td><%= time_ago_in_words(moderator.created_at) %></td>
				<td>
					<%= link_to 'Edit', edit_admin_moderator_path(moderator) %>
				</td>
			</tr>
		<% end %>
	</tbody>
</table>
```

- create moderators/edit

```
<h1>Edit Moderator</h1>

<p><%#= render 'validation_errors', object: @moderator %></p>

<%= form_for [:admin, @moderator] do |f| %>
	<p>
		<%= f.label :fullname %>
		<%= f.text_field :fullname %>
	</p>

	<p>
		<%= f.label :username %>
		<%= f.text_field :username %>
	</p>

	<p>
		<%= f.label :password %>
		<%= f.password_field :password %>
	</p>

	<p>
		<%= f.submit %>
	</p>
<% end %>
```

- **adding validation**
- update moderator.rb

```
class Moderator < ApplicationRecord
  has_secure_password

  has_many :posts

  validates :fullname, presence: true
  validates :username, presence: true, format: {with: /@/, message: 'is not valid'}
  validates :password, presence: true
end

```

## Sessions - lesson 17

- rails g controller admin/sessions new create destroy
- update routes

```
  get '/login' => 'admin/sessions#new'
  get '/logout' => 'admin/sessions#destroy'
  
  namespace :admin do
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
```

- delete the create and destroy files in views
- update the sessions/new


```
<h1>Login</h1>
<%= form_tag admin_sessions_path do %>
	<p>
		<%= label_tag :username %><br>
		<%= text_field_tag :username %>
	</p>
	<p>
		<%= label_tag :password %><br>
		<%= password_field_tag :password %>
	</p>
	<p><%= submit_tag 'Log in' %></p>
<% end %>

```

- update the sessions controller

```
class Admin::SessionsController < ApplicationController
  before_action :authorize, except: [:new, :create]
  
  def new
  end

  def create
    @moderator = Moderator.find_by(username: params[:username]).try(:authenticate, params[:password])
    if @moderator
      session[:current_moderator_id] = @moderator.id
      redirect_to admin_moderators_url, notice: 'You have successfully signed in'
    else
      flash[:alert] = 'There was a problem with your username or password'
      render :new
    end
  end

  def destroy
    session[:current_moderator_id] = nil
    redirect_to '/login', notice: 'You have successfully logged out'
  end
end

```

- create admin/application_controller.rb


```
class Admin::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'admin'
  
  before_action :authorize
  
  def current_moderator
    @moderator ||= Moderator.find(session[:current_moderator_id]) if session[:current_moderator_id]
  end

  def authorize
    unless current_moderator
      redirect_to '/login', alert: 'Please login to view admin pages'
    end
  end

  def to_bool string
    ActiveRecord::Type::Boolean.new.type_cast_from_user(string)
  end
end
```

- update moderators controller and sessions controller

```
class Admin::ModeratorsController < Admin::ApplicationController
class Admin::SessionsController < Admin::ApplicationController
```

- create layouts/admin.html.erb

```
<!DOCTYPE html>
<html>
<head>
  <title>RAILSBlog</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<% if flash[:notice] %>
	<div class="notice"><%= flash[:notice] %></div>
<% end %>

<% if flash[:alert] %>
	<div class="alert"><%= flash[:alert] %></div>
<% end %>

<%= link_to 'Log out', logout_path %>

<p>
	<%#= link_to 'Posts', admin_posts_path %>
	<%#= link_to 'Moderators', admin_moderators_path %>
	<%#= link_to 'Tags', new_admin_tag_path %>
	<%#= link_to 'Comments', admin_comments_path %>
	<%#= link_to 'Visitors', admin_visitors_path %>
	<%#= link_to 'Messages', admin_messages_path %>
	<%#= link_to 'Notifications', admin_notifications_path %>
	<%#= link_to 'Dashboard', admin_dashboard_index_path %>
	<%#= link_to 'Setting', new_admin_setting_path %>
</p>

<%= yield %>

</body>
</html>

```

- using byebug, put byebug in sessions controller, try to log in, in the server logs

```
@moderator.inspect
session[:current_moderator_id]
type c to continue
```

- add the logout link

```
<%= link_to 'Log out', logout_path %>
```

## Creating the posts section

- rails g controller admin/posts index new create edit update show destroy
- update routes

```
resources :posts
```

- delete update, create, destroy files
- install faker gem
- add the seed file


```
moderator = Moderator.create(
  fullname: "Kingsley Ijomah",
  username: "kingsley@example.com",
  password: "example")

30.times do
  post = Post.create(
    title: Faker::Lorem.sentence(20),
    content: Faker::Lorem.paragraph,
    publish: true,
    moderator: moderator)

  tag = Tag.create(name: Faker::Lorem.word)

  post_tag = PostTag.create(post: post, tag: tag)

  # visitor = Visitor.create(
  #   fullname: Faker::Name.name, 
  #   email: Faker::Internet.email)

  # comment = Comment.create(
  #   message: Faker::Lorem.paragraph,
  #   status: [true, false].sample,
  #   post: post,
  #   visitor: visitor)

  # message = Message.create(
  #   content: Faker::Lorem.paragraph,
  #   status: [true, false].sample,
  #   visitor: visitor)

  # notifiable = [visitor, comment].sample

  # notification = Notification.create(
  #   notifiable_id: notifiable.id,
  #   notifiable_type: notifiable.class.name)
end
```

- update posts/index

```
<h1>Admin::Posts#index</h1>

<p><%= link_to 'New Post', new_admin_post_path %></p>

<p>
	<%= render 'search', route: admin_posts_path %>
</p>

<table class="table table-bordered table-hover">
	<thead>
		<tr>
			<th>title</th>
			<th>publish</th>
			<th>actions</th>
		</tr>
	</thead>
	<tbody>

		<% @posts.each do |post| %>
			<tr>
				<td><%= truncate(post.title, length: 60, separate: '') %></td>
				<td><%= status_converter(post.publish, truthy: 'Active', falsey: 'Pending') %></td>
				<td>
					<%= link_to 'Edit', edit_admin_post_path(post) %> |
					<%= link_to 'Show', admin_post_path(post) %> |
					<%= link_to 'Delete', admin_post_path(post), method: :delete, data: {confirm: 'Are you sure?'} %>
				</td>
			</tr>
		<% end %>

	</tbody>
</table>
<p><%= paginate @posts %></p>
```

- add to helpers/application helper

```
	def status_converter(status, truthy: 'Active', falsey: 'Pending')
		if status
			truthy
		else
			falsey
		end
	end
```

- replace post.publish in views/admin/posts/index with

```
<td><%= status_converter(post.publish, truthy: 'Active', falsey: 'Pending') %></td>
```

### adding pagination

- add kaminari gem
- bundle
- update posts controller index action

```
  def index
    if params[:search].present?
      @posts = Post.matching_title_or_content(params[:search]).page params[:page]
    else
      @posts = Post.all.order(id: :desc).page params[:page]
    end
  end
```

- update posts/index

```
<p><%= paginate @posts %></p>
```

- restart server 

### adding search

- add to the posts index

```
<p>
	<%= form_tag(admin_posts_path, method: :get) do %>
		<%= text_field_tag :search %>
		<%= submit_tag 'Search' %>
	<% end %>	
</p>
```

- update posts controller index

```
  def index
    if params[:search].present?
      # @posts = Post.matching_title_or_content(params[:search]).page params[:page]
      @posts = Post.where("title LIKE ? OR content LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%").page params[:page]
    else
      @posts = Post.all.order(id: :desc).page params[:page]
    end
  end
```

- **refactoring the search**
- add to post.rb

```
  def self.matching_title_or_content search
  	where("title LIKE ? OR content LIKE ?", "%#{search}%", "%#{search}%")
  end
```

- in posts controller, use this line instead in the index

```
@posts = Post.matching_title_or_content(params[:search]).page params[:page]
```

- **creating a helper for time ago in words**
- in application helper

```
  def time_ago time
    "#{time_ago_in_words(time)} ago"
  end
```

- and in posts/show replace with

```
<p><b>created:</b> <%= time_ago(@post.created_at) %></p>
```

- **new posts**
- create the posts/form partial, the :admin is for the namespace

```
<p><%#= render 'validation_errors', object: @post %></p>

<%= form_for [:admin, @post] do |f| %>
	<p>
		<%= f.label :title %><br>
		<%= f.text_field :title %>
	</p>

	<p>
		<%= f.label :content %><br>
		<%= f.text_field :content %>
	</p>

	<p>
		<%= f.label :publish %><br>
		<%= f.check_box :publish %>
	</p>

	<p>
		<%= f.select :tag_ids, Tag.all.collect {|t| [t.name, t.id]}, {prompt: 'Select Tag'}, multiple: :true %>
	</p>

	<p><%= f.submit %></p>
<% end %>
```  

- posts controller

```
  def new
    @post = Post.new
  end
```

- update posts/create action

```
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
```

- **validating posts**
- update post.rb

```
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  belongs_to :moderator

  validates :title, presence: true
  validates :content, presence: true

  def self.matching_title_or_content search
    where("title LIKE ? OR content LIKE ?", "%#{search}%", "%#{search}%")
  end
```

- **creating the flash messages partial**
- create the admin/application folder    
- create the validation_errors partial, and object is a variable we assign when calling it from the page

```
<% if object.errors.any? %>
  <div id="validation_errors">
    <h2><%= pluralize(object.errors.count, "error") %> prohibited a successful save:</h2>
 
    <ul>
    <% object.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

- in the posts/form partial

```
<p><%= render 'validation_errors', object: @post %></p>
```

- update admin/moderators/edit

```
<p><%= render 'validation_errors', object: @moderator %></p>
```

- **updating posts**
- add before action find_post and update update action

```
  def update    
    if @post.update(post_params)
      redirect_to admin_posts_url, notice: 'Post was successfully updated'
    else
      flash[:alert] = 'There was a problem updating post'
      render :edit
    end
  end
```

- **deleting posts**
- update destroy action in posts controller

```
  def destroy    
    @post.destroy
    flash[:notice] = 'Post was successfully deleted'
    redirect_back(fallback_location: root_path)
  end
```

- make sure in post.rb the dependents are deleted as well

```
  has_many :comments, dependent: :destroy
  has_many :post_tags, dependent: :destroy
```

- and in comment.rb

```
  belongs_to :post
  belongs_to :visitor
  has_many :notifications, as: :notifiable, dependent: :destroy
```

- the post will delete the comments associated, and the comments will delete the notifications associated

## Creating tags

- rails g controller admin/tags new create edit update show destroy
- update routes

```
  namespace :admin do
    resources :posts
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
```

- in views/admin/tags delete create update destroy files
- update views/admin/tags/new

```
<h1>Admin::Tags#new</h1>

<%= form_for [:admin, @tag] do |f| %>
	<p><%= f.text_area :name, placeholder: 'e.g Ruby, Python, Php' %></p>
	<p><%= f.submit %></p>
<% end %>

<table class="table table-bordered table-hover">
	<thead>
		<tr>
			<th>name</th>
			<th>status</th>
			<th>created</th>
			<th>actions</th>
		</tr>
	</thead>
	<tbody>
		<% @tags.each do |tag| %>
			<tr>
				<td><%= tag.name %></td>
				<td><%= status_converter(tag.in_use?, truthy: 'in use', falsey: 'not in use') %></td>
				<td><%= time_ago tag.created_at %></td>
				<td>
					<%= link_to edit_admin_tag_path(tag) do %>
						<button type="button">Edit</button>
					<% end %>

					<%= create_deletable_button tag %>
				</td>
			</tr>
		<% end %>

	</tbody>
</table>
```

- update tags controller

```
class Admin::TagsController < Admin::ApplicationController
  def new
    @tag = Tag.new
    @tags = Tag.all.order(id: :desc)
  end

  def create
    tags_params[:name].split(',').map do |n|
      Tag.new(name: n).save
    end
    redirect_to new_admin_tag_url, notice: 'Tag was successfully created'
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    if @tag.update tags_params
      redirect_to new_admin_tag_url, notice: 'Successfully updated tag'
    else
      flash[:alert] = 'There was a problem updating tag'
      render :edit
    end
  end

  def show
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    redirect_to :back, notice: 'Successfully deleted tag'
  end

  private

  def tags_params
    params.require(:tag).permit(:id, :name)
  end
end
```

- in tag.rb add the in_use? method

```
  has_many :post_tags
  has_many :posts, through: :post_tags

  validates :name, presence: true
  def in_use?
    PostTag.exists?(tag_id: self.id)
  end  
```

- in tags/new add

```
<td><%= status_converter(tag.in_use?, truthy: 'in use', falsey: 'not in use') %></td>
```  

- creating a link to block with a button

```
<%= link_to edit_admin_tag_path(tag) do %>
	<button type="button">Edit</button>
<% end %>
```					

- update the tags/edit file

```
<h1>Admin::Tags#edit</h1>

<%= form_for [:admin, @tag] do |f| %>
	<p><%= f.label :name %></p>
	<p><%= f.text_field :name %></p>
	<p><%= f.submit %></p>
<% end %>

```

- **making the delete button in-active while the tag is in use**
- in the tag/new add

```
<%= create_deletable_button tag %>
```

- in tags_helper create the method

```
	def create_deletable_button tag 
		if tag.in_use?
			link_to '#' do
			# this is cuz we can't use html in the ruby file
				content_tag(:button, 'Delete', class: 'disabled')
			end
		else
			link_to admin_tag_path(tag), method: :delete, data: { confirm: 'Are you sure?' } do
				content_tag(:button, 'Delete')
			end
		end
	end
```

- update the tags destroy action in the controller

```
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    redirect_to new_admin_tag_url, notice: 'Successfully deleted tag'
  end
```

## Creating comments

- update seed file to add visitors and comments

```
  visitor = Visitor.create(
    fullname: Faker::Name.name, 
    email: Faker::Internet.email)

  comment = Comment.create(
    message: Faker::Lorem.paragraph,
    status: [true, false].sample,
    post: post,
    visitor: visitor)
```

- rails db:reset
- rails g controller admin/comments index update destroy
- update routes

```
  namespace :admin do
    resources :posts
    resources :comments, only: [:index, :update, :destroy]
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
```

- delete comments update and destroy files
- update comments controllers

```
class Admin::CommentsController < Admin::ApplicationController
  def index
  	if params[:search].present?
  		@comments = Comment.matching_fullname_or_message(params[:search]).page params[:page]
  	else
  		@comments = Comment.where(status: to_bool(params[:status])).page params[:page]
  	end
  end

  def update
  	@comment = Comment.find(params[:id])
  	if @comment.update(status: params[:status])
  		redirect_to :back, notice: 'Successfully updated comment'
  	else
  		redirect_to :back, notice: 'There was a problem updating comment'
  	end
  end

  def destroy
  	@comment = Comment.find(params[:id])
  	@comment.destroy

  	redirect_to :back, notice: 'Successfully deleted comment'
  end
end

```

- update comments controller

```
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
```

- update comments/index

```
<h1>Comments</h1>

<p>
	<%#= render 'search', route: admin_comments_path %>
</p>

<p>
	<%= link_to 'Approved', admin_comments_path(status: true) %>
	<%= link_to 'Un-approved', admin_comments_path(status: false) %>
</p>

<% @comments.each do |comment| %>
	<p><b><%= comment.visitor.fullname %></b> posted message on <b><%= comment.post.title %></b></p>
	<p><%= comment.message %></p>
	<p>
		<%= link_to 'Delete', admin_comment_path(comment), method: :delete, data: {confirm: 'Are you sure?'} %>
		<%= 
			if params[:status] == 'true'
				link_to 'Un-approve', admin_comment_path(comment, status: false), method: :put
			else
				link_to 'Approve', admin_comment_path(comment, status: true), method: :put
			end
		%>
	</p>
	<hr>
<% end %>

<%= paginate @comments %>
```

- add to_bool method in admin/application controller

```
  def to_bool string
    ActiveRecord::Type::Boolean.new.cast(string)
  end
```

- **unapproved and approved button**
- add the link to the comment/index

```
		<%= 
			if params[:status] == 'true'
				link_to 'Un-approve', admin_comment_path(comment, status: false), method: :put
			else
				link_to 'Approve', admin_comment_path(comment, status: true), method: :put
			end
		%>
	</p>
```

- make sure comments update action is


```
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
```

- **adding search to comments**
- add to the comment.rb, we are search visitor name with the joins,

```
  def self.matching_fullname_or_message params
    joins(:visitor).where("fullname LIKE ? OR message LIKE ?", "%#{params}%", "%#{params}%")
  end
```

- update the index action in comments controller

```
  def index
    if params[:search].present?
      @comments = Comment.matching_fullname_or_message(params[:search]).page params[:page]
    else
      # @comments = Comment.where(status: to_bool(params[:status])).page params[:page]
      # @comments = Comment.all.page params[:page]
      @comments = Comment.where(status: to_bool(params[:status])).page params[:page]
    end
  end
```    	  

- add to the comments/index the search form

```
<p>
	<%= form_tag(admin_comments_path, method: :get) do %>
		<%= text_field_tag :search %>
		<%= submit_tag 'Search' %>
	<% end %>	
</p>

```

- **refactoring the search form since we are using it in different places**
- create admin/application/search partial

```
<%= form_tag(route, method: :get) do %>
	<%= text_field_tag :search %>
	<%= submit_tag 'Search' %>
<% end %>
```

- in the views replace the forms with the render

```
<p>
	<%= render 'search', route: admin_comments_path %>
</p>
```

## creating visitors

- rails g controller admin/visitors index destroy
- update routes

```
  namespace :admin do
    resources :posts
    resources :visitors, only: [:index, :destroy]
    resources :comments, only: [:index, :update, :destroy]
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
```

- update visitors/index

```
<h1>Visitors</h1>

<% @visitors.each do |visitor| %>
	<p><%= visitor.fullname %></p>
	<p><%= visitor.email %></p>
	<p><%= time_ago visitor.created_at %></p>
	<p><%= link_to 'Delete', admin_visitor_path(visitor), method: :delete, data: {confirm: 'Are you sure?'} %></p>
	<hr>
<% end %>
```

- update visitors controller

```
class Admin::VisitorsController < Admin::ApplicationController
  def index
    @visitors = Visitor.all.order(id: :desc).page params[:page]
  end

  def destroy
    @visitor = Visitor.find(params[:id])
    @visitor.destroy
    flash[:notice] = 'Successfully deleted visitor'
    redirect_back(fallback_location: root_path)
  end
end

```

- update visitor.rb model

```
class Visitor < ApplicationRecord
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy
end
```

## sending messages

- rails g migration AddStatusToMessages status:boolean
- update the migration to add null false and default false

```
  def change
    add_column :messages, :status, :boolean, null: false, default: false
  end
```

- rails db:migrate
- update the messages in seed

```
  message = Message.create(
    content: Faker::Lorem.paragraph,
    status: [true, false].sample,
    visitor: visitor)
```  

- rails db:reset
- rails g controller admin/messages index show update destroy
- update routes

```
  namespace :admin do
    resources :posts
    resources :messages, only: [:index, :show, :update, :destroy]
    resources :visitors, only: [:index, :destroy]
    resources :comments, only: [:index, :update, :destroy]
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
```

- update messages/index

```
<h1>Messages</h1>

<p>
	<%= render 'search', route: admin_messages_path %>
</p>

<% @messages.each do |message| %>
	<p style=<%= message_weight(message) %>>
		<%= message.visitor.fullname %><br>
		<%= truncate(message.content, length: 60, separator: '') %><br>
		<%= status_converter(message.status, truthy: 'Read', falsey: 'Un-Read') %><br>
		<%= time_ago(message.created_at) %><br>
	</p>

	<p>
		<%= link_to 'Delete', admin_message_path(message), method: :delete, data: {confirm: 'Are you sure?'} %>
		<%= link_to 'Show', admin_message_path(message) %>
	</p>

	<p>
		<%= build_read_status_link message %>
	</p>

	<hr>
<% end %>

<%= paginate @messages %>
```

- update messages controller

```
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

```  

- update messages.rb

```
class Message < ApplicationRecord
  belongs_to :visitor

  def self.matching_fullname_or_content params
    joins(:visitor).where("fullname LIKE ? OR content LIKE ?", "%#{params}%", "%#{params}%")
  end

  def mark_read
    update(status: true) if status == false
  end
end

```

- update helpers/admin/messages helper

```
	def message_weight message
		message.status == false ? 'font-weight:bold' : 'font-weight:normal'
	end

	def build_read_status_link message
		if message.status == true 
			link_to 'Un-Read', admin_message_path(message, status: false), method: :put
		else
			link_to 'Read', admin_message_path(message, status: true), method: :put
		end
	end
```

- update messages/show

```
<h1>Messages#show</h1>

<p><b>From:</b> <%= @message.visitor.fullname %></p>
<p><b>When:</b> <%= time_ago @message.created_at %></p>
<p><b>Message:</b> <%= @message.content %></p>
```

- **how to mark message as read when you open the message**
- in the meassages controller show action, he links the method

```
    @message = Message.find(params[:id])
    @message.mark_read
  end
```

- and in the message.rb model creates the method

```
  def mark_read
    update(status: true) if status == false
  end
```

-   







## THESE ARE HIS NOTES ON WHAT HE'S BUILDING

- Moderators 

```
Actors:

1. Moderator
a. create
- is created the first time app is seeded
b. read
- visiting index page, should show the moderator's record
- can see edit link whilst viewing moderator
- cannot see delete link whilst viewing moderator
c. update
- can edit own moderator profile
- no empty fields are allowed during update
- show success/failure flash messages
d. delete
- moderator cannot delete themselves
```

- Sessions

```
Actors:
1. Moderators
a. visit any admin pages
- pages should all be behind an authentication system
- you shoud require username and password to login
- ability to logout by clicking logout link
b. create
- ability to create a new login session for a moderator
- by filling in username and password
- session should remember
c. read
- logout link on all pages that calls session destroy
d. delete
- destroy session
- show success/failure flash messages
```

- Posts

```
Actors: 
1. moderator
a. create
- can create new post with fields
- title, content, pubish(checkbox), tags(multi select)
- failure to fill in all fields will result in validation errors
- publish field should default to fale if left blank
- moderator has an option of selecting multiple tags for the post
- show success/failure flash messages
b. read
- can see a list of posts with headings
- title, publish, actions (delete, edit, show)
- will have a search field, to search by post title
- will have a search field, to search post by content
- clicking on 'show link' will take moderator to view blog details
- title content, publish status, created date
c. update
- can update any post
- show success/failure flash messages
```

- Tags

```
Actors:
1. moderator
a. create
- ability to create multiple tags separated by comma in a text field
- show success/failure flash messages
b. read
- list all tags with heading:
- name, actions, edit | delete
- make delete button in-active for tags in use
c. update
- can update any tags
- can also update tags in use
- show success/failure flash messages
d. delete
- cannot delete a tag currently attached to a blog
- can delete a tag not attached to any blog
- show success/failue flash messages
```

- Comments

```
Actors:
a. read
- approved comments
- can view a list of approved comments
- show delete link for each comment
- able to mark comment as not-approved
- not approved comments
- can view a list of not-approved comments
- show delete link each comment
- able to mark comment as approved
- should have a search field to search word pattern in comments
- should have a search field to search word pattern in visitor
b. update
- show success/failure flash messages
c. delete
- ability to delete any comment
- show success/failure flash messages
```

- Visitors

```
Actors:
a. read
- list all visitors with heading
- fullname, email, status, created
- should have a delete button
b. update
- 
c. delete
- deleting a visitor will:
- delete all comments by the user (warm before delete)
- show success/failure flash messages
```

- Messages

```
Actors:
1. moderators
a. read
- moderator sees a list of all messages with fields
- message, visitor name, date of message
- ability to search for messages by content
- ability to search for messages by visitor
- ability to mark messages as read
- this should make a font weight to regular for that message row
- ability to mark message as unread
- this should make the font weight to be bolded for that row
- clicking on view should
- show whow message is from, full message and date
- automatically mark the message as read
b. update
- show success/failure flash messages
c. delete
- can delete any message
- deleting message does not delete associated visitor
- show success/failure flash messages
```
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
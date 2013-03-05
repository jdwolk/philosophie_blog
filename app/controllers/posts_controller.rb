class PostsController < ApplicationController
  before_filter :authenticate_user!,
    :only => [:edit_index, :publish, :unpublish, :trash, :restore, :done]
  attr_accessor :filter_state

  def index
    # Only show posts with a "published" state
    @posts = Post.where(:state => :published).order(:published_at).reverse_order

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def edit_index
    # Succint index view for private editing
    if flash[:state_filter]
      @posts = Post.where(:state => flash[:state_filter].to_sym)
    else
      @posts = Post.order("state")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def filter_edit_index
    # For getting a subset of the edit_index
    state_filter = params["post"]["state"]

    redirect_to edit_index_posts_path,
      :flash => {:state_filter => state_filter}
  end

  def show
    @post = Post.find(params[:id])

    # For keeping slugs current or allowing use of ids in url
    if request.path != post_path(@post)
      redirect_to @post, status: :moved_permanently
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def create
    normalize_and_create_tags! params[:post]
    @post = Post.new(params[:post])
    save_and_return_to_edit_index(@post)
  end

  def update
    normalize_and_create_tags! params[:post]
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post,
                      notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  #### State transition actions ####

  def publish
    transition_action(:publish) do |post|
      post.transition!(:publish)
      post.published_at = Time.now
      post
    end
  end

  def unpublish
    transition_action(:unpublish) do |post|
      post.transition!(:unpublish)
      post.published_at = nil
      post
    end
  end
 
  [:save, :done, :trash, :restore].each do |action|
    define_method action.to_s do
      transition_action(action) do |post|
        post.transition!(action)
        post
      end
    end
  end

  private

  def normalize_and_create_tags!(post_fields)
    created_tags = create_tags(post_fields)
    post_fields.delete("tag")
    post_fields["tags"] = created_tags
    post_fields
  end

  def create_tags(post_fields)
    tags = post_fields["tag"]["tags"]
    tags.split(' ').map {|t| Tag.create!(:t_val => t)}
  end

  def transition_action(action, &blk)
    # No view associated, so don't need @
    post = Post.find(params[:id])
    changed_post = block_given? ? yield(post) : post
    save_and_return_to_edit_index(changed_post)
  end 
  
  def save_and_return_to_edit_index(post)
    respond_to do |format|
      if post.save
        format.html { redirect_to :action => "edit_index",
                      notice: 'Post was successfully updated.' }
      else
        format.html { render action: "edit_index" }
        format.json { render json: post.errors,
                      status: :unprocessable_entity }
      end
    end
    @post = post
  end

end

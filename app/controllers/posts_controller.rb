class PostsController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit_index, :publish, :unpublish, :trash, :restore, :done]

  def index
    # Only show posts with a "published" state
    @posts = Post.where(:state => :published).order(:published_at)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def edit_index
    # Succint index view for private editing
    @posts = Post.order("state")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
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
    @post = Post.new(params[:post])
    save_and_return_to_edit_index(@post)

#    respond_to do |format|
      #if @post.save
        #format.html { redirect_to @post, notice: 'Post was successfully created.' }
        #format.json { render json: @post, status: :created, location: @post }
      #else
        #format.html { render action: "new" }
        #format.json { render json: @post.errors, status: :unprocessable_entity }
      #end
    #end
  end

  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
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
    @post = Post.find(params[:id])

    # state == :completed
    @post.transition!(:publish)
    @post.published_at = Time.now 
    save_and_return_to_edit_index(@post)
  end

  def unpublish
    @post = Post.find(params[:id])

    # state == :published
    @post.transition!(:unpublish)
    @post.published_at = nil
    save_and_return_to_edit_index(@post)
  end

  def trash
    @post = Post.find(params[:id])

    @post.transition!(:trash)
    save_and_return_to_edit_index(@post)
  end

  def restore 
    @post = Post.find(params[:id])

    # state == :tossed
    @post.transition!(:restore)
    save_and_return_to_edit_index(@post)
  end

  def done
    @post = Post.find(params[:id])

    # state == :draft
    @post.transition!(:done)
    save_and_return_to_edit_index(@post)
  end


  private

  def save_and_return_to_edit_index(post)
    respond_to do |format|
      if post.save
        #format.html { redirect_to post, notice: 'Post was successfully updated.' }
        #format.json { render json: post, status: :created, location: post }
        format.html { redirect_to :action => "edit_index", notice: 'Post was successfully updated.' }
      else
        format.html { render action: "edit_index" }
        format.json { render json: post.errors, status: :unprocessable_entity }
      end
    end

    @post = post
  end

end

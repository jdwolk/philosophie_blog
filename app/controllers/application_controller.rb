class ApplicationController < ActionController::Base
  protect_from_forgery

  # Change devise's default sign-in path
  def after_sign_in_path_for(resource)
    edit_index_posts_path  
  end
end

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :state,          :default => "draft"
      t.text :body,             :null => false
      t.string :title,          :null => false
      t.datetime :published_at
      t.string :slug

      t.timestamps
    end
  end
end

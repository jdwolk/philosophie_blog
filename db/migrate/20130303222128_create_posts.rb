class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :state
      t.text :body
      t.string :title
      t.datetime :published_at
      t.string :slug

      t.timestamps
    end
  end
end

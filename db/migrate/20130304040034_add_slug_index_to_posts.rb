class AddSlugIndexToPosts < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      add_index :posts, :slug
    end
  end
end

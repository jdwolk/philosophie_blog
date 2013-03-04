class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :t_val, :null => false
      t.integer :post_id

      t.timestamps
    end
  end
end

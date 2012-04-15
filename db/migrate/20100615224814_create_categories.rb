class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :category
      t.string :name, :null => false
      t.string :slug

      t.timestamps
    end

    add_index :categories, :slug
  end
end

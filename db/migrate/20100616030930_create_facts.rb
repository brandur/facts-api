class CreateFacts < ActiveRecord::Migration
  def change
    create_table :facts do |t|
      t.references :category
      t.text :content

      t.timestamps
    end
  end
end

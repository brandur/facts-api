Sequel.migration do
  change do
    create_table :facts do |t|
      primary_key :id

      String :content

      foreign_key :category_id, :categories, on_delete: :cascade

      DateTime :created_at, null: false
      DateTime :updated_at
    end
  end
end

Sequel.migration do
  change do
    create_table :categories do
      primary_key :id

      String :name, null: false
      String :slug, null: false

      DateTime :created_at, null: false
      DateTime :updated_at

      index :slug
    end
  end
end

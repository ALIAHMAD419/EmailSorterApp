class AddParentIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :parent_id, :integer
    add_index :users, :parent_id
    add_foreign_key :users, :users, column: :parent_id, on_delete: :cascade
  end
end

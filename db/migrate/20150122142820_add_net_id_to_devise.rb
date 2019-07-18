class AddNetIdToDevise < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :username, :string
    change_column_null :users, :username, false
    change_column_null :users, :email, true, nil
    change_column_default :users, :email, nil
    add_index :users, :username, unique: true
  end
end

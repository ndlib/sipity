class AddWorkTypeToWork < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_works, :work_type, :string
    add_index :sipity_works, :work_type
    change_column_null :sipity_works, :work_type, false
  end
end

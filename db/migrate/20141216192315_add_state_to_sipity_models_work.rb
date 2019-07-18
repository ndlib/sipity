class AddStateToSipityModelsWork < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_works, :processing_state, :string, default: :new, limit: 64
    add_index :sipity_works, :processing_state
    change_column_null :sipity_works, :processing_state, false
  end
end

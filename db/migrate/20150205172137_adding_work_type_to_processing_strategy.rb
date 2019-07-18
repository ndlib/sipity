class AddingWorkTypeToProcessingStrategy < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_processing_strategies, :proxy_for_id, :integer
    add_column :sipity_processing_strategies, :proxy_for_type, :string

    add_index :sipity_processing_strategies, [:proxy_for_id, :proxy_for_type], unique: true, name: :sipity_processing_strategies_proxy_for
    change_column_null :sipity_processing_strategies, :proxy_for_id, false
    change_column_null :sipity_processing_strategies, :proxy_for_type, false
  end
end

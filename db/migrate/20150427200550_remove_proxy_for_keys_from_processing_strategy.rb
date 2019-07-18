class RemoveProxyForKeysFromProcessingStrategy < ActiveRecord::Migration[4.2]
  def change
    remove_index :sipity_processing_strategies, name: :sipity_processing_strategies_proxy_for
    remove_column :sipity_processing_strategies, :proxy_for_id
    remove_column :sipity_processing_strategies, :proxy_for_type
  end
end

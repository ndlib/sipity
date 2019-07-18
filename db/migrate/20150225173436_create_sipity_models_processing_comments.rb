class CreateSipityModelsProcessingComments < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_processing_comments do |t|
      t.string :entity_id, limit: 32
      t.integer :actor_id
      t.text :comment
      t.integer :originating_strategy_action_id
      t.integer :originating_strategy_state_id

      t.timestamps null: false
    end
    add_index :sipity_processing_comments, :entity_id
    add_index :sipity_processing_comments, :actor_id
    add_index :sipity_processing_comments, :originating_strategy_action_id, name: :sipity_processing_comments_action_index
    add_index :sipity_processing_comments, :originating_strategy_state_id, name: :sipity_processing_comments_state_index
    change_column_null :sipity_processing_comments, :entity_id, false
    change_column_null :sipity_processing_comments, :actor_id, false
    change_column_null :sipity_processing_comments, :originating_strategy_action_id, false
    change_column_null :sipity_processing_comments, :originating_strategy_state_id, false
  end
end

class AddingRequestedByAndOnBehalfOfToEntityActionRegister < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_processing_entity_action_registers, :requested_by_actor_id, :integer
    add_column :sipity_processing_entity_action_registers, :on_behalf_of_actor_id, :integer


    add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "on_behalf_of_actor_id"], name: "sipity_processing_entity_action_registers_on_behalf"
    add_index "sipity_processing_entity_action_registers", ["strategy_action_id", "entity_id", "requested_by_actor_id"], name: "sipity_processing_entity_action_registers_requested"

    change_column_null :sipity_processing_entity_action_registers, :requested_by_actor_id, false
    change_column_null :sipity_processing_entity_action_registers, :on_behalf_of_actor_id, false
  end
end

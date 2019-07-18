class AddingSubjectToEntityActionRegister < ActiveRecord::Migration[4.2]
  def change
    add_column :sipity_processing_entity_action_registers, :subject_id, :integer
    add_column :sipity_processing_entity_action_registers, :subject_type, :string

    add_index "sipity_processing_entity_action_registers", ["subject_id", "subject_type"], name: "sipity_processing_entity_action_registers_subject"

    # TODO: I want to add this but it requires a data migration
    # change_column_null :sipity_processing_entity_action_registers, :subject_id, false
    # change_column_null :sipity_processing_entity_action_registers, :subject_type, false
  end
end
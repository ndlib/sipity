class ConvertActionRegisterSubjectIdColumn < ActiveRecord::Migration[4.2]
  def change
    change_table :sipity_processing_entity_action_registers do |t|
      t.change :subject_id, :string, default: nil
    end
    change_column_null :sipity_processing_entity_action_registers, :subject_id, false
    change_column_null :sipity_processing_entity_action_registers, :subject_type, false
  end
end

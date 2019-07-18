class CreateSipityModelsTransientAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_transient_answers do |t|
      t.string :entity_id, limit: 32
      t.string :entity_type
      t.string :question_code
      t.string :answer_code

      t.timestamps null: false
    end

    add_index :sipity_transient_answers, [:entity_id, :entity_type]
    add_index :sipity_transient_answers, [:entity_id, :entity_type, :question_code], unique: true, name: :sipity_transient_entity_answers
    change_column_null :sipity_transient_answers, :entity_id, false
    change_column_null :sipity_transient_answers, :entity_type, false
    change_column_null :sipity_transient_answers, :question_code, false
    change_column_null :sipity_transient_answers, :answer_code, false
  end
end

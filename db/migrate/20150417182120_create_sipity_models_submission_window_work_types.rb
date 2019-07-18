class CreateSipityModelsSubmissionWindowWorkTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_submission_window_work_types do |t|
      t.integer :submission_window_id, null: false
      t.integer :work_type_id, null: false

      t.timestamps null: false
    end

    add_index(
      :sipity_submission_window_work_types,
      [:submission_window_id, :work_type_id],
      unique: true,
      name: :sipity_submission_window_work_types_surrogate
    )

    add_index(
      :sipity_submission_window_work_types,
      :submission_window_id,
      name: :idx_sipity_submission_window_work_types_submission_window_id
    )
    add_index(
      :sipity_submission_window_work_types,
      :work_type_id,
      name: :idx_sipity_submission_window_work_types_work_type_id
    )
  end
end

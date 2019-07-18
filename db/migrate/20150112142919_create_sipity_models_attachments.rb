class CreateSipityModelsAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_attachments, id: false do |t|
      t.string :work_id, limit: 32
      t.string :pid
      t.string :predicate_name
      t.string :file_uid
      t.string :file_name

      t.timestamps null: false
    end

    add_index :sipity_attachments, :work_id
    add_index :sipity_attachments, :pid, unique: true
    change_column_null :sipity_attachments, :work_id, false
    change_column_null :sipity_attachments, :predicate_name, false
    change_column_null :sipity_attachments, :file_uid, false
    change_column_null :sipity_attachments, :file_name, false
  end
end

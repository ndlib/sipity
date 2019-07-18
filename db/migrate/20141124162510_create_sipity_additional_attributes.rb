class CreateSipityAdditionalAttributes < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_additional_attributes do |t|
      t.string :work_id, limit: 32, null: false
      t.string :key, null: false
      t.string :value

      t.timestamps
    end
  end
end

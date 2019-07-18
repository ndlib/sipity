class CreateSipityModelsWorkRedirectStrategies < ActiveRecord::Migration[4.2]
  def change
    create_table :sipity_work_redirect_strategies do |t|
      t.string :work_id, null: false
      t.string :url, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.timestamps null: false
    end
    add_index :sipity_work_redirect_strategies, [:work_id, :start_date], name: :idx_work_redirect_strategies_surrogate
  end
end

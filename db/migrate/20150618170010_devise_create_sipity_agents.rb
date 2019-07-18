class DeviseCreateSipityAgents < ActiveRecord::Migration[4.2]
  def change
    create_table(:sipity_agents) do |t|
      ## Database authenticatable
      t.string :name, null: false
      t.text :description

      t.string :authentication_token, null: false

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :sipity_agents, :name,                 unique: true
    add_index :sipity_agents, :authentication_token, unique: true
  end
end

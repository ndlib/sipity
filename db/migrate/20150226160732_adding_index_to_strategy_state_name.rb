class AddingIndexToStrategyStateName < ActiveRecord::Migration[4.2]
  def change
    add_index "sipity_processing_strategy_states", "name"
  end
end

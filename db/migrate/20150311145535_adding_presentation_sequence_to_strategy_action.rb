class AddingPresentationSequenceToStrategyAction < ActiveRecord::Migration[4.2]
  def change
    add_column "sipity_processing_strategy_actions", "presentation_sequence", :integer
    add_index "sipity_processing_strategy_actions", ["strategy_id", "presentation_sequence"], name: "sipity_processing_strategy_actions_sequence"
  end
end

class TidyingUpEtdWorkflow < ActiveRecord::Migration[4.2]
  def self.up
    # Removing deprecated states but only if all is clear
    Sipity::Models::Processing::StrategyState.where(name: 'under_grad_school_review_with_changes').each do |state|
      raise "State #{state.name} (ID=#{state.id}) has one or more entities" if state.entities.any?
      state.destroy
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

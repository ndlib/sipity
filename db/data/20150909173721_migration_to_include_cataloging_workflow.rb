class MigrationToIncludeCatalogingWorkflow < ActiveRecord::Migration[4.2]
  def self.up
    migrator = new
    migrator.migrate_target_entities!
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  def migrate_target_entities!
    successfully_migrated = []
    errored_while_migrating = []
    target_entities do |target|
      begin
        target.update_column(:strategy_state_id, required_strategy_state_for(target).id)
        successfully_migrated << target
      rescue StandardError => e
        errored_while_migrating << [target, e]
      end
    end
    log_entities(successfully_migrated, errored_while_migrating)
  end

  private

  def etd_work_area
    PowerConverter.convert('etd', to: :work_area)
  end

  def each_etd_entities
    Sipity::Models::WorkSubmission.where(work_area: etd_work_area).find_each do |work_submission|
      yield(convert_to_entity(work_submission.work))
    end
  end

  def convert_to_entity(work)
    Sipity::Conversions::ConvertToProcessingEntity.call(work)
  end

  def target_entities
    each_etd_entities do |entity|
      yield(entity) if entity.strategy_state.name == 'ready_for_ingest'
    end
  end

  def required_strategy_state_for(entity)
    Sipity::Models::Processing::StrategyState.find_by!(
      strategy_id: entity.strategy_id, name: 'grad_school_approved_but_waiting_for_routing'
    )
  end

  def log_entities(successfully_migrated, errored_while_migrating)
    File.open(Rails.root.join("log", "migrated_entities_#{today}.log"), 'w') do |file|
      successfully_migrated.each do |entity|
        file.puts "Migrated Entity: #{entity.inspect}"
        file.puts "Migrated Work: #{entity.proxy_for.inspect}"
        file.puts "\n"
      end

      errored_while_migrating.each do |entity|
        file.puts "Errored Entity: #{entity.inspect}"
        file.puts "Errored Work: #{entity.proxy_for.inspect}"
        file.puts "\n"
      end
    end
  end

  def today
    Date.today.strftime("%Y%m%d")
  end
end

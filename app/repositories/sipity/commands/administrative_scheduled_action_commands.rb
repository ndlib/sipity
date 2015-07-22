module Sipity
  module Commands
    # Responsible for issuing commands against the AdministrativeScheduledAction
    module AdministrativeScheduledActionCommands
      def create_scheduled_action(work:, scheduled_time:, reason:)
        Sipity::Models::Processing::AdministrativeScheduledAction.create!(
          scheduled_time: scheduled_time,
          reason: reason,
          entity: PowerConverter.convert(work, to: :processing_entity)
        )
      end
    end
  end
end

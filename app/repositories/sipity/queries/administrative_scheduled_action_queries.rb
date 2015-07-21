module Sipity
  module Queries
    # Queries
    # TODO: These methods need to no longer be module_functions; I believe the
    #   direction is to look towards creating service objects.
    module AdministrativeScheduledActionQueries
      def scheduled_time_from_work(work:, reason:)
        Models::Processing::AdministrativeScheduledAction.where(
          entity: PowerConverter.convert(work, to: :processing_entity),
          reason: reason
        ).pluck(:scheduled_time)
      end
    end
  end
end

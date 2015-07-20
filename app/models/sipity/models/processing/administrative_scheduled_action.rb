module Sipity
  module Models
    module Processing
      # Responsible for keeping track for postponed cataloging
      class AdministrativeScheduledAction < ActiveRecord::Base
        self.table_name = 'sipity_models_processing_administrative_scheduled_action'

        belongs_to :entity, class_name: 'Sipity::Models::Processing::Entity'

        REASON = 'notify_cataloging'.freeze
        REASON_FOR_ENUM = {
          REASON => REASON
        }.freeze
        enum(reason: REASON_FOR_ENUM)
      end
    end
  end
end

module Sipity
  module Models
    module Processing
      # Responsible for keeping track for postponed cataloging
      class AdministrativeScheduledAction < ActiveRecord::Base
        self.table_name = 'sipity_models_processing_administrative_scheduled_actions'

        belongs_to :entity, class_name: 'Sipity::Models::Processing::Entity'

        NOTIFY_CATALOGING_REASON = 'notify_cataloging'.freeze
        REASON_FOR_ENUM = {
          NOTIFY_CATALOGING_REASON => NOTIFY_CATALOGING_REASON
        }.freeze
        enum(reason: REASON_FOR_ENUM)
      end
    end
  end
end

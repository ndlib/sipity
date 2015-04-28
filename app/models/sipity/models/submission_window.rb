module Sipity
  module Models
    # A conceptual container of when things can be added to the given WorkArea
    class SubmissionWindow < ActiveRecord::Base
      self.table_name = 'sipity_submission_windows'

      belongs_to :work_area

      has_many :submission_window_work_types, dependent: :destroy

      has_one :strategy_usage, as: :usage, class_name: 'Sipity::Models::Processing::StrategyUsage', dependent: :destroy

      def slug=(value)
        super(PowerConverter.convert(value, to: :slug))
      end
    end
  end
end

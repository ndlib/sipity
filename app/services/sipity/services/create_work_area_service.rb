module Sipity
  module Services
    # Codifies what it takes to "bootstrap" a bare-bones work area.
    #
    # My rationale for this is that the creation of a WorkArea sits outside of
    # the permissioning/processing system. In other words, a system
    # administrator (data super user) is needed to create a WorkArea.
    #
    # As an added benefit, this service is the equivalent of a FactoryGirl
    # factory; But something under proper test.
    class CreateWorkAreaService
      def self.call(**keywords)
        new(**keywords).call
      end

      def initialize(name:, slug:, **keywords)
        partial_suffix = keywords.fetch(:partial_suffix, slug)
        demodulized_class_prefix_name = keywords.fetch(:demodulized_class_prefix_name, slug)
        self.work_area_managers = keywords.fetch(:work_area_managers, [])
        self.work_area = find_or_create_work_area(
          name: name, slug: slug, partial_suffix: partial_suffix, demodulized_class_prefix_name: demodulized_class_prefix_name
        )
      end

      def call
        create_processing_strategy!
        create_work_area_processing_entity!
        associate_work_area_with_processing_strategy!
        associate_work_area_manager_with_processing_strategy!
        grant_permission_for_the_work_area_manager_to_see_the_area!
        grant_permission_for_the_work_area_manager_to_create_a_submission_window!
        work_area
      end

      attr_reader :work_area

      private

      attr_writer :work_area
      attr_reader :processing_strategy, :work_area_managers, :strategy_role

      def find_or_create_work_area(attributes)
        Models::WorkArea.find_by(attributes.slice(:name)) || Models::WorkArea.create!(attributes)
      end

      def create_work_area_processing_entity!
        work_area.processing_entity || work_area.create_processing_entity!(
          strategy: processing_strategy, strategy_state: processing_strategy.initial_strategy_state
        )
      end

      def associate_work_area_with_processing_strategy!
        Models::Processing::StrategyUsage.find_or_create_by!(strategy: processing_strategy, usage: work_area)
      end

      def create_processing_strategy!
        @processing_strategy ||= begin
          Models::Processing::Strategy.find_by(proxy_for_type: work_area.class.to_s) ||
          Models::Processing::Strategy.create!(
            proxy_for_id: 0, proxy_for_type: work_area.class, name: "#{work_area.class} processing strategy"
          )
        end
      end

      def associate_work_area_manager_with_processing_strategy!
        @strategy_role = Models::Processing::StrategyRole.find_or_create_by!(role: work_area_manager_role, strategy: processing_strategy)
        work_area_managers.each do |manager|
          Models::Processing::EntitySpecificResponsibility.find_or_create_by!(
            strategy_role: strategy_role,
            entity: work_area.processing_entity,
            actor: manager
          )
        end
      end

      def grant_permission_for_the_work_area_manager_to_see_the_area!
        strategy_action = Models::Processing::StrategyAction.find_or_create_by!(
          strategy: processing_strategy, name: 'show', allow_repeat_within_current_state: true
        )
        state_action = Models::Processing::StrategyStateAction.find_or_create_by!(
          strategy_action: strategy_action, originating_strategy_state: processing_strategy.initial_strategy_state
        )
        Models::Processing::StrategyStateActionPermission.find_or_create_by!(
          strategy_role: strategy_role, strategy_state_action: state_action
        )
      end

      def grant_permission_for_the_work_area_manager_to_create_a_submission_window!
        strategy_action = Models::Processing::StrategyAction.find_or_create_by!(
          strategy: processing_strategy, name: 'create_submission_window', allow_repeat_within_current_state: true
        )
        state_action = Models::Processing::StrategyStateAction.find_or_create_by!(
          strategy_action: strategy_action, originating_strategy_state: processing_strategy.initial_strategy_state
        )
        Models::Processing::StrategyStateActionPermission.find_or_create_by!(
          strategy_role: strategy_role, strategy_state_action: state_action
        )
      end

      def work_area_manager_role
        @work_area_manager_role ||= Conversions::ConvertToRole.call(Models::Role::WORK_AREA_MANAGER)
      end

      def work_area_managers=(managers)
        @work_area_managers = Array.wrap(managers).map { |manager| Conversions::ConvertToProcessingActor.call(manager) }
      end
    end
  end
end

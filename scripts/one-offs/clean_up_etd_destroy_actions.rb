# REAMDE:
#    The "destroy" action is being partially supplanted by a "deactivate" action.
#    The "destroy" action will only be available in the "new" state for the "creating_user" role.
#    The "deactivate" action will replace the "destroy" action for all other states/users in the ETDs.
#    The `app/data_generators/sipity/data_generators/work_types/etd_work_types.config.json` file
#    adds the "deactivate" action, but we need to manually delete the "destroy" actions that
#    we want to replace. This script does that.
#
# Delete all "destroy" actions that can be taken by any user that is not the "creating_user", for ETDs.

doctoral_dissertation = PowerConverter.convert(Sipity::Models::WorkType::DOCTORAL_DISSERTATION, to: :work_type)
master_thesis = PowerConverter.convert(Sipity::Models::WorkType::MASTER_THESIS, to: :work_type)

[doctoral_dissertation, master_thesis].each do |work_type|
  strategy = work_type.strategy_usage.strategy
  destroy_action = Sipity::Conversions::ConvertToProcessingAction.call("destroy", scope: strategy)
  destroy_action.strategy_state_actions.each do |strategy_state_action|
    if strategy_state_action.originating_strategy_state.name == "new"
      strategy_state_action.strategy_state_action_permissions.each do |strategy_state_action_permission|
        if strategy_state_action_permission.strategy_role.role.name != Sipity::Models::Role::CREATING_USER
          strategy_state_action_permission.destroy
        end
      end
    else
      strategy_state_action.destroy
    end
  end
end

# To test:
# Checkout master branch
# `bundle exec rake bootstrap`
# `bundle exec rails runner scripts/commands/generate_state_machine_diagrams.rb`
# Using Graphviz, open the output for Doctoral Dissertations and save the PNG
# `git checkout new_deactivate_state`
# `bundle exec rake db:seed`
# `bundle exec rails runner scripts/one-offs/clean_up_etd_destroy_actions.rb`
# `bundle exec rails runner scripts/commands/generate_state_machine_diagrams.rb`
# Using Graphviz, open the output for Doctoral Dissertations and save the PNG

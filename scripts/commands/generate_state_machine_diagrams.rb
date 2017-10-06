#!/usr/bin/env ruby -wU
require 'erb'

def yield_emails_for(sender)
  sender.notifiable_contexts.includes(email: { recipients: :role }).each do |notifiable_context|
    data = { reason: notifiable_context.reason_for_notification, template: notifiable_context.email.method_name }
    recipient_strategies = notifiable_context.email.recipients.group_by(&:recipient_strategy)
    recipient_strategies.each do |strategy, values|
      data[strategy.to_sym] = values.map { |value| value.role.name } if values.present?
    end
    yield(data)
  end
end
private :yield_emails_for

email_templater = ->(e) do
  strategies = []
  text = "#{e.fetch(:template)}("
  strategies << "to: #{e.fetch(:to).join(', ')}" if e.key?(:to)
  strategies << "cc: #{e.fetch(:cc).join(', ')}" if e.key?(:cc)
  strategies << "bcc: #{e.fetch(:bcc).join(', ')}" if e.key?(:bcc)
  text << strategies.join(" ; ") << ")"
end

Sipity::Models::Processing::Strategy.all.each do |__strategy|
  strategy = {
    name: __strategy.name,
    states: Set.new,
    actions: Set.new,
    edges: Set.new
  }

  # Create a diagraph file with correct header information
  __strategy.strategy_states.each do |__state|
    state = { name: __state.name, enrichments: Set.new, emails: Set.new, id: __state.id }
    yield_emails_for(__state) { |email| state[:emails] << email }
    __state.originating_strategy_state_actions.includes(:strategy_action, :strategy_state_action_permissions).each do |state_action|
      next if state_action.strategy_action.resulting_strategy_state_id
      state[:enrichments] << {
        name: state_action.strategy_action.name,
        roles: state_action.strategy_state_action_permissions.map {|o| o.strategy_role.role.name }
      }
    end

    strategy[:states] << state
  end

  __strategy.strategy_actions.includes(:resulting_strategy_state).each do |__action|
    if __action.resulting_strategy_state.present?
      config = {
        name: __action.name,
        next_state: __action.resulting_strategy_state.name,
        roles: __action.strategy_state_actions.map do |ssa|
          ssa.strategy_state_action_permissions.map { |perm| perm.strategy_role.role.name }
        end.flatten.compact.uniq,
        emails: Set.new
      }
      yield_emails_for(__action) { |email| config[:emails] << email }
      strategy[:actions] << config
    end
  end

  __strategy.strategy_states.each do |state|
    state.originating_strategy_state_actions.includes(:strategy_action, :strategy_state_action_permissions).each do |state_action|
      if state_action.strategy_action.action_type == 'state_advancing_action'
        strategy[:edges] << ["state_#{state.name.underscore}", "action_#{state_action.strategy_action.name.underscore}"]
        if state_action.strategy_action.resulting_strategy_state.present?
          strategy[:edges] << ["action_#{state_action.strategy_action.name.underscore}", "state_#{state_action.strategy_action.resulting_strategy_state.name.underscore}"]
        end
      end
    end
  end

  erb_file = File.join(File.dirname(__FILE__), '../templates/for_state_machines.dot.erb')
  output_filename = Rails.root.join("artifacts/state_machines/#{PowerConverter.convert(strategy.fetch(:name), to: :file_system_safe_file_name)}.dot")
  File.open(output_filename, 'w+') do |file|
    file.puts ERB.new(File.read(erb_file)).result(binding).split("\n").each(&:strip).select(&:present?).join("\n")
  end
end

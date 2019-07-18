users = User.create!([
  {email: "test@example.com", remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2015-02-24 18:32:52", last_sign_in_at: "2015-02-24 18:32:52", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", name: "Test User", role: nil, username: "test@example.com"},
  {email: "second-test@example.com", remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2015-02-24 18:32:52", last_sign_in_at: "2015-02-24 18:32:52", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", name: "Second Test User", role: nil, username: "second-test@example.com"}
])

work_types = Sipity::Models::WorkType.create!([
  {name: "doctoral_dissertation", description: nil}
])

actors = Sipity::Models::Processing::Actor.create!([
  {proxy_for: users[0], name_of_proxy: nil},
  {proxy_for: users[1], name_of_proxy: nil}
])

works = Sipity::Models::Work.create!([
  id: Rails.application.config.default_pid_minter.call, work_type: work_types[0].name
])

strategies = Sipity::Models::Processing::Strategy.create!([
  {name: "doctoral_dissertation processing", description: nil}
])

roles = Sipity::Models::Role.create!([
  {name: "creating_user", description: nil},
  {name: "etd_reviewing", description: nil},
  {name: "advising", description: nil}
])

strategy_states = Sipity::Models::Processing::StrategyState.create!([
  {strategy: strategies[0], name: "new"},
  {strategy: strategies[0], name: "under_advisor_review"}
])

strategy_actions = Sipity::Models::Processing::StrategyAction.create!([
  {strategy: strategies[0], name: "show", action_type: "resourceful_action"},
  {strategy: strategies[0], name: "describe", action_type: "enrichment_action"},
  {strategy: strategies[0], name: "assign_a_doi", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[1], name: "submit_for_review", action_type: "state_advancing_action"},
  {strategy: strategies[0], allow_repeat_within_current_state: false, name: "already_taken_on_behalf" },
  {strategy: strategies[0], allow_repeat_within_current_state: false, name: "already_taken_but_by_someone_else" },
  {strategy: strategies[0], allow_repeat_within_current_state: false, name: "analog_to_submit_for_review" }
])

strategy_roles = Sipity::Models::Processing::StrategyRole.create!([
  {strategy: strategies[0], role: roles[0]},
  {strategy: strategies[0], role: roles[1]},
  {strategy: strategies[0], role: roles[2]}
])

entities = Sipity::Models::Processing::Entity.create!([
  {proxy_for: works[0], strategy: strategies[0], strategy_state: strategy_states[1]}
])

entity_action_registers = Sipity::Models::Processing::EntityActionRegister.create!([
  {strategy_action: strategy_actions[1], entity: entities[0], subject: entities[0], requested_by_actor: actors[0], on_behalf_of_actor: actors[0]},
  {strategy_action: strategy_actions[3], entity: entities[0], subject: entities[0], requested_by_actor: actors[0], on_behalf_of_actor: actors[0]},
  {strategy_action: strategy_actions[4], entity: entities[0], subject: entities[0], requested_by_actor: actors[0], on_behalf_of_actor: actors[0]},
  {strategy_action: strategy_actions[5], entity: entities[0], subject: entities[0], requested_by_actor: actors[0], on_behalf_of_actor: actors[1]}
])

entity_specific_responsibilities = Sipity::Models::Processing::EntitySpecificResponsibility.create!([
  {strategy_role: strategy_roles[0], entity: entities[0], actor: actors[0]}
])

strategy_usages = Sipity::Models::Processing::StrategyUsage.create!([
  {strategy: strategies[0], usage: work_types[0]}
])

strategy_action_analogues = Sipity::Models::Processing::StrategyActionAnalogue.create!([
  {strategy_action: strategy_actions[6], analogous_to_strategy_action: strategy_actions[3]}
])

requiring_strategy_action_prerequisites = Sipity::Models::Processing::StrategyActionPrerequisite.create!([
  {guarded_strategy_action: strategy_actions[3], prerequisite_strategy_action: strategy_actions[1]}
])

strategy_state_actions = Sipity::Models::Processing::StrategyStateAction.create!([
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[1]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[3]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[4]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[4]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[5]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[5]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[6]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[6]}
])

strategy_state_action_permissions = Sipity::Models::Processing::StrategyStateActionPermission.create!([
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[5]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[2]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[3]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[1]},

  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[2]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[3]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[1]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[4]},

  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[1]},

  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[5]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[6]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[7]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[8]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[9]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[10]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[11]},

  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[6]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[7]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[8]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[9]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[10]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[11]}
])

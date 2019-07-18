# TODO: The purpose of this data is to establsih a set of data in which not
# all of the pre-requisites have been achieved.
#
# This data was generated via rake db:seed:dump
# It is used for a specific test.
users = User.create!([
  {email: nil, remember_created_at: nil, sign_in_count: 1, current_sign_in_at: "2015-02-23 15:05:46", last_sign_in_at: "2015-02-23 15:05:46", current_sign_in_ip: "::1", last_sign_in_ip: "::1", name: nil, role: nil, username: "jfriesen"}
])
actors = Sipity::Models::Processing::Actor.create!([
  {proxy_for: users[0], name_of_proxy: nil}
])

work_types = Sipity::Models::WorkType.create!([
  {name: "doctoral_dissertation", description: nil}
])

strategies = Sipity::Models::Processing::Strategy.create!([
  {name: "etd processing", description: nil}
])

roles = Sipity::Models::Role.create!([
  {name: "creating_user", description: nil},
  {name: "etd_reviewing", description: nil},
  {name: "advising", description: nil}
])

works = Sipity::Models::Work.create!([
  id: Rails.application.config.default_pid_minter.call, work_type: work_types[0].name
])

strategy_states = Sipity::Models::Processing::StrategyState.create!([
  {strategy: strategies[0], name: "new"},
  {strategy: strategies[0], name: "under_advisor_review"},
  {strategy: strategies[0], name: "advisor_changes_requested"},
  {strategy: strategies[0], name: "under_grad_school_review"},
  {strategy: strategies[0], name: "ready_for_ingest"},
  {strategy: strategies[0], name: "ingesting"},
  {strategy: strategies[0], name: "done"}
])

strategy_usages = Sipity::Models::Processing::StrategyUsage.create!([
  {strategy: strategies[0], usage: work_types[0]}
])
strategy_actions = Sipity::Models::Processing::StrategyAction.create!([
  {strategy: strategies[0], resulting_strategy_state: nil, name: "show", action_type: "resourceful_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "edit", action_type: "resourceful_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "destroy", action_type: "resourceful_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "describe", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "attach", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "collaborators", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "assign_a_doi", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: nil, name: "assign_a_citation", action_type: "enrichment_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[1], name: "submit_for_review", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[3], name: "advisor_signs_off", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[2], name: "advisor_requests_changes", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[1], name: "request_revision", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[4], name: "grad_school_signoff", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[5], name: "ingest", action_type: "state_advancing_action"},
  {strategy: strategies[0], resulting_strategy_state: strategy_states[6], name: "ingest_completed", action_type: "state_advancing_action"}
])
strategy_state_actions = Sipity::Models::Processing::StrategyStateAction.create!([
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[2], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[4], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[5], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[6], strategy_action: strategy_actions[0]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[1]},
  {originating_strategy_state: strategy_states[2], strategy_action: strategy_actions[1]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[1]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[2], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[2]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[3]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[4]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[5]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[6]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[6]},
  {originating_strategy_state: strategy_states[2], strategy_action: strategy_actions[6]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[6]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[7]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[7]},
  {originating_strategy_state: strategy_states[2], strategy_action: strategy_actions[7]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[7]},
  {originating_strategy_state: strategy_states[0], strategy_action: strategy_actions[8]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[9]},
  {originating_strategy_state: strategy_states[1], strategy_action: strategy_actions[10]},
  {originating_strategy_state: strategy_states[3], strategy_action: strategy_actions[11]}
])
strategy_action_prerequisites = Sipity::Models::Processing::StrategyActionPrerequisite.create!([
  {guarded_strategy_action: strategy_actions[8], prerequisite_strategy_action: strategy_actions[3]},
  {guarded_strategy_action: strategy_actions[8], prerequisite_strategy_action: strategy_actions[4]},
  {guarded_strategy_action: strategy_actions[8], prerequisite_strategy_action: strategy_actions[5]}
])
strategy_roles = Sipity::Models::Processing::StrategyRole.create!([
  {strategy: strategies[0], role: roles[0]},
  {strategy: strategies[0], role: roles[1]},
  {strategy: strategies[0], role: roles[2]}
])

entities = Sipity::Models::Processing::Entity.create!([
  {proxy_for: works[0], strategy: strategies[0], strategy_state: strategy_states[0]}
])

entity_action_registers = Sipity::Models::Processing::EntityActionRegister.create!([
  {strategy_action: strategy_actions[3], entity: entities[0], requested_by_actor: actors[0], on_behalf_of_actor: actors[0], subject: entities[0]}
])
entity_specific_responsibilities = Sipity::Models::Processing::EntitySpecificResponsibility.create!([
  {strategy_role: strategy_roles[0], entity: entities[0], actor: actors[0]}
])

strategy_state_action_permissions = Sipity::Models::Processing::StrategyStateActionPermission.create!([
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[25]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[7]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[14]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[15]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[16]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[10]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[17]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[21]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[1]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[19]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[23]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[2]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[8]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[12]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[3]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[4]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[5]},
  {strategy_role: strategy_roles[0], strategy_state_action: strategy_state_actions[6]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[7]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[14]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[15]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[16]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[10]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[17]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[21]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[1]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[18]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[22]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[11]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[26]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[27]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[19]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[2]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[8]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[12]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[20]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[24]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[28]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[3]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[9]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[13]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[4]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[5]},
  {strategy_role: strategy_roles[1], strategy_state_action: strategy_state_actions[6]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[0]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[1]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[26]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[27]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[2]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[3]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[4]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[5]},
  {strategy_role: strategy_roles[2], strategy_state_action: strategy_state_actions[6]}
])

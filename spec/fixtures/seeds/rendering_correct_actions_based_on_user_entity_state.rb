User.create!([
  {email: "test@example.com", remember_created_at: nil, sign_in_count: 2, current_sign_in_at: "2015-02-24 18:32:52", last_sign_in_at: "2015-02-24 18:32:52", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", name: "Test User", role: nil, username: "test@example.com"}
])
Sipity::Models::AccessRight.create!([
  {entity_id: 1, entity_type: "Sipity::Models::Work", access_right_code: "private_access"}
])
Sipity::Models::AdditionalAttribute.create!([
  {work_id: 1, key: "abstract", value: "Lorem ipsum"}
])
Sipity::Models::EventLog.create!([
  {user_id: 1, entity_id: 1, entity_type: "Sipity::Models::Work", event_name: "submit"},
  {user_id: 1, entity_id: 1, entity_type: "Sipity::Models::Work", event_name: "work_enrichments/describe_form/submit"},
  {user_id: 1, entity_id: 1, entity_type: "Sipity::Models::Work", event_name: "etd/submit_for_review_form/submit"}
])
Sipity::Models::Processing::Actor.create!([
  {proxy_for_id: 1, proxy_for_type: "User", name_of_proxy: nil}
])
Sipity::Models::Processing::Entity.create!([
  {proxy_for_id: 1, proxy_for_type: "Sipity::Models::Work", strategy_id: 1, strategy_state_id: "2"}
])
Sipity::Models::Processing::EntityActionRegister.create!([
  {strategy_action_id: 2, entity_id: 1, requested_by_actor_id: 1, on_behalf_of_actor_id: 1},
  {strategy_action_id: 4, entity_id: 1, requested_by_actor_id: 1, on_behalf_of_actor_id: 1}
])
Sipity::Models::Processing::EntitySpecificResponsibility.create!([
  {strategy_role_id: 1, entity_id: 1, actor_id: 1}
])
Sipity::Models::Processing::Strategy.create!([
  {name: "doctoral_dissertation processing", description: nil, proxy_for_id: 1, proxy_for_type: "Sipity::Models::WorkType"}
])
Sipity::Models::Processing::StrategyAction.create!([
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "show", form_class_name: nil, completion_required: false, action_type: "resourceful_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "describe", form_class_name: nil, completion_required: false, action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: nil, name: "assign_a_doi", form_class_name: nil, completion_required: false, action_type: "enrichment_action"},
  {strategy_id: 1, resulting_strategy_state_id: 2, name: "submit_for_review", form_class_name: nil, completion_required: false, action_type: "state_advancing_action"}
])
Sipity::Models::Processing::StrategyActionPrerequisite.create!([
  {guarded_strategy_action_id: 4, prerequisite_strategy_action_id: 2}
])
Sipity::Models::Processing::StrategyRole.create!([
  {strategy_id: 1, role_id: 1},
  {strategy_id: 1, role_id: 2},
  {strategy_id: 1, role_id: 3}
])
Sipity::Models::Processing::StrategyState.create!([
  {strategy_id: 1, name: "new"},
  {strategy_id: 1, name: "under_advisor_review"}
])
Sipity::Models::Processing::StrategyStateAction.create!([
  {originating_strategy_state_id: 1, strategy_action_id: 1},
  {originating_strategy_state_id: 2, strategy_action_id: 1},
  {originating_strategy_state_id: 1, strategy_action_id: 2},
  {originating_strategy_state_id: 1, strategy_action_id: 3},
  {originating_strategy_state_id: 2, strategy_action_id: 3},
  {originating_strategy_state_id: 1, strategy_action_id: 4}
])
Sipity::Models::Processing::StrategyStateActionPermission.create!([
  {strategy_role_id: 1, strategy_state_action_id: 6},
  {strategy_role_id: 1, strategy_state_action_id: 1},
  {strategy_role_id: 1, strategy_state_action_id: 3},
  {strategy_role_id: 1, strategy_state_action_id: 4},
  {strategy_role_id: 1, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 1},
  {strategy_role_id: 2, strategy_state_action_id: 3},
  {strategy_role_id: 2, strategy_state_action_id: 4},
  {strategy_role_id: 2, strategy_state_action_id: 2},
  {strategy_role_id: 2, strategy_state_action_id: 5},
  {strategy_role_id: 3, strategy_state_action_id: 1},
  {strategy_role_id: 3, strategy_state_action_id: 2}
])
Sipity::Models::Role.create!([
  {name: "creating_user", description: nil},
  {name: "etd_reviewer", description: nil},
  {name: "advisor", description: nil}
])
Sipity::Models::TransientAnswer.create!([
  {entity_id: 1, entity_type: "Sipity::Models::Work", question_code: "access_rights", answer_code: "private_access"}
])
Sipity::Models::Work.create!([
  {work_publication_strategy: "do_not_know", title: "Hello World", work_type: "doctoral_dissertation"}
])
Sipity::Models::WorkType.create!([
  {name: "doctoral_dissertation", description: nil},
  {name: "master_thesis", description: nil}
])

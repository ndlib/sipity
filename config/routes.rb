Rails.application.routes.draw do
  scope module: :sipity do
    scope module: :controllers do
      resources :works do
        resource :citation
        resource :doi do
          member do
            post :assign_a_doi
            post :request_a_doi
          end
        end
      end

      # TODO: There is the concept of valid enrichments; extract those
      enrichment_constraint = lambda do |request|
        enrichment_type = request.params.fetch(:enrichment_type)
        # REVIEW: Magic strings! There is a canonical enrichment question; And
        #   the valid enrichments may not be available for all work ids
        %(attach describe collaborators defense_date access_policy).include?(enrichment_type)
      end
      get 'works/:work_id/:enrichment_type', to: 'work_enrichments#edit', as: 'enrich_work', constraints: enrichment_constraint
      post 'works/:work_id/:enrichment_type', to: 'work_enrichments#update', constraints: enrichment_constraint

      # HACK: This is a shim to account for the policy behavior. I can look
      #   towards future normalization.
      get 'works/:work_id/assign_a_doi', to: 'dois#show'
      get 'works/:work_id/assign_a_citation', to: 'citations#show'

      get 'works/:id/trigger/update', to: 'works#edit'
      get 'works/:id/trigger/show', to: 'works#show'

      # # Are there constraints?
      get 'works/:work_id/trigger/:processing_action_name', to: 'work_event_triggers#new', as: 'event_trigger_for_work'
      post 'works/:work_id/trigger/:processing_action_name', to: 'work_event_triggers#create'

      #Account profile Managament
      get 'account/edit', to: 'account_profiles#edit'
      post 'account', to: 'account_profiles#update'
    end
  end

  root to: 'visitors#index'
  devise_for :users
  get 'dashboard', to: 'sipity/controllers/dashboards#index', as: "dashboard"
  get 'start', to: redirect('/works/new'), as: 'start'
end

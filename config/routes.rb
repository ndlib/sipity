require 'sipity/terms_of_service_failure_app'
Rails.application.routes.draw do
  root to: redirect('/areas/etd')

  constraints Sipity::Constraints::UnauthenticatedConstraint do
    get 'areas/:work_area_slug', to: 'sipity/controllers/visitors#work_area'
  end

  get 'status/:work_id', to: 'sipity/controllers/visitors#status'

  ##############################################################################
  # Begin Account related things
  ##############################################################################
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, failure_app: Sipity::TermsOfServiceFailureApp
  devise_scope :user do
    get 'sign_in', to: redirect("/users/auth/oktaoauth", status: 301), as: :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  devise_for :user_for_profile_managements, class_name: 'User', only: :sessions

  get 'account', to: 'sipity/controllers/account_profiles#edit', as: 'account'
  post 'account', to: 'sipity/controllers/account_profiles#update'
  get 'dashboard', to: 'sipity/controllers/dashboards#index', as: "dashboard"

  ##############################################################################
  # Begin Work Area
  ##############################################################################
  get(
    'areas/:work_area_slug', as: 'work_area', to: 'sipity/controllers/work_areas#query_action', defaults: { processing_action_name: 'show' }
  )
  get 'areas/:work_area_slug/do/:processing_action_name', as: 'work_area_action', to: 'sipity/controllers/work_areas#query_action'

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(http_verb_name, 'areas/:work_area_slug/do/:processing_action_name', to: 'sipity/controllers/work_areas#command_action')
  end

  ##############################################################################
  # Begin Submission Window
  ##############################################################################
  get(
    'areas/:work_area_slug/:submission_window_slug',
    as: 'submission_window',
    defaults: { processing_action_name: 'show'},
    to: 'sipity/controllers/submission_windows#query_action'
  )

  get(
    'areas/:work_area_slug/:submission_window_slug/do/:processing_action_name',
    as: 'submission_window_action',
    to: 'sipity/controllers/submission_windows#query_action'
  )

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(
      http_verb_name,
      'areas/:work_area_slug/:submission_window_slug/do/:processing_action_name',
      to: 'sipity/controllers/submission_windows#command_action'
    )
  end

  # This route should considered deprecated
  get 'start', to: redirect('/areas/etd/start', status: 301), as: 'start'

  ##############################################################################
  # Begin Work Submission
  ##############################################################################
  get(
    'work_submissions/:work_id',
    as: 'work_submission',
    to: 'sipity/controllers/work_submissions#query_action',
    defaults: { processing_action_name: 'show' }
  )
  get(
    'work_submissions/:work_id/do/:processing_action_name',
    as: 'work_submission_action',
    to: 'sipity/controllers/work_submissions#query_action'
  )
  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(
      http_verb_name,
      'work_submissions/:work_id/callback/:processing_action_name', to: 'sipity/controllers/work_submission_callbacks#command_action'
    )
    send(http_verb_name, 'work_submissions/:work_id/do/:processing_action_name', to: 'sipity/controllers/work_submissions#command_action')
  end

  get '/work_submissions/:work_id/comments', to: 'sipity/controllers/comments#index', as: 'work_comments'
  get '/works/:work_id', to: redirect('/work_submissions/%{work_id}', status: 301), as: 'work'

  ##############################################################################
  # Begin Attachments
  ##############################################################################

  # I need parentheses or `{ }` for the block, because of when the blocks are
  # bound.
  get(
    "extname_thumbnails/:width/:height/:text(.:format)" => Dragonfly.app.endpoint do |params, app|
      height = params[:height].to_i
      app.generate(:text, params[:text], 'font-size' => (height / 4 * 3), 'padding' => "#{(height - (height / 4 * 3)) / 2} 8").
        thumb("#{height}x#{params[:width]}#", 'format' => params['format'] )
    end
  )
end

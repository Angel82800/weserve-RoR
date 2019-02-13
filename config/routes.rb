Rails.application.routes.draw do
  match "/status/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
  match "/update_acc_status", to: "stripe_webhooks#update_acc_status", via: [:get, :post]

  if Rails.env.production?
    DelayedJobWeb.use Rack::Auth::Basic do |username, password|
      username == ENV['delayed_job_username'] && password == ENV['delayed_job_password']
    end
  end

  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end

  resources :group_messages, only: [:index, :create]
  post 'group_messages/get_chatroom'
  post 'group_messages/refresh_chatroom_messages'
  get 'group_messages/download_files'
  get 'pages/terms_of_use'
  get 'pages/privacy_policy'
  get 'tasks/task_fund_info'

  resources :group_messages do
    get :autocomplete_user_username, :on => :collection
  end
  get 'group_messages/search_user'
  post 'tasks/send_email'
  post 'task_attachments/create'
  post 'task_attachments/destroy_attachment'
  resources :profile_comments, only: [:index, :create, :update, :destroy]
  resources :plans
  resources :cards

  resources :notifications, only: [:index, :destroy] do
    collection do
      put :mark_all_as_read
      get :load_older
    end
  end

  resources :teams do
    collection do
      get :users_search
    end
  end

  resources :admin_requests, only: [:create] do
    member do
      post :accept, :reject
    end
  end

  resources :apply_requests, only: [:create] do
    member do
      post :accept, :reject
    end
  end

  resources :team_memberships, only: [:update, :destroy]
  resources :work_records
  # post 'user_wallet_transactions/send_to_any_address'
  post 'user_wallet_transactions/send_to_task_address'
  # get 'user_wallet_transactions/send_to_personal_coinbase'
  resources :proj_admins, only: [:create] do
    member do
      put :accept, :reject
    end
  end
  resources :assignments, only: [:new, :create] do
    member do
      put :accept, :reject, :completed, :confirmed, :confirmation_rejected
    end
    collection do
      put :update_collaborator_invitation_status
    end
  end

  resources :do_requests, only: [:new, :create, :destroy] do
    member do
      put :accept, :reject
    end
  end

  resources :activities, only: [:index]
  resources :wikis
  resources :tasks, only: [:show, :create, :update, :destroy] do
    member do
      put :accept, :reject, :doing, :reviewing, :completed, :refund, :incomplete, :request_change, :cancel
      put '/back_funding/:assignee_id', to: 'tasks#back_funding', as: :back_funding
      put '/update_task_in_progress', to: 'tasks#update_task_in_progress'
      put '/add_assignee', to: 'tasks#add_assignee'
      get '/preview', to: 'tasks#preview'
      put '/set_approve_change_task', to: 'tasks#set_approve_change_task'
      post '/review', to: 'tasks#create_task_review'
      delete '/members/:team_membership_id', to: 'tasks#remove_member', as: :remove_task_member
      delete '/remove_assignee/:membership_id', to: 'tasks#remove_assignee', as: :remove_assignee
    end
  end

  resources :discussions, only: [:destroy] do
    member do
      put :accept
    end
  end

  resources :favorite_projects, only: [:create, :destroy]
  resources :home , controller: 'projects'
  resources :projects, :except => [:edit] do
    resources :tasks, only: [:show, :create, :update, :destroy] do
      member do
        get :show_share, to: 'tasks#show_share'
        get :card_payment, to: 'payments/stripe#new'
        post :card_payment, to: 'payments/stripe#create'
      end
      resources :task_comments, only: [:create, :destroy]
      resources :assignments, only: [:new, :create]
    end
    resources :subprojects, only: [:index, :destroy]
    resources :project_comments
    resources :boards

    member do
      get :discussions, :revisions, :plan, :read_from_mediawiki, :unblock_user,
          :block_user, :taskstab, :requests, :show_project_team, :donors
      post :follow, :rate, :switch_approval_status, :write_to_mediawiki,
           :save_edits, :update_edits, :create_subpage, :sub_pages
      put :accept, :reject, :unfollow, :revision_action
      put :rename_subpage, defaults: {format: :json}
      put '/change_leader_by_admin/:user_id', to: 'projects#change_leader_by_admin', as: 'change_leader_by_admin'
      put '/change_user_role/:user_id', to: 'projects#change_user_role', as: 'change_user_role'
      post :rearrange_order_tasks
      post :rearrange_order_boards
    end

    collection do
      get :get_activities, :show_all_teams, :show_all_revision,
          :show_task, :autocomplete_user_search, :archived, :search_results,
          :get_in, :user_search
      post :send_project_invite_email, :send_project_email,
           :start_project_by_signup, :change_leader
    end
  end

  resources :change_leader_invitation, only: [] do
    member do
      put :accept, :reject
    end
  end

  get "/oauth2callback" => "projects#contacts_callback"
  get "/callback" => "projects#contacts_callback"
  get '/contacts/failure' => "projects#failure"
  get '/contacts/gmail'
  get '/contacts/yahoo'
  get '/pages/privacy_policy'
  get '/pages/terms_of_use'

  namespace :pusher do
    put '/chat_sessions' => 'chat_sessions#update', as: :chat_session
    resources :auth, only: [:create]
    resources :chat_sessions, only: [:create]
    resources :messages, only: [:create]
  end

  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations',
    omniauth_callbacks: 'omniauth_callbacks',
    confirmations: 'confirmations'
  }

  resources :users do
    member do
      get :my_wallet
      get :payout_method
      get :payout_details
      post :payout
      get :remove_external
      get :withdraw_method
      post :payout_external
      match '/credit_card', to: "users#credit_card", via: [:get, :post]
      match '/bank', to: "users#bank", via: [:get, :post]
      match '/verify', to: "users#verify", via: [:get, :post]
    end
    collection do
      get :state
    end
  end

  namespace :api do
    namespace :v1 do
      resources :mediawiki do
        collection do
          post :page_edited
        end
      end
    end
  end

  resources :transaction_histories, only: [:index]

  resources :tax_deduction, except: [:index, :show, :destroy]
  get '/download_tax_receipt/:transaction_id', to: 'tax_deduction#download_tax_receipt', as: 'download_tax_receipt'

  get 'my_projects', to: 'users#my_projects', as: :my_projects
  root to: 'visitors#landing'
end

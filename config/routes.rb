Rails.application.routes.draw do
  get "orders/index"
  get "orders/new"
  get "orders/create"
  get "orders/show"
  get "orders/edit"
  get "orders/update"
  get "orders/destroy"
  get "receipts/new"
  get "receipts/create"
  get "receipts/index"
  get "receipts/show"
  get "receipts/edit"
  get "receipts/update"
  get "receipts/destroy"
  get "transactions", to: "transactions#index"  # This creates transactions_path
  get "vendors/index"
  get "vendors/show"
  get "vendors/new"
  get "vendors/create"
  get "vendors/edit"
  get "vendors/update"
  get "vendors/destroy"
  get "cost_centers/index"
  get "cost_centers/show"
  get "cost_centers/new"
  get "cost_centers/create"
  get "cost_centers/edit"
  get "cost_centers/update"
  get "cost_centers/destroy"
  get "item_groups/index"
  get "item_groups/show"
  get "item_groups/new"
  get "item_groups/create"
  get "item_groups/edit"
  get "item_groups/update"
  get "item_groups/destroy"
  get '/.well-known/*path', to: proc { [204, {}, ['']] }
devise_for :users

  root 'dashboard#index'

  resources :items
  resources :categories
  resources :warehouses
  resources :suppliers
  resources :receipts
  resources :orders do
  resources :order_lines, only: [:create, :destroy]
  resources :transactions
  end

  resources :stock_transactions, except: [:edit, :update, :destroy]

  resources :reports, only: [:index] do
    collection do
      get 'inventory_status'
      get 'transaction_history'
      get 'valuation_report'
    end
  end

  get 'dashboard', to: 'dashboard#index'
end

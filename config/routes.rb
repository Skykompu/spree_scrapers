Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :admin do
    resources :scrapers do
      member do
        get :scrape
      end
    end
  end
end

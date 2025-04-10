Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :tasks, except: %i[new show edit] do
        patch :reorder, on: :collection
      end
    end
  end
end

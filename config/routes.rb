Rails.application.routes.draw do
  scope module: :markdown, defaults: { business: 'markdown' } do
    scope '(:base_name)' do
      resources :assets, only: [:show], constraints: { id: /.+/ }
      resources :posts, only: [:index]
      resources :posts, only: [] do
        collection do
          get 'ppt/*slug' => :ppt
          get 'raw/*slug' => :raw
          get 'content/*slug' => :content
          get '(*slug)' => :show
        end
      end
    end
    resources :gits, only: [:show] do
      member do
        post '' => :create
      end
    end
  end

  namespace :markdown, defaults: { business: 'markdown' } do
    namespace :admin, defaults: { namespace: 'admin' } do
      root 'home#index'
      resources :gits do
        member do
          post :edit_github_user
        end
        resources :catalogs do
          collection do
            get :all
          end
          member do
            patch :reorder
          end
        end
        resources :posts do
          collection do
            post :sync
          end
        end
        resources :assets do
          collection do
            post :sync
          end
        end
      end
    end

    namespace :panel, defaults: { namespace: 'panel' } do
      root 'home#index'
      resources :gits do
        member do
          post :edit_github_user
        end
        resources :catalogs do
          collection do
            get :all
          end
          member do
            patch :reorder
          end
        end
        resources :posts do
          collection do
            post :sync
          end
        end
        resources :assets do
          collection do
            post :sync
          end
        end
      end
    end
  end
end

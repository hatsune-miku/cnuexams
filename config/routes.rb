Rails.application.routes.draw do
    root 'main#index'
    resources :users
    resources :overview
    resources :statics
    resources :exams
end

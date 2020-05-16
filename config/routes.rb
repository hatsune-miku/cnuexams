Rails.application.routes.draw do
    root 'main#index'
    resources :users
    resources :overview
    resources :statics
    resources :exams
    resources :questions
    resources :members
    resources :upload
    resources :preferences
    resources :institutes
    resources :auths
    resources :exam_question_kinds

    resources :member
    namespace :member do
        resources :overview
    end
end

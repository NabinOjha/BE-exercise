Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get "payments_with_index", to: "payments#payments_with_quality_check"
  root "payments#payments_with_quality_check"
end

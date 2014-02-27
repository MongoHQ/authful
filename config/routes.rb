Authful::Application.routes.draw do
  get 'qr/:id.png' => 'qr#show', as: :qr_code
  
  mount Authful::API => '/api'
end

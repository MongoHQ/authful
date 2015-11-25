Authful::Application.routes.draw do
  get 'qr/:id.png' => 'qr#show', as: :qr_code

  mount Authful::API => '/api'

  get :status, to: proc { [200, {}, ['']] }
end

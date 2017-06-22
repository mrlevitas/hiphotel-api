Rails.application.routes.draw do
  scope '/hotels' do
    get '/search' => 'hotel_search#index'
  end
end

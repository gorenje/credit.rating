get '/rating/:eid' do
  @user = User.find_by_external_id(params[:eid])
  @user.update_rating if @user && @user.rating.nil?
  haml :rating_user
end

get '/rating' do
  @user = User.find(session[:user_id])
  @user.update_rating
  haml :rating
end

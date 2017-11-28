get '/badge' do
  @user = User.find(session[:user_id])
  haml :badge
end

get '/badge/:eid.svg' do
  @clr = "black"
  generate_svg "button" do
    @rating = if user = User.find_by_external_id(params[:eid])
                user.update_rating if user.rating.nil?
                user.rating.score || 0
              else
                "---"
              end
  end
end

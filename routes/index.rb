get "/" do
  if params[:state] == "qweqwe" && params[:code]
    redirect "/callback?#{params.to_query}"
  else
    haml :index
  end
end

{ "/aboutus" => :aboutus,
  "/contact" => :contact,
}.each do |path, view|
  get path do
    haml view
  end
end

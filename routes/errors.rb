error 406 do
  if @env['sinatra.error'].is_a?(ErrorPage::FormatNotSupported)
    @message = @env['sinatra.error'].message
    haml :format_not_supported
  end
end

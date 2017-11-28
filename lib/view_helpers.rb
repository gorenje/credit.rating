module ViewHelpers
  def redirect_host_to_ssl?
    request.scheme == 'http' &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def redirect_host_to_www?
    !(request.host =~ /^www[.]/) &&
      !ENV['HOSTS_WITH_NO_SSL'].split(",").map(&:strip).include?(request.host)
  end

  def return_json
    content_type :json
    yield.to_json
  end

  def must_be_logged_in
    redirect '/' unless is_logged_in?
  end

  def view_exist?(path)
    File.exists?(File.dirname(__FILE__)+"/../views/#{path}.haml")
  end

  def is_logged_in?
    !!session[:user_id]
  end

  def page_can_be_viewed_while_not_logged_in
    ['/', '/auth', '/logout', '/aboutus', '/contact', '/login', '/register',
     '/users/email-confirmation', '/user/emailconfirm'].
      include?(request.path_info) ||
      case request.path_info
      when /^\/api\/rating\/.+[.]json/ then true
      when /^\/badge\/.+[.]svg/ then true
      when /^\/rating\/.+/ then true
      when /^\/resend\/email\/.+/ then true
      else
        false
      end
  end

  def format_rating_value(val)
    return "-" if val.nil?
    val.is_a?(Integer) ? val : "%02.2f" % val
  end

  def format_date(dt)
    dt.to_s
  end

  def path_replace_account_id(new_account)
    request.path_info.sub(/#{@account.id}/, "#{new_account.id}")
  end

  def extract_email_and_salt(encstr)
    estr = begin
             AdtekioUtilities::Encrypt.decode_from_base64(encstr)
           rescue
             begin
               AdtekioUtilities::Encrypt.decode_from_base64(CGI.unescape(encstr))
             rescue
               "{}"
             end
           end
    # this is a hash: { :email => "fib@fna.de", :salt => "sddsdad" }
    # so sorting and taking the last will give: ["fib@fna.de","sddsdad"]
    JSON.parse(estr).sort.map(&:last) rescue [nil,nil]
  end

  def to_email_confirm(s)
    "#{$hosthandler.login.url}/users/email-confirmation?r=#{s}"
  end

  def params_blank?(*args)
    args.any? { |a| params[a].blank? }
  end

  def generate_svg(name, &block)
    content_type "image/svg+xml"
    yield if block_given?
    haml :"images/_#{name}.svg", :layout => false
  end

  def get_account
    Account.
      where(:user_id => session[:user_id], :id => params[:account_id]).first
  end

  def generate_fake_rating_history_data
    xlookup = {}.tap do |hsh|
      ((Date.today - 17)..Date.today).to_a.each_with_index { |d,i| hsh[i] = d }
    end

    dataset = 18.times.map { |idx| { "x" => idx, "y" => rand(10)-5 } }
    yvalues = dataset.map { |a| a["y"] }
    ymax, ymin = yvalues.max, yvalues.min

    {"data"=>
      [{"name"  =>"Rating",
         "color"=>"green",
         "data" => dataset}],
      "xlookup" => xlookup,
      "ymax"    => ymax > 0 ? ymax + (ymax*0.1) : ymax - (ymax*0.1),
      "ymin"    => ymin > 0 ? ymin - (ymin*0.1) : ymin + (ymin*0.1)}
  end
end

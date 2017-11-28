# -*- coding: utf-8 -*-
require './application.rb'

use Rack::Session::Cookie,
    :secret => (ENV['COOKIE_SECRET'] || '74y?W}LCxutk<H,0o,QJ]p!Öe{zF*x86')

if settings.environment == "development"
  require 'term/ansicolor'
  class String ; include Term::ANSIColor end
  clr = :green
  Sinatra::Application.routes.keys.each do |verb|
    clr = { :green => :blue, :blue => :green }[clr]
    Sinatra::Application.routes[verb].each do |route|
      puts "#{verb.send(clr)} #{route[0].to_s.red}"
    end
  end
end

run Sinatra::Application

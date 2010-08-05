require "rubygems" ; require "bundler" ; Bundler.setup(:default)
require 'sinatra/base'

class ShoulderPads < Sinatra::Base
  get '/hello' do
    'Hello World'
  end
end

use Rack::Lint
run ShoulderPads

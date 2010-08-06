require "rubygems" ; require "bundler" ; Bundler.setup(:default)
require "sinatra/base"
require "sinatra/helpers"
require "dm-core"
require "dm-migrations"
require "dm-validations"
require "digest/md5"
require "curb"

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'mysql://localhost/shoulder_pads')

class ::Resource
  include DataMapper::Resource

  property :id, Serial
  property :short, String, :length => 40, :unique_index => true
  property :url, String, :length => 255, :required => true

  before :save, :generate_short

  def generate_short
    self.short = Digest::MD5.hexdigest("#{url}-#{Time.now}")
  end

  def uri
    @parsed ||= URI.parse(url)
  end

  def get
    Curl::Easy.perform(url)
  end

  def response(callback)
    200, {'Content-Type' => 'text/javascript'}, "#{callback}(#{get.response_str})"
  end
end

DataMapper.auto_upgrade!

class ShoulderPads < Sinatra::Base
  include Sinatra::Helpers

  get '/new' do
    haml :new
  end

  post '/resources' do
    resource = Resource.create(:url => params['url'])
    redirect "/u/#{resource.short}"
  end

  get '/u/:short' do
    @resource = Resource.first(:short => params['short'])
    raise @resource.get.body_str

    halt *@resource.response(params['callback'] || "loadJsonp")
  end
end

use Rack::Lint
run ShoulderPads

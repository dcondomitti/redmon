class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :show_exceptions => false
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)


  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers do
    include Rack::Utils
    include Redmon::RedisUtils

    def redis_url
      @opts[:redis_url]
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end

    def config
      @redis.config :get, '*'
    end

    def prompt
      "#{@opts[:redis_url].gsub('://', ' ')}>"
    end

    def poll_interval
      @opts[:poll_interval] * 1000
    end
  end

  def initialize(opts)
    @opts  = opts
    @redis = Redis.connect(:url => redis_url)
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/config' do
    content_type :json
    config.to_json
  end

  get '/info' do
    content_type :json
    @redis.zrange(info_key(ns), count, -1).to_json
  end

  def ns
    @opts[:namespace]
  end

  def redis_url
    @opts[:redis_url]
  end
end
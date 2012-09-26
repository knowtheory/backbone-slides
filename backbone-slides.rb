require "rubygems"
require "erb"
require "bundler/setup"
Bundler.require(:default)

here = File.dirname(__FILE__)

AppConfig = {}

AppConfig['database'] = YAML.load(ERB.new(File.open(File.join(here, 'config', 'database.yml' )).read).result)
AppConfig['twitter']  = YAML.load(ERB.new(File.open(File.join(here, 'config', 'twitter.yml' )).read).result)
DataMapper.setup(:default, AppConfig['database'][ENV['RACK_ENV'] || 'development'])

class User
  include DataMapper::Resource
  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :created_at, DateTime
end

class Slide
  include DataMapper::Resource
  property :id, Serial
  property :body, Text
  property :format, Enum[:markdown, :html]
  
  has n, :comments
  
  def canonical
    {
      :id => id,
      :body => body,
      :comments => comments
    }
  end
end

class Comment
  include DataMapper::Resource
  property :id,   Serial
  property :body, Text
  belongs_to :user
  belongs_to :slide
end

DataMapper.finalize
DataMapper.auto_upgrade!

class SlideApp < Sinatra::Base
  use OmniAuth::Strategies::Twitter, AppConfig['twitter']['consumer_key'], AppConfig['twitter']['consumer_secret']

  enable :sessions
  
  configure do
    mime_type :js, 'application/javascript'
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id]) if session[:user_id]
    end
    
    def pick(hash, *keys)
      filtered = {}
      hash.each {|key, value| filtered[key] = value if keys.include?(key) }
      filtered
    end
  end
  
  get '/' do
    @slides = Slide.all
    erb :slides, :layout => :slide_layout
  end

  get '/auth/:name/callback' do
    auth = request.env["omniauth.auth"]
    user = User.first_or_create({ :uid => auth["uid"]}, {
      :uid => auth["uid"],
      :nickname => auth["info"]["nickname"], 
      :name => auth["info"]["name"],
      :created_at => Time.now })
    session[:user_id] = user.id
    redirect '/'
  end

  # any of the following routes should work to sign the user in: 
  #   /sign_up, /signup, /sign_in, /signin, /log_in, /login
  ["/sign_in/?", "/signin/?", "/log_in/?", "/login/?", "/sign_up/?", "/signup/?"].each do |path|
    get path do
      redirect '/auth/twitter'
    end
  end

  # either /log_out, /logout, /sign_out, or /signout will end the session and log the user out
  ["/sign_out/?", "/signout/?", "/log_out/?", "/logout/?"].each do |path|
    get path do
      session[:user_id] = nil
      redirect '/'
    end
  end

  get '/slides.?:format?' do
    @slides = Slide.all
    case params[:format]
    when "html"
      erb :slides, :layout => :slide_layout
    else
      @slides.map(&:canonical).to_json
    end
  end
  
  post '/slides/:id/comments' do
    raise Sinatra::NotFound unless @slide = Slide.get(params[:id])
    return 403 unless current_user
    attributes = ::JSON.parse(request.body.read)
    puts attributes.inspect
    attrs = pick(attributes, 'body').merge(:slide_id => @slide.id, :user_id => current_user.id)
    puts attrs.inspect
    @comment = Comment.new(attrs)
    if @comment.save
      @slide.comments.to_json
    else
      raise 401, @comment.errors.to_json
    end
  end
  
  get '/slides/:id/comments.?:format?' do
    raise Sinatra::NotFound unless @slide = Slide.get(params[:id])
    @comments = Slide.comments
    @comments.to_json
  end
  
  get '/templates.js' do
    content_type :js
    template_dir = Dir.open('views/jst')
    templates = template_dir.select{ |filename| filename =~ /jst$/}.map do |filename|
      raw = File.open('views/jst/' + filename ).read
      name = filename.gsub('.jst', '')
      template_body = raw.gsub(/\n/,'').gsub(/\\|'/){ |c| "\\#{c}" }
      "JST['#{name}'] = _.template('#{ template_body }');"
    end
    "JST = {};\n#{templates.join("\n")}"
  end
end
require 'sinatra'
require 'rubygems'
require 'haml'
require 'json'
require 'rest_client'
require 'securerandom'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'omniauth-facebook'

require_relative 'libs/DatabaseHandler'
require_relative 'libs/EventHandler'
require_relative 'libs/UserHandler'
require_relative 'libs/AuthHandler'
require_relative 'libs/ScoreHandler'

unless CLOUDANT_URL = ENV['CLOUDANT_URL']
  raise "You must specify the CLOUDANT_URL env variable"
end

unless GOOGLE_SECRET = ENV['GOOGLE_SECRET']
  raise "You must specify the GOOGLE_SECRET env variable"
end

unless GOOGLE_KEY = ENV['GOOGLE_KEY']
  raise "You must specify the GOOGLE_KEY env variable"
end

unless FACEBOOK_ID = ENV['FACEBOOK_ID']
  raise "You must specify the FACEBOOK_ID env variable"
end

unless FACEBOOK_SECRET = ENV['FACEBOOK_SECRET']
  raise "You must specify the FACEBOOK_SECRET env variable"
end

$DB_URL = ENV['CLOUDANT_URL'] + '/tennis'
$eventsId = 'e880ba39b93d28125e641cbfb6678ff1'
$usersId = '9157ee4977df70f38f6373aab9f049e4'
$userInfoId = '9157ee4977df70f38f6373aab9eca46b'

use Rack::Session::Cookie, :secret => ENV['RACK_COOKIE_SECRET']

use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {}
  provider :facebook, ENV['FACEBOOK_ID'], ENV['FACEBOOK_SECRET'], :scope => 'email,read_stream'
end

before do
  # TODO add admin checks
  unless safe_urls? request.path_info
    unless has_access_token?
      redirect '/login'
    end
  end

  if need_to_be_admin? request.path_info
    unless is_admin?
      redirect '/'
    end
  end
end

get '/' do
  haml :index
end

get '/credit' do
  haml :credit
end

get '/login' do
  haml :login
end

get '/minside' do
  haml :profile, :locals => {:user => get_user, :info => get_user_info(get_uid), :scores => get_scores_for_user(get_uid)}
end

post '/minside' do
  info = get_user_info get_uid
  info["racket"] = params["racket"]
  save_user_info(session[:uid], info)

  redirect '/minside'
end

post '/blimed' do
  eventId = params["id"]
  if params.has_key? "join" then
    add_player_to_event eventId, get_uid, get_user
  elsif params.has_key? "leave" then
    remove_player_from_event eventId, get_uid
  end

  redirect '/'
end

get '/resultater' do
  haml :resultater
end

get '/resultater/:id/remove/:sid' do | id, sid |
  remove_score_from_event id, sid
  redirect '/resultater/' + id
end

get '/resultater/:id' do | id |
  haml :resultat, :locals => { :event => get_event(id), :users => get_users}
end

post '/resultater/:id' do
  id = params["id"]
  # TODO: Add validation
  if params["registration_type"].match "simple" then
    save_simple_score_to_event id, params["player1"], params["player2"], params["winner"]
  else
    save_advance_score_to_event id, params["player1"], params["score1"], params["player2"], params["score2"]
  end

  redirect '/resultater/' + id
end

get '/logout' do
  session.clear
  redirect '/'
end

# admin
get '/admin' do
  haml :admin
end

get '/admin/event/add/:date' do
  date = params[:date]
  if correct_date? date then
    add_event! date
  end

  redirect '/admin'
end

get '/admin/user/:id' do | id |
  user = get_user_by id
  dot = user["dots"] || 0

  if params["dot"].match "inc" then
    dot = dot + 1
  else
    dot = dot - 1
  end

  unless dot < 0 then
    user["dots"] = dot
    update_user user
  end

  redirect '/admin'
end

get '/admin/edit/:id' do | id |
  haml :editEvent, :locals => { :event => get_event(id) }
end

post '/admin/edit/:id' do | id |
  # update event
  event = get_event id
  event["max"] = params[:max].to_i
  date = params[:date]
  
  if correct_date? date then
    event["date"] = convert_date date
  end

  update_event event
  redirect '/admin'
end

get '/admin/edit/:eventId/remove/:uid' do | eventId, uid |
  remove_player_from_event_admin(eventId, uid)
  redirect '/admin/edit/' + eventId
end

get '/admin/delete/:id' do | id |
  haml :deleteEvent, :locals => { :id => id, :date => get_event(id)["date"] }
end

post '/admin/delete/:id' do | id |
  remove_event! id
  redirect '/admin'
end

# Sign in
get '/auth/:provider/callback' do
  content_type 'text/plain'
  begin
    authJson = request.env['omniauth.auth']
    session[:uid] = authJson["uid"]
    session[:access_token] = authJson["credentials"]["token"]
    # save or update user...keep that info fresh!
    authJson["info"]["id"] = authJson["uid"]
    save_user(session[:uid], authJson["info"])
    init_user_info session[:uid]
    session[:user] = authJson["info"] # always use latest
    redirect '/'
  rescue
    p "User was not logged in with request #{request}"
    redirect '/login'
  end
end

get '/auth/failure' do
  content_type 'text/plain'
  begin
    request.env['omniauth.auth'].to_hash.inspect
  rescue
    p "User could not log in with request #{request}"
    redirect '/login'
  end
end

# Errors
not_found do
  haml :"404"
end

error do
  haml :errors
end

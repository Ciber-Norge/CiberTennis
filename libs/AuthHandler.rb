def has_access_token?
  session[:access_token]
end

def safe_urls?(path)
  [
    '/',
    '/credit',
    '/login',
    '/auth/google_oauth2/callback',
    '/auth/facebook/callback',
    '/auth/failure'
  ].include? path
end

def need_to_be_admin?(path)
  path.start_with? '/admin'
end

def is_admin?
  ENV['ADMINS'].split(';').include? session[:uid]
end

def is_logged_in?
  session[:uid]
end

def get_name
  session[:user]["name"] if session[:user]
end

def get_uid
  session[:uid]
end

def get_user
  session[:user]
end

def get_email
  session[:user]["email"] if session[:user]
end

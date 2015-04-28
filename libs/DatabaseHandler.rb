# events
private
def get_events_json_from_cloudant
  JSON.parse(RestClient.get($DB_URL + "/#{$eventsId}"))
end

def get_events_from_cloudant
  get_events_json_from_cloudant["events"]
end

def add_event_to_cloudant(event)
  jdata = get_events_json_from_cloudant
  jdata["events"][event[:id]] = event
  save_to_cloudant(jdata.to_json)
end

def update_event_to_cloudant(event)
  jdata = get_events_json_from_cloudant
  jdata["events"][event["id"]] = event
  save_to_cloudant(jdata.to_json)
end

def remove_event_from_cloudant(id)
  jdata = get_events_json_from_cloudant
  jdata["events"].delete id
  save_to_cloudant(jdata.to_json)
end

#users
private
def get_users_json_from_cloudant
  JSON.parse(RestClient.get($DB_URL + "/#{$usersId}"))
end

def get_users_from_cloudant
  get_users_json_from_cloudant["users"]
end

def get_user_from_cloudant(uid)
  get_users_json_from_cloudant["users"][uid]
end

def save_user_to_cloudant(uid, user)
  jdata = get_users_json_from_cloudant
  jdata["users"][uid] = user
  save_to_cloudant(jdata.to_json)
end

#userinfo
private
def get_users_info_json_from_cloudant
  JSON.parse(RestClient.get($DB_URL + "/#{$userInfoId}"))
end

def get_users_info_from_cloudant
  get_users_info_json_from_cloudant["user_info"]
end

def get_user_info_from_cloudant(uid)
  get_users_info_json_from_cloudant["user_info"][uid]
end

def save_user_info_to_cloudant(uid, user)
  jdata = get_users_info_json_from_cloudant
  jdata["user_info"][uid] = user
  save_to_cloudant(jdata.to_json)
end

private
def save_to_cloudant(json)
  begin
    @respons =  RestClient.post("#{$DB_URL}/", json, {:content_type => :json, :accept => :json})
    if @respons["ok"] then
      p "OK"
    else
      # something bad :\
    end
  rescue => e
    p e.response
    # inform someone
  end
end

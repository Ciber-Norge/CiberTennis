def correct_date?(date)
  date.match(/\d\d\.\d\d\.\d{4}/) if date
end

def get_event(id)
  get_events[id]
end

def add_event!(date)
  date = convert_date(date) unless date.is_a? DateTime
  add_event_to_cloudant(generate_event(date))
end

def convert_date(date)
  DateTime.parse(date + '-18:00', '%d.%m.%Y-%H:%M')
end

def get_events
  # no cach yet
  # store it globally and nil if 
  # it is updated, or just update it?
  events = get_events_from_cloudant
  events.each do | key, value |
    date = value["date"]
    if date then
      value["date"] = DateTime.parse(date)
    end
  end
  events
end

def get_future_events
  now = DateTime.now()
  futureEvents = {}
  events = get_events
  events.each do | key, value |
    if value["date"] >= now then
      futureEvents[key] = value
    end
  end

  futureEvents
end

def remove_event!(id)
  remove_event_from_cloudant id
end

def generate_event(date)
  {
    id: SecureRandom.uuid,
    date: date.to_s,
    max: 9,
    participating: [],
    scores: []
  }
end

def update_event(event)
  update_event_to_cloudant event
end

def add_player_to_event(eventId, uid, info)
  name = info["name"]
  email = info["email"]
  image = info["image"]
  event = get_events[eventId]

  unless event_full? event or registered?(event["participating"], name) then
    event["participating"] << { "name" => name, "id" => uid, "email" => email, "image" => image }
    update_event event
  end
end

def remove_player_from_event_admin(id, uid)
  event = get_events[id]
  event["participating"].delete_if { | value | value["id"].match uid }
  update_event event
end

def remove_player_from_event(id, uid)
  event = get_events[id]

  #unless event_full? event then
    event["participating"].delete_if { | value | value["id"].match uid }
  #end
  
  update_event event
end

def event_full?(event)
  event["participating"].size >= event["max"] if event
end

def registered?(participants, name)
  if name.nil? then return false end
    
  participants.each do | value |
    if value["name"].match name then
      return true
    end
  end

  false
end

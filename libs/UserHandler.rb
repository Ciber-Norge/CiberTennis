def get_user_by(uid)
  get_user_from_cloudant uid
end

def update_user(user)
  save_user_to_cloudant user["id"], user
end

def save_user(uid, user)
  save_user_to_cloudant uid, user
end

def get_users
  get_users_from_cloudant
end

def get_scores_for_user(uid)
  users = get_users
  scores = []
  wins = 0
  get_events.each do | key, event |
    event["scores"].each do | score |
      if score["player1"].match uid or\
        score["player2"].match uid then
        data = {
          "date" => event["date"],
          "p1" => users[score["player1"]]["first_name"],
          "p2" => users[score["player2"]]["first_name"]
        }
        if score.has_key?("winner") then
          data["simple"] = true
          data["winner"] = score["winner"]
          if score["winner"].match("winner1")\
            and score["player1"] == uid then
            wins = wins + 1
          elsif score["winner"].match("winner2")\
            and score["player2"] == uid then
            wins = wins + 1
          end
        else
          data["simple"] = false
          data["s1"] = score["score1"]
          data["s2"] = score["score2"]
          if score["player1"] == uid\
          and score["score1"].to_i > score["score2"].to_i then
            wins = wins + 1
          elsif score["player2"] == uid\
            and score["score1"].to_i < score["score2"].to_i then
            wins = wins + 1
          end
        end
        scores << data
      end
    end
  end
  
  {
    "results" => scores,
    "wins" => wins
  }
end

def get_user_first_name(uid)
  user = get_user_by uid
  user ? user["full_name"] : "ukjent"
end

# info
def init_user_info(uid)
  info = get_user_info_from_cloudant(uid) || add_user_info(uid)
  session[:info] = info
end

def get_user_info(uid)
  session[:info] || get_user_info_from_cloudant(uid)
end

def add_user_info(uid)
  info = {:racket => ""}
  save_user_info_to_cloudant uid, info
  info
end

def save_user_info(uid, info)
  save_user_info_to_cloudant uid, info
end

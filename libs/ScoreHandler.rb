def save_advance_score_to_event(eventId, player1, score1, player2, score2)
  event = get_event(eventId)
  event["scores"] << generate_advance_score(eventId, player1, score1, player2, score2)
  update_event event
end

def save_simple_score_to_event(eventId, player1, player2, winner)
  event = get_event(eventId)
  event["scores"] << generate_simple_score(eventId, player1, player2, winner)
  update_event event
end

private
def generate_advance_score(eventId, player1, score1, player2, score2)
  {
    id: SecureRandom.uuid,
    event: eventId,
    player1: player1,
    score1: score1,
    player2: player2,
    score2: score2
  }
end

private
def generate_simple_score(eventId, player1, player2, winner)
  {
    id: SecureRandom.uuid,
    event: eventId,
    player1: player1,
    player2: player2,
    winner: winner
  }
end

def remove_score_from_event(id, sid)
  event = get_event(id)
  event["scores"].delete_if { | value | value["id"].match sid }
  
  update_event event
end

def calculate_all_scores()
  events = get_events
  scores = {}
  events.each do | key, event |
    event["scores"].each do | score |
      # simple
      if score.has_key? "winner" then
        if score["winner"].match "winner1" then
          if scores.has_key? score["player1"] then
            scores[score["player1"]] = scores[score["player1"]] + 1
          else
            scores[score["player1"]] = 1
          end
        else
          if scores.has_key? score["player2"] then
            scores[score["player2"]] = scores[score["player2"]] + 1
          else
            scores[score["player2"]] = 1
          end
        end
      else
        if score["score1"].to_i > score["score2"].to_i then
          if scores.has_key? score["player1"] then
            scores[score["player1"]] = scores[score["player1"]] + 1
          else
            scores[score["player1"]] = 1
          end
        else
          if scores.has_key? score["player2"] then
            scores[score["player2"]] = scores[score["player2"]] + 1
          else
            scores[score["player2"]] = 1
          end
        end
      end
    end
  end
  scores
end

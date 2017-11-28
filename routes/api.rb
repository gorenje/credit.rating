get '/api/account/:filter/:account_id.json' do
  return_json do
    xcnt, xlookup  = -1,{}
    data = [{ "name" => "Ingoing",  "color" => "green",     "data" => [], },
            { "name" => "Outgoing", "color" => "red",       "data" => [], },
            { "name" => "Total",    "color" => "steelblue", "data" => []  }]

    get_account.
      cluster_transactions_by_month(params[:filter]).
      sort_by { |month,_| month.to_i }.
      each do |month, details|

      xcnt += 1
      xlookup[xcnt] = "%s/%s" % [month[4..6], month[0..3]]

      data[0]["data"] << {
        "x" => xcnt,
        "y" => details["credit"].map(&:to_f).sum.round(2)
      }
      data[1]["data"] << {
        "x" => xcnt,
        "y" => details["debit"].map(&:to_f).sum.round(2)
      }
      data[2]["data"] << {
        "x" => xcnt,
        "y" => details["all"].map(&:to_f).sum.round(2)
      }
    end

    data_point_count = data.map { |d| d["data"].count }.sum

    if (data_point_count == 0)
      { :empty => true }
    else
      values = data.map { |d| d["data"].map { |e| e["y"] }}.flatten
      ymax,ymin = values.max || 0.0, values.min || 0.0
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => ymax > 0 ? ymax + (ymax*0.1) : ymax - (ymax*0.1),
        :ymin    => ymin > 0 ? ymin - (ymin*0.1) : ymin + (ymin*0.1)
      }
    end
  end
end

get '/api/rating/:eid.json' do
  return_json do
    if user = User.find_by_external_id(params[:eid])
      data = [{ "name" => "Rating",  "color" => "green", "data" => [] }]

      xcnt, xlookup, last_rating_history_score  = -1,{},-1
      user.rating_histories.sort_by(&:id).each do |rating|
        xcnt += 1
        xlookup[xcnt] = rating.created_at.to_date
        data[0]["data"] << { "x" => xcnt, "y" => rating.score }
        last_rating_history_score = rating.score
      end

      if last_rating_history_score != user.rating.score
        xcnt += 1
        data[0]["data"] << { "x" => xcnt, "y" => user.rating.score }
        xlookup[xcnt] = user.rating.updated_at.to_date
      end

      values = data.map { |d| d["data"].map { |e| e["y"] || 0 }}.flatten
      ymax,ymin = values.max || 0.0, values.min || 0.0
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => ymax > 0 ? ymax + (ymax*0.1) : ymax - (ymax*0.1),
        :ymin    => ymin > 0 ? ymin - (ymin*0.1) : ymin + (ymin*0.1)
      }
    else
      generate_fake_rating_history_data
    end
  end
end

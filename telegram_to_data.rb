require 'json'
require 'date'
require 'csv'

def getDate(raw)
  Date.parse(raw.split('T').first).strftime('%e %b %Y')
end

filepath = 'result.json'
# chats / list / id: 4647753752 , message[{
     #  "id": 2,
     #  "type": "message",
     #  "date": "2017-11-14T20:42:15",
     #  "edited": "1970-01-01T01:00:00",
     #  "from": "Yuliya Borzylo",
     #  "from_id": 352786456,
     #  "text": "Hey honey"
     # }],

serialized_messages = File.read(filepath)

messages = JSON.parse(serialized_messages)

formalized_data = []
puts "Parsing data and formating it for json"
messages_data = messages["chats"]["list"].select{|a| a["id"] == 4647753752}.first

messages_data["messages"].each do |mess_hash|
  if formalized_data.last.nil? || getDate(mess_hash["date"]) != formalized_data.last[:date]
    if mess_hash["from"] == "Yuliya Borzylo"
      formalized_data << {"date": getDate(mess_hash["date"]), "Yuliya Borzylo": 1, "Pierre-Etienne Soury": 0}
    else
      formalized_data << {"date": getDate(mess_hash["date"]), "Yuliya Borzylo": 0, "Pierre-Etienne Soury": 1}
    end
  else
    if mess_hash["from"] == "Yuliya Borzylo"
      formalized_data.last[:"Yuliya Borzylo"] = formalized_data.last[:"Yuliya Borzylo"] + 1
    else
     formalized_data.last[:"Pierre-Etienne Soury"] = formalized_data.last[:"Pierre-Etienne Soury"] + 1 
    end
  end
end

puts "Writting data in telegram_data.csv for count of messages per day"

csv_options = { col_sep: ',' }

CSV.open("telegram_data.csv", 'wb', csv_options) do |csv|
  csv << ['Date', 'Yuliya Borzylo', 'Pierre-Etienne Soury']
  formalized_data.each do |point|
    csv << [point[:"date"], point[:"Yuliya Borzylo"], point[:"Pierre-Etienne Soury"]]
  end 
end

puts "done!"

poi = formalized_data.first

puts "Computing data per month, to get the count of messages per month per author"

formalized_data_in_months = [{"month": Date.parse(poi[:"date"]).strftime('%b %Y'), "Yuliya Borzylo": poi[:"Yuliya Borzylo"], "Pierre-Etienne Soury": poi[:"Pierre-Etienne Soury"]}]
formalized_data.each do |point| 
  if Date.parse(point[:"date"]).strftime('%b %Y') == formalized_data_in_months.last[:"month"]
    formalized_data_in_months.last[:"Pierre-Etienne Soury"] += point[:"Pierre-Etienne Soury"]
    formalized_data_in_months.last[:"Yuliya Borzylo"] += point[:"Yuliya Borzylo"]
  else
    formalized_data_in_months << {"month": Date.parse(point[:"date"]).strftime('%b %Y'), "Yuliya Borzylo": point[:"Yuliya Borzylo"], "Pierre-Etienne Soury": point[:"Pierre-Etienne Soury"]}
  end
end

puts "Writting data in telegram_data_in_months.csv for count of messages per month"

CSV.open("telegram_data_in_months.csv", 'wb', csv_options) do |csv|
  csv << ['Month', 'Yuliya Borzylo', 'Pierre-Etienne Soury']
  formalized_data_in_months.each do |point|
    csv << [point[:"month"], point[:"Yuliya Borzylo"], point[:"Pierre-Etienne Soury"]]
  end 
end

puts "done!"

# Words analysis

# puts "words analysis: parsing every messages into a big ass string"

# words = ""

# messages_data["messages"].each do |mess_hash|
#   words += mess_hash["text"] + "  \n" if mess_hash["text"].is_a?(String)
# end

the_file='all_messages_telegram.txt'

# File.write(the_file, words)

# puts "done!"


puts "Time for words analysis"

h = Hash.new
f = File.open(the_file, "r")
f.each_line { |line|
  words = line.split
  words.each { |w|
    w.capitalize!
    if h.has_key?(w)
      h[w] = h[w] + 1
    else
      h[w] = 1
    end
  }
}

puts "Writing words_analysis.csv to exploit word analysis"
# sort the hash by value, and then print it in this sorted order
h = h.sort{|a,b| a[1]<=>b[1]}
CSV.open("telegram_words_analysis.csv", 'wb', csv_options) do |csv|
  csv << ['Word', 'Count']
  h.last(100).each do |a, b|
    csv << [a, b] if a.length > 2
  end 
end

puts "done!"



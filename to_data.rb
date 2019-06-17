require 'json'
require 'date'
require 'csv'

filepath = 'message.json'

serialized_messages = File.read(filepath)

messages = JSON.parse(serialized_messages)
# now messages is a very big hash

formalized_data = []
puts "Parsing data and formating it for json"
messages["messages"].each do |mess_hash|
  if formalized_data.last.nil? || Time.at(mess_hash["timestamp_ms"]/1000).strftime('%e %b %Y') != formalized_data.last[:date]
    if mess_hash["sender_name"] == "Yuliya Borzylo"
      formalized_data << {"date": Time.at(mess_hash["timestamp_ms"]/1000).strftime('%e %b %Y'), "Yuliya Borzylo": 1, "Pierre-Etienne Soury": 0}
    else
      formalized_data << {"date": Time.at(mess_hash["timestamp_ms"]/1000).strftime('%e %b %Y'), "Yuliya Borzylo": 0, "Pierre-Etienne Soury": 1}
    end
  else
    if mess_hash["sender_name"] == "Yuliya Borzylo"
      formalized_data.last[:"Yuliya Borzylo"] = formalized_data.last[:"Yuliya Borzylo"] + 1
    else
     formalized_data.last[:"Pierre-Etienne Soury"] = formalized_data.last[:"Pierre-Etienne Soury"] + 1 
    end
  end
end

puts "Writting data in data.json for count of messages per day"

File.open("data.json", 'wb') do |file|
  file.write(JSON.generate(formalized_data))
end


csv_options = { col_sep: ',' }

puts "Writting data in data.csv for count of messages per day"

CSV.open("data.csv", 'wb', csv_options) do |csv|
  csv << ['Date', 'Yuliya Borzylo', 'Pierre-Etienne Soury']
  formalized_data.reverse.each do |point|
    csv << [point[:"date"], point[:"Yuliya Borzylo"], point[:"Pierre-Etienne Soury"]]
  end 
end

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

puts "Writting data in data_in_months.csv for count of messages per month"

CSV.open("data_in_months.csv", 'wb', csv_options) do |csv|
  csv << ['Month', 'Yuliya Borzylo', 'Pierre-Etienne Soury']
  formalized_data_in_months.reverse.each do |point|
    csv << [point[:"month"], point[:"Yuliya Borzylo"], point[:"Pierre-Etienne Soury"]]
  end 
end

# Words analysis

puts "words analysis: parsing every messages into a big ass string"

#words = ""
# messages["messages"].each do |mess_hash|
  #if mess_hash["type"] == "Generic"
  #  words += mess_hash["content"] + "  \n" if mess_hash["content"]
 # end
#end

#File.write("all_messages.txt", words)

#puts "parsing done. Time for words analysis"

the_file='all_messages.txt'
h = Hash.new
f = File.open(the_file, "r")
f.each_line { |line|
  words = line.split
  words.each { |w|
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
CSV.open("words_analysis.csv", 'wb', csv_options) do |csv|
  csv << ['Word', 'Count']
  h.last(100).each do |a, b|
    csv << [a, b] if a.length > 2
  end 
end


















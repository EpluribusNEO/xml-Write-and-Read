if(Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require "rexml/document" #подклбчить XML-парсер
require "date" #для операций с данными

current_path = File.dirname(__FILE__ )
file_name = current_path + "/myfiles/my_expenses.xml"

unless File.exist?(file_name)
  abort "файл не найден!"
end

file = File.new(file_name)
doc = REXML::Document.new(file)

amount_by_day = Hash.new #трата за каждый день
doc.elements.each("expenses/expense") do |item|
  loss_sum = item.attributes["amount"].to_i #Подчерпываем сумму
  loss_date = Date.parse(item.attributes["date"]) #дату

  amount_by_day[loss_date] ||=0 #если значение пустое, присвоить 0
  amount_by_day[loss_date] += loss_sum
end
file.close

sum_by_month = Hash.new
current_month = amount_by_day.keys.sort[0].strftime("%B %Y") #берём первый месяц

amount_by_day.keys.sort.each do |key|
  sum_by_month[key.strftime("%B %Y")] ||=0 # в Руби "a ||= b" эквивалентно "if a == nil  a = b"
  sum_by_month[key.strftime("%B %Y")] +=  amount_by_day[key]
end

#заголовок для первого месяца в списке
puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]}p. }------"

amount_by_day.keys.sort.each do |key|
  if key.strftime("%B %Y") != current_month
    current_month = key.strftime("%B %Y") #переключаемся на нывый месяц
    puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]}p. }------"
  end
  puts "\t#{key.day}: #{amount_by_day[key]}p."
end

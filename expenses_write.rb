if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require 'rexml/document'
require 'date'

puts "На что потрачено?"
expence_text = STDIN.gets.chomp

puts "Сколько потрачено?"
expence_amount = STDIN.gets.chomp.to_i

puts "Укажите дату (ДД.ММ.ГГГГ), пример 27.07.2007. (Пустое поле - сегодня)."
expence_input = STDIN.gets.chomp

expence_date = nil

if expence_input == ''
  expence_date = Date.today #Date.now
else
  expence_date = Date.parse(expence_input)
end

puts "Категория"
expence_category = STDIN.gets.chomp

current_path = File.dirname(__FILE__)
file_name = current_path + "/myfiles/my_expenses.xml"

unless File.exist?(file_name)
  abort "файл не найден!"
end


file = File.new(file_name, "r:UTF-8")
begin
  doc = REXML::Document.new(file)
rescue REXML::ParseException => excep
  puts "Что-то не так с XML файлом:"
  abort excep.message
end

file.close


_expences = doc.elements.find('expenses').first

expence = _expences.add_element('expense', {
    'date' => expence_date.to_s,
    'category' => expence_category,
    'amount' => expence_amount
})

expence.text = expence_text

file = File.new(file_name, "w:UTF-8")
doc.write(file, 2)
file.close

puts "Запись сохранениа)"
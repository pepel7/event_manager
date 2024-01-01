require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require_relative './find_user_info'
include FindUserInfo

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

all_reg_hours = []
all_reg_weekdays = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone = clean_phone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])

  reg_hour = calc_hour(row[:regdate])
  reg_weekday = calc_weekday(row[:regdate])

  all_reg_hours << reg_hour
  all_reg_weekdays << reg_weekday

  puts "#{name}'s phone number is #{phone} and registration date is #{reg_hour} o'clock at #{reg_weekday}."
  
  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id,form_letter)
end

reg_hours_table = calc_reg_per_hours(all_reg_hours)
reg_weekdays_table = calc_reg_per_weekdays(all_reg_weekdays)

puts "Registration per hours: #{reg_hours_table}"
puts "Registration per weekdays: #{reg_weekdays_table}"

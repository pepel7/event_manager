require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone(phone)
  phone.to_s.gsub!(/[^\d]/, '')

  if phone.length == 10 
    phone
  elsif phone.length == 11 && phone[0] == "1"
    phone[1..]
  else
    'Bad phone number'
  end
end

def calc_hour(reg_date)
  Time.strptime(reg_date, "%m/%d/%Y %k:%M").hour
end

def calculate_peak_registration_hours(all_reg_hours)
  result = all_reg_hours.reduce(Hash.new) do |hash, hour|
    hash[hour] ||= 0
    hash[hour] += 1
    hash
  end
  result.sort_by {|k,v| v}.reverse.to_h
end

def calc_weekday(reg_date)
  weekdays = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
  weekday_number = Time.strptime(reg_date, "%m/%d/%Y %k:%M").wday
  weekday = weekdays[weekday_number]
end

def calculate_peak_registration_weekdays(all_reg_weekday)
  result = all_reg_weekday.reduce(Hash.new) do |hash, weekday|
    hash[weekday] ||= 0
    hash[weekday] += 1
    hash
  end
  result.sort_by {|k,v| v}.reverse.to_h
end


def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

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

  registration_hour = calc_hour(row[:regdate])
  registration_weekday = calc_weekday(row[:regdate])

  all_reg_hours << registration_hour
  all_reg_weekdays << registration_weekday

  puts "#{name}'s phone number is #{phone} and registration date is #{registration_hour} o'clock at #{registration_weekday}."
  
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end

puts peak_hours = calculate_peak_registration_hours(all_reg_hours)
puts peak_weekdays = calculate_peak_registration_weekdays(all_reg_weekdays)
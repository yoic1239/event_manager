require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

# Assignment: Clean phone numbers
def clean_phone_numbers(phone_num)
  cleaned_num = phone_num.gsub(/\D/, '')

  cleaned_num = cleaned_num[1..] if cleaned_num.length == 11 && cleaned_num[0] == '1'

  cleaned_num.length == 10 ? cleaned_num : ''
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

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

# Assignment: Time targeting
def fetch_reg_hour(time)
  Time.strptime(time, '%D %R').hour
end

def peak_hour(hour_arr)
  hour_arr.tally.select { |hour, count| count == hour_arr.tally.values.max }.keys.map { |hr| "#{hr}:00" }
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

# Assignment: Time targeting
reg_hour = []

contents.each do |row|
  # id = row[0]
  # name = row[:first_name]
  # zipcode = clean_zipcode(row[:zipcode])
  # phone_num = clean_phone_numbers(row[:homephone])

  # legislators = legislators_by_zipcode(zipcode)

  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)

  # # Assignment: Clean phone numbers
  # puts "#{name} can sign up for mobile alerts for his number #{phone_num}" if phone_num != ''

  # Assignment: Time targeting
  reg_hour.push(fetch_reg_hour(row[:regdate]))
end

# Assignment: Time targeting
puts "The peak registration hours are #{peak_hour(reg_hour).join(', ')}."

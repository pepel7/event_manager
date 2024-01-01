module FindUserInfo
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
  
  def calc_reg_per_hours(all_reg_hours)
    result = all_reg_hours.reduce(Hash.new(0)) do |hash, hour|
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
  
  def calc_reg_per_weekdays(all_reg_weekday)
    result = all_reg_weekday.reduce(Hash.new(0)) do |hash, weekday|
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
end
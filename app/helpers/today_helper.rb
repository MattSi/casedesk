module TodayHelper
  def greeting(now)
    case now.hour
    when 5...12 then "Good morning"
    when 12...18 then "Good afternoon"
    else "Good evening"
    end
  end
end

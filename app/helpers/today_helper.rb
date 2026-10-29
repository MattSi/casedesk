module TodayHelper
  def greeting(now)
    case now.hour
    when 5...12 then "Good morning"
    when 12...18 then "Good afternoon"
    else "Good evening"
    end
  end


  def day_label(date, today)
    case date
    when today then "Today"
    when today.tomorrow then "Tomorrow"
    else date.strftime("%A, %B %-d")
    end
  end
end

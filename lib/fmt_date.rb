def ordinalize_num(num)
  if (11..13).include?(num % 100)
    "#{num}th"
  else
    case num % 10
    when 1 then "#{num}st"
    when 2 then "#{num}nd"
    when 3 then "#{num}rd"
    else "#{num}th"
    end
  end
end

def fmt_date(date)
  date.strftime('%B %Y')
end

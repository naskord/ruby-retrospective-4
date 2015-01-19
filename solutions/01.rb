def series(series_name, number)
  case series_name
  when 'fibonacci' then find_series_element(1, 1, number)
  when 'lucas'     then find_series_element(2, 1, number)
  else                  find_series_element(3, 2, number)
  end
end


def find_series_element(first, second, number)
  if    number == 1 then first
  elsif number == 2 then second
  else  find_series_element(second, first + second, number - 1)
  end
end

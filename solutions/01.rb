def series(series_name, number)
  if series_name == 'fibonacci' then find_series_element(1, 1, number)
  elsif series_name == 'lucas' then find_series_element(2, 1, number)
  else
    find_series_element(1, 1, number) + find_series_element(2, 1, number)
  end
end


def find_series_element(first, second, number)
  if number == 1 then first
  elsif number == 2 then second
  else
    find_series_element(second, first + second, number - 1)
  end
end

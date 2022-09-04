function rate =  rate_of_change(data, time)
    rate = gradient(data(:)) ./ gradient(time(:));
end
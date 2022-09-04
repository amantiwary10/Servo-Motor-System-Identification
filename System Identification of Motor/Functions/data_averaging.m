function out_data = data_averaging(data, field)
    out_data = [];
    for i = 1:length(data.PW_Keys)
        id = index_extraction(data.pulse_width, data.PW_Keys(i));
        out_data = [out_data; mean(field(id))];
    end

end
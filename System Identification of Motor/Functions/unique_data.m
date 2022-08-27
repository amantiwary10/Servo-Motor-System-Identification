% Function to find unique values from a data set
function unique = unique_data(data)

unique = [];
count = length(data);
j = 1;

for i = 1:count
    if ~ismember(data(i), unique)
        unique(j) = data(i);
        j = j + 1;
    end
end
end
%Skye
%reference tracking trajectory generator

function ref = r(t)
    x = (t/10)*cos(t);
    y = (t/10)*sin(t);
    theta = 0;
    ref = [x; y; theta];
end
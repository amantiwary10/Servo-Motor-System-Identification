%Skye
%reference tracking trajectory generator

function ref = r_mod2(t)
    x = 5*t;
    y = log(t);
    theta = 0.05*sin(t);
    
    ref = [x; y; theta];
end
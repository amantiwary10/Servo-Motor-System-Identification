%Skye
%reference tracking trajectory generator

function ref = r_mod(t)
    tf = 10; %final time
    tCh = tf/2; %time of reference signal change
    xCh = (tCh/10)*cos(tCh); yCh = (tCh/10)*sin(tCh);
    mx = xCh/(tCh-tf); my = yCh/(tCh-tf);
    if t <= tCh
        x = (t/10)*cos(t);
        y = (t/10)*sin(t);
        theta = 0;
    else
        x = mx*t + xCh;
        y = my*t + yCh;
        theta = 0;
    end
        ref = [x; y; theta];
end
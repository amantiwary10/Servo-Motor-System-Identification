clear all, close all, clc

tVec = 0:.1:25;

for i = 1:length(tVec)
    trj(:,i) = r_mod2(tVec(i));
end

x = trj(1,:); y = trj(2,:); theta = trj(3,:);

figure
plot(x,y)
title('x vs. y')

%figure
%plot(tVec,theta)
%title('theta vs time ')
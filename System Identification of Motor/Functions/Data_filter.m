function [pwm_new, motor_rpm_new] = Data_filter(pwm, motor_rpm, time)
%% Data Processing
% The region of interest lies in  [1100, 1400] and [1500, 1800]
% Thus resetting the upper and lower limits of the PWM Signal to make a continuous plot

pwm_ = pwm;
motor_rpm_ = motor_rpm;
time_ = time;

% Filtering data in [1100, 1400] and [1500, 1800]
[len_time, ~] = size(time_);
pwm_dummy = [];
motor_rpm_dummy = [];

for i = 1:len_time
    if (pwm_(i)>= 1100 && pwm_(i) <= 1400)
        pwm_dummy(end+1) = pwm_(i) - 1400;     % Clockwise rotation pwm_new[-300, 0]
        motor_rpm_dummy(end+1) = motor_rpm_(i);
    elseif (pwm_(i)>= 1500 && pwm_(i) <= 1800) 
        pwm_dummy(end+1) = pwm_(i) - 1500;     % Anticlockwise rotation pwm_new[0, 300]
        motor_rpm_dummy(end+1) = motor_rpm_(i);
    end
    
end
pwm_new = pwm_dummy';
motor_rpm_new = motor_rpm_dummy';

%% Plotting the filtered data
figure(4)
plot(pwm_new, motor_rpm_new)
hold on
plot(zeros(size(pwm_new)), motor_rpm_new, '--k')
xlabel('PWM')
ylabel('Motor RPM')
hold off
end

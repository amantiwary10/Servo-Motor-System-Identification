clear all
close all
clc
%% Data Pre-Processing

% Collecting RPM readings taken by the app
[RPM_ramp, time_ramp, count_ramp] = readvars('RPM_data.csv');

% Collecting the readings taken by the board
Time_2_ramp = readvars('StepsTest_clock_run1_2022-05-17_215353.csv', 'Range', 'A2:A618');
pwm_ramp = readvars('StepsTest_clock_run1_2022-05-17_215353.csv', 'Range', 'E2:E618');
motor_rpm_ramp = zeros(size(Time_2_ramp));

[len_Time_2, dum] = size(Time_2_ramp);
[len_time, dumm] = size(time_ramp);

%% Interpolation to map motor rpm to PWM signals
for i = 1:len_Time_2
    for j = 1:len_time
        if Time_2_ramp(i) >= time_ramp(j) && Time_2_ramp(i) <= time_ramp(j+1)
            if pwm_ramp(i) < 1410
                motor_rpm_ramp(i) = (RPM_ramp(j+1) - RPM_ramp(j))/(time_ramp(j+1) - time_ramp(j)) * (Time_2_ramp(i) - time_ramp(j)) + RPM_ramp(j);
            else
                motor_rpm_ramp(i) = -((RPM_ramp(j+1) - RPM_ramp(j))/(time_ramp(j+1) - time_ramp(j)) * (Time_2_ramp(i) - time_ramp(j)) + RPM_ramp(j));
            end
        end
     end
end

%writematrix(motor_rpm, 'RPM_data.csv', 'Range', 'D2:D618')

%% Plotting
figure(1)
plot(pwm_ramp(1:51), motor_rpm_ramp(1:51))
hold on
plot(1100*ones(size(pwm_ramp(1:51))), motor_rpm_ramp(1:51), '-r')
xlabel('pwm')
ylabel('Motor RPM')

figure(2)
plot(Time_2_ramp, motor_rpm_ramp)
xlabel('time')
ylabel('Motor RPM')

figure(3)
plot(Time_2_ramp, pwm_ramp)
xlabel('time')
ylabel('PWM')
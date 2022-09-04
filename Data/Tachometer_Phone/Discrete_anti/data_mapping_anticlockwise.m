function [pwm_anti, motor_rpm_anti, time_anti, current_step_anti, di_dt] = data_mapping_anticlockwise()

%% Data Processing

% Collecting RPM Readings from the app
[RPM_step_anti, time_step_anti, ~] = readvars('discrete_anticlock_run1_rpm.csv');

% Collecting the readings taken by the board
Time_2_step_anti = readvars('StepsTest_anticlock_run1_2022-05-18_005801.csv', 'Range', 'A2:A618');
pwm_step_anti = readvars('StepsTest_anticlock_run1_2022-05-18_005801.csv', 'Range', 'E2:E618');
current_step_anti = readvars('StepsTest_anticlock_run1_2022-05-18_005801.csv', 'Range', 'L2:L618');
di_dt = rate_of_change(current_step_anti, Time_2_step_anti);
motor_rpm_step_anti = zeros(size(Time_2_step_anti));

[len_Time_2, ~] = size(Time_2_step_anti);
[len_time, ~] = size(time_step_anti);

%% Interpolation to map motor rpm to PWM signals
for i = 1:len_Time_2
    flag_A = 1;
    for j = 2:len_time
        flag_B = 1;
        if Time_2_step_anti(i) >= time_step_anti(j) && Time_2_step_anti(i) <= time_step_anti(j+1)
            if pwm_step_anti(i) < 1410
                motor_rpm_step_anti(i) = (RPM_step_anti(j+1) - RPM_step_anti(j-1))/(time_step_anti(j+1) - time_step_anti(j-1)) * (Time_2_step_anti(i) - time_step_anti(j)) + RPM_step_anti(j);
            else
                motor_rpm_step_anti(i) = -((RPM_step_anti(j+1) - RPM_step_anti(j))/(time_step_anti(j+1) - time_step_anti(j)) * (Time_2_step_anti(i) - time_step_anti(j)) + RPM_step_anti(j));
            end
        end
     end
end

%writematrix(motor_rpm, 'RPM_data.csv', 'Range', 'D2:D618')
% taking the data from the second run

pwm_anti = pwm_step_anti;
motor_rpm_anti = motor_rpm_step_anti;
time_anti = Time_2_step_anti;

%% Plotting
figure(1)
plot(pwm_anti, motor_rpm_anti)
hold on
plot(1490*ones(size(pwm_anti)), motor_rpm_anti, '-r')
plot(1800*ones(size(pwm_anti)), motor_rpm_anti, '-r')
xlabel('pwm')
ylabel('Motor RPM')

figure(2)
plot(Time_2_step_anti, motor_rpm_step_anti)
xlabel('time')
ylabel('Motor RPM')

figure(3)
plot(Time_2_step_anti, pwm_step_anti)
xlabel('time')
ylabel('PWM')

end

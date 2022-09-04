function [pwm_clock, motor_rpm_clock, time_clock, current_clock, di_dt] = data_mapping_discrete_clock()
%% Data Pre-Processing

% Collecting RPM readings taken by the app
[RPM, time, ~] = readvars('discrete_clock_run1_rpm.csv');

% Collecting the readings taken by the board
Time_2_clock = readvars('StepsTest_clock_run1_2022-05-17_215353.csv', 'Range', 'A2:A618');
pwm = readvars('StepsTest_clock_run1_2022-05-17_215353.csv', 'Range', 'E2:E618');
current_clock = readvars('StepsTest_clock_run1_2022-05-17_215353.csv', 'Range', 'L2:L618');
di_dt =  rate_of_change(current_clock,Time_2_clock);
motor_rpm = zeros(size(Time_2_clock));

[len_Time_2, ~] = size(Time_2_clock);
[len_time, ~] = size(time);

%% Interpolation to map motor rpm to PWM signals
for i = 1:len_Time_2
    for j = 1:len_time
        if Time_2_clock(i) >= time(j) && Time_2_clock(i) <= time(j+1)
            if pwm(i) < 1410
                motor_rpm(i) = (RPM(j+1) - RPM(j))/(time(j+1) - time(j)) * (Time_2_clock(i) - time(j)) + RPM(j);
            else
                motor_rpm(i) = -((RPM(j+1) - RPM(j))/(time(j+1) - time(j)) * (Time_2_clock(i) - time(j)) + RPM(j));
            end
        end
     end
end

%writematrix(motor_rpm, 'RPM_data.csv', 'Range', 'D2:D618')
pwm_clock = pwm;
motor_rpm_clock = motor_rpm;
time_clock = Time_2_clock;
%% Plotting
figure(1)
plot(pwm_clock, motor_rpm_clock)
hold on
plot(1100*ones(size(pwm_clock)), motor_rpm_clock, '-r')
xlabel('pwm')
ylabel('Motor RPM')

figure(2)
plot(Time_2_clock, motor_rpm)
xlabel('time')
ylabel('Motor RPM')

figure(3)
plot(Time_2_clock, pwm)
xlabel('time')
ylabel('PWM')

%step(pwm)
end
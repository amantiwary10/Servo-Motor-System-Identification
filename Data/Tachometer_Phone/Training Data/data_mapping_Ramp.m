function [pwm_ramp_2, motor_rpm_ramp_2, time_ramp_2] = data_mapping_Ramp()
%% Data Pre-Processing

% Collecting RPM readings taken by the app
[RPM_ramp, time_ramp, ~] = readvars('/media/aman/Windows8_OS/Users/User/Downloads/ACL/Data/Training Data/RPM_data.csv');

% Collecting the readings taken by the board
Time_2_ramp = readvars('/media/aman/Windows8_OS/Users/User/Downloads/ACL/Data/Training Data/RampTest_1.csv', 'Range', 'A2:A19138');
pwm_ramp = readvars('/media/aman/Windows8_OS/Users/User/Downloads/ACL/Data/Training Data/RampTest_1.csv', 'Range', 'E2:E19138');
motor_rpm_ramp = zeros(size(Time_2_ramp));

[len_Time_2, ~] = size(Time_2_ramp);
[len_time, ~] = size(time_ramp);

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
% taking the data from the second run
pwm_ramp_2 = pwm_ramp .* (1e-6 * 50) * 100 ;        % caculating duty cycle
% duty_cycle = Pulse width * Signal Frequency * 100%
motor_rpm_ramp_2 = motor_rpm_ramp;
time_ramp_2 = Time_2_ramp;
 
%% Plotting
figure(1)
plot(pwm_ramp(339:617), motor_rpm_ramp(339:617))
hold on
plot(1100*ones(size(pwm_ramp_2)), motor_rpm_ramp_2, '-r')
plot(1800*ones(size(pwm_ramp_2)), motor_rpm_ramp_2, '-r')
plot(1410*ones(size(pwm_ramp_2)), motor_rpm_ramp_2, '-k')
plot(1490*ones(size(pwm_ramp_2)), motor_rpm_ramp_2, '-k')

xlabel('pwm')
ylabel('Motor RPM')
hold off

figure(2)
plot(Time_2_ramp, motor_rpm_ramp)
xlabel('time')
ylabel('Motor RPM')

figure(3)
plot(Time_2_ramp, pwm_ramp)
xlabel('time')
ylabel('PWM')

end

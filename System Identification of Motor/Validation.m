clear all
close all
clc

%% Data Extraction for Validation
% Pulse_Width_anti = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Anti-Clock/Training/*.csv', ...
%     'Range', 'E2:E969');
% 
% Motor_RPM_anti = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Anti-Clock/Training/*.csv', ...
%     'Range', 'N2:N969');

Pulse_Width_clock = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Clock/Training/StepsTest_2022-09-23_092153.csv', ...
    'Range', 'E2:E969');

Motor_RPM_clock = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Clock/Training/StepsTest_2022-09-23_092153.csv', ...
    'Range', 'N2:N969');

%% PLots
plot(Pulse_Width_anti, Motor_RPM_anti)
%% Validation for anti-clock
Predicted_RPM_anti = [];
motor_rpm_anti = [];
PW_anti = [];
j = 1;
counter = 1;
for i = transpose(Pulse_Width_anti)
    if i >= 1450
        motor_rpm_anti(j) = -1 * Motor_RPM_anti(counter);
        PW_anti(j) = i;
        Predicted_RPM_anti(j) = (56.6075741/(1 + exp(0.0356323011 * (i - 1533.38050)))) - 51.2946944;
        j = j + 1;
    end
    counter = counter + 1;
end

%% Validation for clock

Predicted_RPM_clock = [];
motor_rpm_clock = [];
PW_clock = [];
j = 1;
counter = 1;
for i = transpose(Pulse_Width_clock)
    if i <=1450
        motor_rpm_clock(j) = Motor_RPM_clock(counter);
        PW_clock(j) = i;
        Predicted_RPM_clock(j) = (-52.5881734 / (1 + exp(-0.0402144660 * (i - 1325.03527)))) + 50.3756412;
        j = j + 1;
    end
    counter = counter + 1;
end
%% Plots Anti
figure(1)
plot(PW_anti, Predicted_RPM_anti, "k", "LineWidth",2)
hold on
plot(PW_anti, motor_rpm_anti, "-y")
hold off
%% Plots clock
figure(2)
plot(PW_clock, Predicted_RPM_clock, "k", "LineWidth",2)
hold on
plot(PW_clock, motor_rpm_clock, "-y")
hold off

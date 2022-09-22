clear all
close all
clc

%% Data Extraction for Validation
Pulse_Width_anti = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Data_20_Aug/StepsTest_anticlock_run1_2022-08-21_162408_usable.csv', ...
    'Range', 'E2:E969');

Motor_RPM_anti = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Data_20_Aug/StepsTest_anticlock_run1_2022-08-21_162408_usable.csv', ...
    'Range', 'N2:N969');

Pulse_Width_anti2 = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Data_20_Aug/StepsTest_anticlock_run1_2022-08-21_173354_usable.csv', ...
    'Range', 'E2:E969');

Motor_RPM_anti2 = readvars('/home/aman/ACL/Servo-Motor-System-Identification/Data/Optical Probe/Data_20_Aug/StepsTest_anticlock_run1_2022-08-21_173354_usable.csv', ...
    'Range', 'N2:N969');

%% PLots
plot(Pulse_Width_anti, Motor_RPM_anti)
%% Validation
Predicted_RPM = [];
Motor_RPM = [];
PW = [];
j = 1;
counter = 1;
for i = transpose(Pulse_Width_anti2)
    if i >= 1500
        Motor_RPM(j) = -1 * Motor_RPM_anti2(counter);
        PW(j) = i;
        Predicted_RPM(j) = (58.3152416/(1 + exp(0.0317348137 * (i - 1538.67135)))) - 52.1035066;
        j = j + 1;
    end
    counter = counter + 1;
end

%% Plots
figure(1)
plot(PW, Predicted_RPM, "k", "LineWidth",2)
hold on
plot(PW, Motor_RPM, "-b")
hold off
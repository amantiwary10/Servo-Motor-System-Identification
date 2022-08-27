clc
clear all
close all
%% Data Processing

data = struct('Ramp', [], 'clock', [], );

% 1. Anticlockwise
[pwm, motor_rpm, time] = data_mapping_Ramp();

% 2. Clockwise
%[pwm, motor_rpm, time] = data_mapping_discrete_clock();

%[pwm_f, motor_rpm_f] = Data_filter(pwm, motor_rpm, time);
plot(pwm, motor_rpm)
hold on
%plot(zeros(size(pwm)), motor_rpm_new, '--k')
xlabel('PWM')
ylabel('Motor RPM')
hold off
%data_Validation = iddata(motor_rpm_f, pwm_f);

%% Combining Data set
Training_set = struct("PWM_Keys", []);
Training_set.PWM_Keys = reshape(sort(unique_data(pwm)), [], 1);
Training_set.("PWM") = pwm;

  %% Comparison
T_F_f = sys_id()
disp(T_F_f)
figure(6)
compare(data_Validation, T_F_f)
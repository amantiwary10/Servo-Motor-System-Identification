function T_f_2 = sys_id()
%% Getting Data
[pwm, motor_rpm, time] = data_mapping_discrete_clock();

%% System identification with Noisy data
[pwm_f, motor_rpm_f] = Data_filter(pwm, motor_rpm, time);
data_1 = iddata(motor_rpm_f, pwm_f);
T_f_1 = tfest(data_1, 1, 0)
T_f_2 = tfest(data_1, 2, 0)
T_f_3 = tfest(data_1, 2, 1)
T_f_4 = tfest(data_1, 2, 2)
T_f_5 = tfest(data_1, 3, 1)
T_f_6 = tfest(data_1, 3, 2)

figure(5)
% compare(data_1, T_f_1)

% 
compare(data_1, T_f_2)
% 
%compare(data_1, T_f_3)
% 
%compare(data_1, T_f_4)
% 
%compare(data_1, T_f_5)

%compare(data_1, T_f_6)

end
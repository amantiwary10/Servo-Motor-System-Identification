clc
clear all
close all
%% Data Processing

data = struct('Ramp', [], 'clock', [], 'anti_clock', []);

% 1. Ramp
[data.Ramp.('pulse_width'), data.Ramp.('motor_rpm'), data.Ramp.('time'), data.Ramp.('current'), data.Ramp.('di_dt')] = data_mapping_Ramp();

% 2. Anticlockwise
[data.anti_clock.('pulse_width'), data.anti_clock.('motor_rpm'), data.anti_clock.('time'), data.anti_clock.('current'), data.anti_clock.('di_dt')] = data_mapping_anticlockwise();

% 3. Clockwise
[data.clock.('pulse_width'), data.clock.('motor_rpm'), data.clock.('time'), data.clock.('current'), data.clock.('di_dt')] = data_mapping_discrete_clock();

% Finding Unique Keys
data.Ramp.('PW_Keys') = reshape(sort(unique_data(data.Ramp.pulse_width)), [], 1);
data.clock.('PW_Keys') = reshape(sort(unique_data(data.clock.pulse_width)), [], 1);
data.anti_clock.('PW_Keys') = reshape(sort(unique_data(data.anti_clock.pulse_width)), [], 1);

%% Combining Data set
Training_set = struct("Anti_clock", [], "Clock", []);
Training_set.Anti_clock.("Unique_PW_Keys") = [];
dummy_anti = [];
dummy_clock = [];
dummy_anti_keys = [];
dummy_clock_keys = [];
for i = 1:length(data.Ramp.PW_Keys)
    if data.Ramp.PW_Keys(i) > 1500 && data.Ramp.PW_Keys(i) < 1900
        dummy_anti = [dummy_anti ; data.Ramp.PW_Keys(i)];
    elseif data.Ramp.PW_Keys(i) < 1400 && data.Ramp.PW_Keys(i) > 1000
        dummy_clock = [dummy_clock ; data.Ramp.PW_Keys(i)];
    end
end

for i = 1:length(data.anti_clock.PW_Keys)
    if data.anti_clock.PW_Keys(i) > 1500 && data.anti_clock.PW_Keys(i) < 1900  
        dummy_anti_keys = [dummy_anti_keys; data.anti_clock.PW_Keys(i)];
    end
end

for i = 1:length(data.clock.PW_Keys)
    if data.clock.PW_Keys(i) < 1400 && data.clock.PW_Keys(i) > 1000 
        dummy_clock_keys = [dummy_clock_keys; data.clock.PW_Keys(i)];
    end
end

Training_set.Anti_clock.Unique_PW_Keys = union(dummy_anti, dummy_anti_keys);
Training_set.Clock.Unique_PW_Keys = union(dummy_clock, dummy_clock_keys);


%% Using the PW_keys to average the RPM
% Anticlock

Training_set.Anti_clock.("motor_rpm") = [];
for i = 1: length(Training_set.Anti_clock.Unique_PW_Keys)

    id_ramp_anti = index_extraction(data.Ramp.pulse_width, Training_set.Anti_clock.Unique_PW_Keys(i));
    id_anti = index_extraction(data.anti_clock.pulse_width, Training_set.Anti_clock.Unique_PW_Keys(i));
    Training_set.Anti_clock.motor_rpm = [Training_set.Anti_clock.motor_rpm; mean([data.Ramp.motor_rpm(id_ramp_anti); data.anti_clock.motor_rpm(id_anti)])];

end
% duty_cycle = Pulse width * Signal Frequency * 100%
Training_set.Anti_clock.("PW_adj") = (Training_set.Anti_clock.Unique_PW_Keys - 1463 .* ones(202, 1));
%% Using the PW_keys to average the RPM
% Clock

Training_set.Clock.("motor_rpm") = [];
for i = 1: length(Training_set.Clock.Unique_PW_Keys)

    id_ramp_clock = index_extraction(data.Ramp.pulse_width, Training_set.Clock.Unique_PW_Keys(i));
    id_clock = index_extraction(data.clock.pulse_width, Training_set.Clock.Unique_PW_Keys(i));
    Training_set.Clock.motor_rpm = [Training_set.Clock.motor_rpm; mean([data.Ramp.motor_rpm(id_ramp_clock); data.clock.motor_rpm(id_clock)])];

end
% duty_cycle = Pulse width * Signal Frequency * 100%
Training_set.Clock.("PW_adj") = (Training_set.Clock.Unique_PW_Keys - 1463 .* ones(202, 1)) ;

%% Plots
%scatter(data.Ramp.pulse_width, data.Ramp.motor_rpm, ones(length(data.Ramp.pulse_width), 1))
hold on
%plot(data.Ramp.PW_Keys, X_clean, "-m")
%scatter(data.clock.pulse_width, data.clock.motor_rpm, ones(length(data.clock.pulse_width), 1), 'k')
%scatter(data.anti_clock.pulse_width, data.anti_clock.motor_rpm, ones(length(data.anti_clock.pulse_width), 1), 'k')
plot(Training_set.Anti_clock.Unique_PW_Keys, Training_set.Anti_clock.motor_rpm, "-k")
plot(Training_set.Clock.Unique_PW_Keys, Training_set.Clock.motor_rpm, "-m")
xlabel('PWM')
ylabel('Motor RPM')
hold off
%data_Validation = iddata(motor_rpm_f, pwm_f)
%% 
figure(1)
plot(Training_set.Anti_clock.Voltage, Training_set.Anti_clock.motor_rpm)
hold on
plot(Training_set.Clock.Voltage, Training_set.Clock.motor_rpm)
hold off
xlabel("Voltage")
ylabel("Motor RPM")
%% Transfer Function Estimate
data_anticlock = iddata(Training_set.Anti_clock.motor_rpm, Training_set.Anti_clock.Voltage);
T_f_anticlock = tfest(data_anticlock, 2, 0);

data_clock = iddata(Training_set.Clock.motor_rpm, Training_set.Clock.Voltage);
T_f_clock = tfest(data_clock, 2, 0);

%% Compare
figure(1)
compare(data_anticlock, T_f_anticlock)

figure(2)
compare(data_clock, T_f_clock)
%Skye Mceowen
%ACL 2018-2019 - April 25, 2019
%Rover Kinematic Model - ODE 45 simulation
%Continuous control

clear all, close all, clc

%setting up variables (change things here)
    delta = 0.1; %time step
    steps = 100; %number of time steps
    times = delta*(1:1:steps)'; %vector of times you're simulating
    IC = zeros(12,1); %initial condition
    s = tf('s'); %ignore
    
    %controller tuning:
    Kp = 1; Ki = 1; Kd = 1; tau_d = 1; %bw of differentiator
    
    %trajectory generator
    ref_handle = @r; %change this to you reference handle

%setting up actuator state space model
    f_A = 1; %bandwidth of the actuator in Hz
    A = tf([0 2*pi*f_A],[1 2*pi*f_A]); %actuator filter transfer function
    A_ss = ss(A); %state space model of actuator transfer function

%setting up controller state space model
    Cx = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d)); %C(s) design (TF), x
    Cy = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d)); % " y
    Ct = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d)); % " theta

    Cx_ss = ss(Cx); %C(s) design (State Space), x
    Cy_ss = ss(Cy); % " y
    Ct_ss = ss(Ct); % " theta               
    
%creating reference signal
    for k = 1:times(end)/delta
        ref(:,k) = ref_handle(times(k));
        x_ref(1,k) = ref(1,k);
        y_ref(1,k) = ref(2,k);
        theta_ref(1,k) = ref(3,k);
    end

%calling continuous derivative function in ODE45
    [~,state] = ode45(@(t,x) derivs_c(t,x,Cx_ss,Cy_ss,Ct_ss,A_ss,ref_handle),times,IC);
    state = state';
%Determine indices for plotting
    n_Cx = length(Cx_ss.A) %length of x control state
    n_Cy = length(Cy_ss.A) %length of y control state
    n_Ct = length(Ct_ss.A) %length of theta control state
    n_A = length(A_ss.A)   %length of actuator state
    n_P = 3                %plant state vector (x,y,theta)

    i_x_Cx = (1:n_Cx);              %x control indices
    i_x_Cy = (1:n_Cy)+i_x_Cx(end);  %y control indices
    i_x_Ct = (1:n_Ct)+i_x_Cy(end);  %theta control indices
    i_x_A1 = (1:n_A)+i_x_Ct(end);   %actuator 1 state indices
    i_x_A2 = (1:n_A)+i_x_A1(end);   %actuator 2 state indices
    i_x_A3 = (1:n_A)+i_x_A2(end);   %actuator 3 state indices
    i_x_P = (1:n_P)+i_x_A3(end);    %plant state indices
    
    
    x_Cx = state(i_x_Cx,:);   %extracting x-control state vector
    x_Cy = state(i_x_Cy,:);   %extracting y-control state vector
    x_Ct = state(i_x_Ct,:);   %extracting theta-control state vector

    x_A1 = state(i_x_A1,:);   %extracting actuator 1 state vector
    x_A2 = state(i_x_A2,:);   %extracting actuator 2 state vector
    x_A3 = state(i_x_A3,:);   %extracting actuator 3 state vector

    x_P = state(i_x_P,:); x = x_P(1,:); y = x_P(2,:); theta = x_P(3,:);
    
%plotting
    figure
    plot(times,x_P-ref)
    title('Error vs. Time')
    xlabel('Time [s]')
    ylabel('Error')
    legend('e_x','e_y','e_{\theta}')
    ylim([-5 5])

    figure
    plot(x,y,x_ref,y_ref)
    title('x vs. y')
    xlabel('x [m]')
    ylabel('y [m]')
    legend('Rover Trj','Reference Signal')
    
    figure
    plot(times,x,times,y,times,x_ref,times,y_ref)
    title('(x,y) Position vs. Time')
    xlabel('Time [s]')
    ylabel('x,y [m]')
    legend('Rover x Trj','Rover y Trj','x Reference Signal','y Reference Signal')

    figure
    plot(times,theta,times,theta_ref)
    title('Theta vs. Time')
    xlabel('Time [s]')
    ylabel('Theta [rad]')
    legend('Rover Trj','Reference Signal')
    ylim([-5 5])
    

    figure
    plot(times,x_Cx,times,x_Cy,times,x_Ct)
    title('Control Input vs. Time')
    xlabel('Time [s]')
    ylabel('Control Input [m/s] or [rad/s]')
    legend('x1','x2','y1','y2','t1','t2')
    
    figure
    plot(times,x_A1,times,x_A2,times,x_A3)
    title('Actuator Response vs. Time')
    xlabel('Time [s]')
    ylabel('Actuator Response')
    legend('Actuator 1','Actuator 2','Actuator 3')
    %}
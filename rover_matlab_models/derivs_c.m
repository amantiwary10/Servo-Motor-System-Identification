                                                                                                                                                                                                                                           %Skye Mceowen
%ACL 2018-2019 - April 25, 2019
%Rover Kinematic Model - Continuous Control
%Contains everything from reference to control input, actuator dynamics and output

%Testing
%{
clear all, close all, clc
time = 1;
state = zeros(12,1);
s = tf('s');

f_A = 1; %bandwidth of the actuator in Hz
A = tf([0 2*pi*f_A],[1 2*pi*f_A]); %actuator filter transfer function
A_ss = ss(A);

Kp = 5; Ki = 0.5; Kd = 1; tau_d = 0.01; %bw of differentiator

Cx = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d));
Cy = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d));
Ct = Kp + Ki/s + Kd*s*(1/tau_d)/(s+(1/tau_d));

Cx_ss = ss(Cx);
Cy_ss = ss(Cy);
Ct_ss = ss(Ct);
%}


function f_x = derivs_c(time,state,Cx_ss,Cy_ss,Ct_ss,A_ss,ref_handle)
    %Future: might want to pass in reference signal function handle %r(t)
    %NOTE: f_x is a vector with: [xcDot; xaDot; xpDot]'
            %where  xc contains controller dynamics
                %   xa contains actuator dynamics
                %   xp contains plant dynamics
    
    if nargin == 6
       ref_handle = @r; 
    end
    
    %extract dyanmics (state is a single vector)
        %determining appropriate state lengths and corresponding indices
        n_Cx = length(Cx_ss.A); %length of x control state
        n_Cy = length(Cy_ss.A); %length of y control state
        n_Ct = length(Ct_ss.A); %length of theta control state
        n_A = length(A_ss.A);   %length of actuator state
        n_P = 3;                %plant state vector (x,y,theta)

        i_x_Cx = (1:n_Cx);              %x control indices
        i_x_Cy = (1:n_Cy)+i_x_Cx(end);  %y control indices
        i_x_Ct = (1:n_Ct)+i_x_Cy(end);  %theta control indices
        i_x_A1 = (1:n_A)+i_x_Ct(end);   %actuator 1 state indices
        i_x_A2 = (1:n_A)+i_x_A1(end);   %actuator 2 state indices
        i_x_A3 = (1:n_A)+i_x_A2(end);   %actuator 3 state indices
        i_x_P = (1:n_P)+i_x_A3(end);    %plant state indices

        %extracting state vectors for controller, actuators, and plant
        x_Cx = state(i_x_Cx);   %extracting x-control state vector
        x_Cy = state(i_x_Cy);   %extracting y-control state vector
        x_Ct = state(i_x_Ct);   %extracting theta-control state vector

        x_A1 = state(i_x_A1);   %extracting actuator 1 state vector
        x_A2 = state(i_x_A2);   %extracting actuator 2 state vector
        x_A3 = state(i_x_A3);   %extracting actuator 3 state vector

        x_P = state(i_x_P); %extracting x,y,theta state vector (inertial)
            theta = x_P(3); %current angle (for rotation matrix)
    
    %initializing model parameters and matrices
        radius = .063/2; %radius of robot wheel [m]
        d = .054; %distance between robot center and wheels [m]
        M = (1/radius)*[sin(pi/3)   cos(pi/3)   d;...
                         -sin(pi/3) cos(pi/3)   d;...
                         0          -1          d]; %mixing matrix (from Vb to wheel angular velocity)
        R_i2b = [cos(theta) sin(theta)  0;...
                -sin(theta) cos(theta)  0;...
                0           0           1]; %rotation matrix (inertial --> body)
        R_b2i = R_i2b'; %rotation matrix (body --> inertial)
   
    %determine control inputs and measurements
        e = ref_handle(time) -  x_P; %position error in inertial frame

        %control inputs (error)
        u_Cx = e(1); %x position error in inertial
        u_Cy = e(2); %y position error in inertial    
        u_Ct = e(3); %theta position error in inertial

        %control outputs (control/body frame velocity)
        y_Cx = Cx_ss.C*x_Cx+Cx_ss.D*u_Cx; %x body frame velocity command
        y_Cy = Cy_ss.C*x_Cy+Cy_ss.D*u_Cy; %y body frame velocity command
        y_Ct = Ct_ss.C*x_Ct+Ct_ss.D*u_Ct; %theta body frame velocity command

        y_C = [y_Cx y_Cy y_Ct]'; %creating vector
        u_wheels = M*y_C; %convert to angular wheel velocity
        
        %CHANGE LATER (PWM conversion and saturation):
        %%%!!!!!!!!!!!!!!FIX THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        PWM_conv = eye(length(u_wheels)); %convert angular velocity to PWM
        PWM_min = PWM_conv*u_wheels; %convert to actual lower bound
        PWM_max = PWM_conv*u_wheels; %convert to actual upper bound
        %%%^^^^^^^^^^^^^^FIX THIS^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        
        %convert to actuator space (PWM signal inputs)
        u_A = PWM_conv*u_wheels; %convert to PWM signal
        u_A_sat = min(PWM_max, max(PWM_min, u_A)); %introduce saturation

        u_A1 = u_A_sat(1); 
        u_A2 = u_A_sat(2);
        u_A3 = u_A_sat(3);

        %determine angular wheel velocities from given PWM inputs
        y_A1 = A_ss.C*x_A1+A_ss.D*u_A1;
        y_A2 = A_ss.C*x_A2+A_ss.D*u_A2;
        y_A3 = A_ss.C*x_A3+A_ss.D*u_A3;
        v_w_ang = [y_A1 y_A2 y_A3]'; %angular wheel velocity

        %convert to rover velocity (x,y,theta)_dot
        v_b = M\v_w_ang; %rover velocity in the inertial frame
        v_i = R_b2i*v_b; %rover velocity in the inertial frame
   
    %Determine state derivatives
        %Controller state derivative
        x_dot_Cx = Cx_ss.A*x_Cx+Cx_ss.B*u_Cx;
        x_dot_Cy = Cy_ss.A*x_Cy+Cy_ss.B*u_Cy;
        x_dot_Ct = Ct_ss.A*x_Ct+Ct_ss.B*u_Ct;

        %Actuator state derivative
        x_dot_A1 = A_ss.A*x_A1+A_ss.B*u_A1;
        x_dot_A2 = A_ss.A*x_A2+A_ss.B*u_A2;
        x_dot_A3 = A_ss.A*x_A3+A_ss.B*u_A3;
    
        %Rover position state derivative: (x,y,theta)_Dot in inerital
        x_dot_P = v_i;
    
    %spit out derivative vector
        f_x = zeros(size(state));
        f_x(i_x_Cx) = x_dot_Cx;
        f_x(i_x_Cy) = x_dot_Cy;
        f_x(i_x_Ct) = x_dot_Ct;
        f_x(i_x_A1) = x_dot_A1;
        f_x(i_x_A2) = x_dot_A2;
        f_x(i_x_A3) = x_dot_A3;
        f_x(i_x_P) = x_dot_P;
end
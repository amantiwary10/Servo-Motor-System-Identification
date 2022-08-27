                                                                                                                                                                                                                                           %Skye Mceowen
%ACL 2018-2019 - April 25, 2019
%Rover Kinematic Model - Discrete Control
%Contains actuator dynamics and plant output

function xDot = derivs_d(time,state,y_C,A_ss)
    %NOTE: xDot is a vector with: [xpDot; xaDot]'
            %where  xa contains actuator dynamics
                %   xp contains plant dynamics
 
    %extract dyanmics (state is a single vector)
        %determining appropriate state lengths and corresponding indices
        n_P = 3;                %plant state vector (x,y,theta)
        n_A = length(A_ss.A);   %length of actuator state
        
        i_x_P = (1:n_P);                %plant state indices
        i_x_A1 = (1:n_A)+i_x_P(end);    %actuator 1 state indices
        i_x_A2 = (1:n_A)+i_x_A1(end);   %actuator 2 state indices
        i_x_A3 = (1:n_A)+i_x_A2(end);   %actuator 3 state indices  

        %extracting state vectors for controller, actuators, and plant
        x_P = state(i_x_P); %extracting x,y,theta state vector (inertial)
            theta = x_P(3); %current angle (for rotation matrix)
        
        x_A1 = state(i_x_A1);   %extracting actuator 1 state vector
        x_A2 = state(i_x_A2);   %extracting actuator 2 state vector
        x_A3 = state(i_x_A3);   %extracting actuator 3 state vector

        
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
        %control outputs (control/body frame velocity)
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
        v_b = M\v_w_ang; %rover velocity in the body frame
        v_i = R_b2i*v_b; %rover velocity in the inertial frame
        
   
    %Determine next states
        %Rover position state derivative: (x,y,theta)_Dot in inerital
        xDot_P = v_i;
    
        %Actuator state derivative
        xDot_A1 = A_ss.A*x_A1+A_ss.B*u_A1;
        xDot_A2 = A_ss.A*x_A2+A_ss.B*u_A2;
        xDot_A3 = A_ss.A*x_A3+A_ss.B*u_A3;
    
    
    %spit out derivative vector
        xDot = zeros(size(state));
        xDot(i_x_P) = xDot_P;
        xDot(i_x_A1) = xDot_A1;
        xDot(i_x_A2) = xDot_A2;
        xDot(i_x_A3) = xDot_A3;
end
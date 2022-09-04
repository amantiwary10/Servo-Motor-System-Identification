function X_clean = fast_fourier(X, Ts)
    
    L = length(X);
    %Fs = 1/Ts;
    % compute fourier transform of the signal
    Y = fft(X);

    % compute two sided spectrum P2, then compute single side spectrum P1
    P2 = abs(Y/L);
    %P1 = P2(1:L/2 + 1);

    %P2(2:end - 1) = 2 * P2(2:end - 1);

    %f = Fs * (0:L-1)/L;

%     plot(f, P2)
% 
%     title('Single-Sided Amplitude Spectrum of X(t)')
%     xlabel('f (Hz)')
%     ylabel('|P1(f)|')

indices = P2 > 0.5;
Y_clean = indices .* Y;

X_clean = ifft(Y_clean);



    
end
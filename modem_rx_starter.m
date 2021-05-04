
load short_modem_rx.mat

% The received signal includes a bunch of samples from before the
% transmission started so we need discard the samples from before
% the transmission started. 

start_idx = find_start_of_signal(y_r,x_sync);
% start_idx now contains the location in y_r where x_sync begins
% we need to offset by the length of x_sync to only include the signal
% we are interested in
y_t = y_r(start_idx+length(x_sync):end); % y_t is the signal which starts at the beginning of the transmission


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Put your decoder code here
% 1. multiply y_t by a cosine wave
% 2. low pass filter 

x = y_t(1: 4100) .* cos(2*pi*(f_c/Fs)*[0:4099]');
% length(y_t)-1


Xw = fft(x);
O = linspace(-pi, pi - 2*pi/length(x), length(x));
figure(1)
plot(O, abs(Xw))
title('ft of x')

Y = fft(y_t);
O2 = linspace(-pi, pi - 2*pi/length(Y), length(Y));
figure(7)
plot(O2,abs(Y))
title('ft of yt')

t = [-100:1:99]*(1/Fs);
W = 2*pi*1000; 
h = W/pi*sinc(W/pi*t);
% figure(3)
% plot(t, h)

m = conv(x, h); 
figure(2)
plot(m)
xlim([0 4500])

N = length(m);
X = fftshift(fft(m));
f = linspace(-Fs/2*2*pi, 2*pi*Fs/2- 2*pi*Fs/length(m), length(m));
figure(6)
plot(f, abs(X));
xlabel('Frequency (rad/s)');
ylabel('|X(j\omega)|');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits
% BitsToString(x_d)


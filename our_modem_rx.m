
%load acoustic_modem_take2.mat
load acoustic_file_3.mat

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

%multiply input signal by cosine
x = y_t(1: 100*msg_length*8) .* cos(2*pi*(f_c/Fs)*[0:100*msg_length*8 - 1]');

%create sinc function with cutoff frequency W
t = [-50:1:49]*(1/Fs);
W = 2*pi*1000; 
h = W/pi*sinc(W/pi*t);

%convolve x and h
m = conv(x, h);

%Find indeces where m is positive and negative
mpos = find(m>0);
mneg = find(m<0);

%Create a matrix where m_bin is binary 1s or 0s depending if m is positive
%or negative
m_bin = [];
m_bin(mpos) = 1;
m_bin(mneg) = 0;

%cut off first 50 and last 50 data points, which were added in the
%convolution of x and h. Then sample between where every change should take
%place, every 100 data points
m_shortened = m_bin(50:end-50);
x_d = m_shortened(50:100:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert to a string assuming that x_d is a vector of 1s and 0s
% representing the decoded bits

final_message = BitsToString(x_d)
%function to make all relevant plots
make_plots(msg_length, x,m,Fs, m_bin, x_d, y_t);

function [X, f] = plot_ft_rad(x, fs)
    % plots the magnitude of the Fourier transform of the signal x
    % which is assumed to originate from a Continous-time signal 
    % sampled with frequency fs
    % the function returns X and f.
    % In other words, this function plots the FT of the DT signal x
    % with the frequency axis labeled as if it were the original CT signal
    % 
    % X contains the frequency response
    % f contains the frequency samples


    N = length(x);

    X = fftshift(fft(x));
    
    % note that the frequency range here is from -fs/2*2*pi -> something
    % just a little bit less of fs/2*2*pi
    % this is an artefact of the fact that we are actually computing a 
    % Discrete-Fourier-Transform (DFT) when we call FFT (which is a
    % numerical method to efficiently compute the DFT).
    
    f = linspace(-fs/2*2*pi, 2*pi*fs/2- 2*pi*fs/length(x), length(x));
    plot(f, abs(X));
    xlabel('Frequency (rad/s)');
    ylabel('|X(j\omega)|');
end
function make_plots(msg_length, x,m,Fs, m_bin, x_d, y)
    figure(1)
    plot_ft_rad(x, Fs);
    title('FFT of x');
    figure(2)
    plot_ft_rad(y,Fs);
    title('FFT of y');
    figure(3)
    plot(m)
    xlim([0 100*msg_length*8]);
    title('Plot of m, reconstructed signal');
    xlabel('Samples')
    ylabel('Amplitude')
    figure(4)
    plot_ft_rad(m,Fs);
    title('FFT of m');
    figure(5)
    plot(m_bin);
    title('Boxy Representation');
    xlabel('Samples')
    figure(6)
    plot(x_d, 'x--');
    title('Decoded Bits');
    xlabel('Samples')
    ylabel('Amplitude')
end


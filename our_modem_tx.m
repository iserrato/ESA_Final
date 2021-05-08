Fs = 8192;
f_c = 1000;
bits_to_send = StringToBits('Declan and Isabel say hi :D');

figure(11)
plot(bits_to_send)
msg_length = length(bits_to_send)/8;
SymbolPeriod = 80;

% convert the vector of 1s and 0s to 1s and -1s
m = 2*bits_to_send-1;
% create a waveform that has a positive box to represent a 1
% and a negative box to represent a zero
m_us = upsample(m, SymbolPeriod);
m_boxy = conv(m_us, ones(SymbolPeriod, 1));
figure(10)
plot(m_boxy); % visualize the boxy signal
title('M Boxy')

% create a cosine with analog frequency f_c
c = cos(2*pi*f_c/Fs*[0:length(m_boxy)-1]');
% create the transmitted signal
x_tx = m_boxy.*c;
X_TEST = x_tx;
% figure(4)
% plot(x_tx)  % visualize the transmitted signal
% title('Transmitted Signal')

% create  noise-like signal 
% to synchronize the transmission
% this same noise sequence will be used at
% the receiver to line up the received signal
% This approach is standard practice is real communications
% systems.
randn('seed', 1234);
x_sync = randn(Fs/4,1);
x_sync = x_sync/max(abs(x_sync))*0.5;
% stick it at the beginning of the transmission
x_tx = [x_sync;x_tx];
save sync_noise.mat x_sync Fs msg_length
% write the data to a file
audiowrite('80_symbol_period.wav', x_tx, Fs);


% recorder = audiorecorder(Fs,8,1)
% recordblocking(recorder, time)
%y_r = getaudiodata(recorder)

%save('acoustic_file_3.mat', 'f_c', 'Fs', 'msg_length', 'x_sync', 'y_r')
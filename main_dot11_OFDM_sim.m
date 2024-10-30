% main_OFDM_simulation.m
% This script simulates the construction and modulation of an OFDM packet
% following the IEEE 802.11-2017 standard, including packet transmission,
% channel distortion, packet detection, synchronization, channel estimation,
% and data decoding.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>
% https://github.com/Teddy-van-Jerry/802.11-2017-mini-phy

%% Preparations
addpath('functions');
close all;

%% Parameters
NUM_BITS = 4160; % Number of bits in the packet (> 1000)
PLT_SAVE = true; % Save the plots as .eps files
STF_XCORR_MAX = 800; % Maximum index for cross-correlation for synchronization
PD_THRESHOLD = 0.5; % Threshold for packet detection
plt_options = {'LineWidth', 1.5};

%% Step (1): QPSK Modulation and OFDM Symbol Construction
% Step (1.a): QPSK Modulation
% Generate random bits
bits = randi([0, 1], NUM_BITS, 1);

% Convert bits to QPSK symbols
[qpsk_symbols, num_padding_bits] = dot11_QPSK_modulate(bits);

% Group QPSK symbols into OFDM symbols with pilots
[ofdm_symbols_matrix, num_ofdm_symbols] = dot11_construct_OFDM_symbols(qpsk_symbols);

% Step (1.b): OFDM Modulation
% Perform OFDM modulation (64-point IFFT and add cyclic prefix)
tx_signal = dot11_OFDM_modulate(ofdm_symbols_matrix);

% Step (1.c): Add STF and LTF Preambles
% Generate STF and LTF preambles
[stf_signal, ltf_signal] = dot11_generate_preambles();

% Construct the complete packet
tx_packet = [stf_signal; ltf_signal; tx_signal];

% Step (1.d): Plotting
% Plot the magnitude of TX packet samples
figure;
plot(abs(stf_signal), plt_options{:});
grid on;
title('Magnitude of STF Samples');
xlabel('Sample Index');
ylabel('Magnitude');
if PLT_SAVE
    saveas(gcf, 'plots/TX_Packet_Magnitude.eps', 'epsc');
end

% Plot the power spectral density of the entire OFDM packet (including CP)
dot11_plot_PSD(tx_packet, PLT_SAVE, plt_options);

%% Step (2): Packet Transmission and Channel Distortion
% Add a number of (e.g., 100) zero samples before the packet
idle_samples = zeros(100, 1);
tx_signal_with_idle = [idle_samples; tx_packet];

% Simulate channel distortion
% (i) Magnitude attenuation to 10^-5 of original
channel_attenuation = 1e-5;

% (ii) Phase shift by -3*pi/4
phase_shift = exp(-1j * 3 * pi / 4);

% (iii) Frequency offset causing phase drift per sample
frequency_offset = 0.00017;
num_samples = length(tx_signal_with_idle);
phase_drift = exp(-1j * 2 * pi * frequency_offset * (0:num_samples - 1).');

% (iv) Add channel noise (mean 0, variance 1e-14)
noise_variance = 1e-24;
noise = sqrt(noise_variance / 2) * (randn(num_samples, 1) + 1j * randn(num_samples, 1));

% Apply the channel effects
rx_signal = tx_signal_with_idle * channel_attenuation; % Magnitude attenuation
rx_signal = rx_signal * phase_shift; % Phase shift
rx_signal = rx_signal .* phase_drift; % Frequency offset (phase drift)
rx_signal = rx_signal + noise; % Add noise

% Plot the magnitude of samples in the packet's STF after channel distortion
% Extract the STF part from rx_signal
stf_start_index = length(idle_samples) + 1;
stf_end_index = stf_start_index + length(stf_signal) - 1;
rx_stf_signal = rx_signal(stf_start_index:stf_end_index);

figure;
plot(abs(rx_stf_signal), plt_options{:});
grid on;
title('Magnitude of STF Samples after Channel Distortion');
xlabel('Sample Index');
ylabel('Magnitude');
if PLT_SAVE
    saveas(gcf, 'plots/STF_Magnitude_Channel_Distortion.eps', 'epsc');
end

%% Step (3): Packet Detection using Self-Correlation
% Parameters for self-correlation
L = 16; % Length of the repeating pattern in STF
metric = zeros(num_samples, 1);

% Compute self-correlation and normalization
for n = 1:num_samples - 2 * L
    r1 = rx_signal(n:n+L-1);
    r2 = rx_signal(n+L:n+2*L-1);
    metric(n+L) = abs(sum(r1 .* conj(r2))) / (sum(abs(r1).^2) + eps);
end

% Plot the self-correlation metric
figure;
plot(metric, plt_options{:});
grid on;
title('Self-Correlation Metric for Packet Detection');
xlabel('Sample Index');
ylabel('Correlation Metric');
if PLT_SAVE
    saveas(gcf, 'plots/Packet_Detection_Self_Correlation.eps', 'epsc');
end

% Threshold for packet detection
packet_detect_indices = find(metric > PD_THRESHOLD);
if isempty(packet_detect_indices)
    error('Packet not detected.');
end
disp(['Packet detected at sample index: ', num2str(packet_detect_indices(1))]);

%% Step (4): Packet Synchronization using Cross-Correlation
% Cross-correlate rx_signal with the known STF sequence
% cross_corr = abs(conv(rx_signal, flipud(conj(stf_signal)), 'same'));
cross_corr = abs(xcorr(rx_signal(packet_detect_indices), stf_signal(1:16)));

% Plot the cross-correlation result
figure;
plot(cross_corr(1:STF_XCORR_MAX), plt_options{:});
grid on;
title('Cross-Correlation for Packet Synchronization');
xlabel('Sample Index');
ylabel('Cross-Correlation Metric');
if PLT_SAVE
    saveas(gcf, 'plots/Packet_Synchronization_Cross_Correlation.eps', 'epsc');
end

% Find the peak in the cross-correlation
[~, sync_index] = max(cross_corr(packet_detect_indices:STF_XCORR_MAX));
disp(['Packet synchronization index (STF start): ', num2str(sync_index)]);

%% Step (5): Channel Estimation and Packet Decoding

% Step (a): Estimate Frequency Offset using LTF
% The LTF starts after the STF
ltf_start_index = sync_index + length(stf_signal);
ltf_end_index = ltf_start_index + length(ltf_signal) - 1;

% Extract the LTF samples from rx_signal
rx_ltf_signal = rx_signal(ltf_start_index:ltf_end_index);

% Remove CP from LTF symbols
ltf1 = rx_ltf_signal(16+1 :16+64 ); % First LTF symbol (after CP)
ltf2 = rx_ltf_signal(16+65:16+128); % Second LTF symbol (after CP)

% Estimate CFO from phase difference between ltf1 and ltf2
angle_tmp = angle(mean(ltf2 ./ ltf1));
if angle_tmp > pi
    angle_tmp = angle_tmp - 2 * pi;
end
cfo_est = angle_tmp / 64;
disp(['Estimated CFO: ', num2str(cfo_est)]);

% Correct the frequency offset in the received signal
n = (0:length(rx_signal) - sync_index).';
rx_signal_corrected = rx_signal(sync_index:end) .* exp(-1j * cfo_est * n);

% Step (b): Channel Estimation using LTF
% Perform FFT on the received LTF symbol
rx_ltf_fft = fft(rx_ltf_signal(17:16+64), 64);

% Get the known LTF sequence in frequency domain
known_ltf_freq = dot11_ltf_known_sequence();

% Estimate the channel response
channel_estimate = rx_ltf_fft ./ known_ltf_freq;

% Print the channel distortion to each subcarrier
disp('Channel estimation for each subcarrier:');
disp(channel_estimate().');

% Step (c): Data Decoding
% Extract the OFDM data symbols from rx_signal_corrected
data_start_index = length(stf_signal) + length(ltf_signal) + 1;
rx_data_signal = rx_signal_corrected(data_start_index:end);

% Number of OFDM data symbols
num_data_symbols = num_ofdm_symbols;

% Initialize matrix to hold received data symbols
rx_ofdm_symbols_data = zeros(48, num_data_symbols); % only data subcarriers

% For each OFDM data symbol
for k = 1:num_data_symbols
    symbol_start = (k - 1) * 80 + 1 + 16; % Skip CP
    symbol_end = symbol_start + 63;
    if symbol_end > length(rx_data_signal)
        break; % Avoid index exceeding array bounds
    end
    rx_symbol = rx_data_signal(symbol_start:symbol_end);
    
    % Perform FFT
    rx_fft = fft(rx_symbol, 64);
    
    % Equalize using channel estimate
    rx_eq = rx_fft ./ channel_estimate;
    
    % Extract data subcarriers
    data_subcarrier_indices = dot11_data_subcarrier_indices();
    rx_data = rx_eq(data_subcarrier_indices);
    
    % Store the data symbols
    rx_ofdm_symbols_data(:, k) = rx_data; % Now dimensions match
end

% Reshape received data symbols into a vector
rx_qpsk_symbols = rx_ofdm_symbols_data(:);
rx_bits = dot11_QPSK_demodulate(rx_qpsk_symbols, num_padding_bits);

if length(rx_bits) > NUM_BITS
    rx_bits = rx_bits(1:NUM_BITS);
elseif length(rx_bits) < NUM_BITS
    error('Received bits are less than transmitted bits.');
end

% Calculate BER
[num_errors, ber] = dot11_ber(bits, rx_bits);

disp(['Number of bit errors: ', num2str(num_errors), ' out of ', num2str(NUM_BITS), '. BER: ', num2str(ber)]);

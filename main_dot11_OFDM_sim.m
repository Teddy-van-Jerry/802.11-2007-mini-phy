% main_OFDM_simulation.m
% This script simulates the construction and modulation of an OFDM packet
% following the IEEE 802.11-2007 standard, including packet transmission,
% channel distortion, packet detection, synchronization, channel estimation,
% and data decoding.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>
% https://github.com/Teddy-van-Jerry/802.11-2007-mini-phy

%% Preparations
addpath('functions');
close all;

%% Parameters
NUM_BITS = 4160; % Number of bits in the packet (> 1000)
PLT_SAVE = true; % Save the plots as .eps files
STF_SCORR_MAX = 1000; % Maximum length for self-correlation plot
STF_XCORR_MAX = 500; % Maximum length for cross-correlation plot
PD_THRESHOLD = 0.5; % Threshold for packet detection
BD_THRESHOLD = 0.8; % Threshold for boundary detection
LOOPBACK = false; % Enable loopback mode for channel distortion
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
    saveas(gcf, 'plots/STF_Magnitude.eps', 'epsc');
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
noise_variance = 1e-14;
noise = sqrt(noise_variance / 2) * (randn(num_samples, 1) + 1j * randn(num_samples, 1));

% Apply the channel effects
if LOOPBACK == true % <- so we do not have a unreachable branch warning
    rx_signal = tx_signal_with_idle; % No channel distortion
else
    rx_signal = tx_signal_with_idle * channel_attenuation; % Magnitude attenuation
    rx_signal = rx_signal * phase_shift; % Phase shift
    rx_signal = rx_signal .* phase_drift; % Frequency offset (phase drift)
    rx_signal = rx_signal + noise; % Add noise
end

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
[approx_packet_start, metric] = dot11_packet_detect(rx_signal, PD_THRESHOLD);

% Plot the self-correlation metric
figure;
plot(metric(1:STF_SCORR_MAX), plt_options{:});
grid on;
title('Self-Correlation Metric for Packet Detection');
xlabel('Sample Index');
ylabel('Correlation Metric');
if PLT_SAVE
    saveas(gcf, 'plots/Packet_Detection_Self_Correlation.eps', 'epsc');
end

disp(['Packet detected at sample index: ', num2str(approx_packet_start)]);

%% Step (4): Packet Synchronization using Cross-Correlation
% bounfary detection (synchronization)
[sync_index, cross_corr] = dot11_boundary_detect(rx_signal, BD_THRESHOLD);

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
disp(['Packet synchronization index (start of STF): ', num2str(sync_index)]);

%% Step (5): Channel Estimation and Packet Decoding

% Step (a): Estimate Frequency Offset using LTF and correct the signal
[cfo_est, rx_ltf_signal, rx_signal_corrected] = dot11_cfo_estimate(sync_index, rx_signal);
disp(['Estimated CFO: ', num2str(cfo_est, '%.6f')]);

% Step (b): Channel Estimation using LTF
channel_estimate = dot11_channel_estimate(rx_ltf_signal);
dot11_print_est_channel(channel_estimate);

% Step (c): Data Decoding
% Extract the OFDM data symbols from rx_signal_corrected
rx_qpsk_symbols = dot11_decode_OFDM_data(rx_signal_corrected, num_ofdm_symbols, channel_estimate);
rx_bits = dot11_QPSK_demodulate(rx_qpsk_symbols, num_padding_bits);

if length(rx_bits) > NUM_BITS
    rx_bits = rx_bits(1:NUM_BITS);
elseif length(rx_bits) < NUM_BITS
    error('Received bits are less than transmitted bits.');
end

% Calculate BER
[num_errors, ber] = dot11_ber(bits, rx_bits);

disp(['Number of bit errors: ', num2str(num_errors), ' out of ', num2str(NUM_BITS), '. BER: ', num2str(ber)]);

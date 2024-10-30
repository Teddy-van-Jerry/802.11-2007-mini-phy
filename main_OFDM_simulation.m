% main_OFDM_simulation.m
% This script simulates the construction and modulation of an OFDM packet
% following the IEEE 802.11-2017 standard.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

%% Function Path
addpath('functions');

%% Parameters
NUM_BITS = 4160; % Number of bits in the packet (> 1000)
PLT_SAVE = true; % Save the plots as .eps files
plt_options = {'LineWidth', 1.5};

%% Step (a): QPSK Modulation and OFDM Symbol Construction
% Generate random bits
bits = randi([0, 1], NUM_BITS, 1);

% Convert bits to QPSK symbols
qpsk_symbols = dot11_QPSK_modulate(bits);

% Group QPSK symbols into OFDM symbols with pilots
[ofdm_symbols_matrix, num_ofdm_symbols] = dot11_construct_OFDM_symbols(qpsk_symbols);

%% Step (b): OFDM Modulation
% Perform OFDM modulation (64-point IFFT and add cyclic prefix)
tx_signal = dot11_OFDM_modulate(ofdm_symbols_matrix);

%% Step (c): Add STF and LTF Preambles
% Generate STF and LTF preambles
[stf_signal, ltf_signal] = dot11_generate_preambles();

% Construct the complete packet
tx_packet = [stf_signal; ltf_signal; tx_signal];

%% Step (d): Plotting
% Close all figures first
close all;

% Plot the magnitude of STF samples
figure;
plot(abs(tx_packet), plt_options{:});
grid on;
title('Magnitude of STF Samples');
xlabel('Sample Index');
ylabel('Magnitude');
if PLT_SAVE
    saveas(gcf, 'plots/STF_Magnitude.eps', 'epsc');
end

% Plot the power spectral density of the entire OFDM packet (including CP)
dot11_plot_PSD(tx_packet, PLT_SAVE, plt_options);

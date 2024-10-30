% dot11_cfo_estimate.m
% This function estimates the carrier frequency offset (CFO) using the LTF symbols.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [cfo_est, rx_ltf_signal, rx_signal_corrected] = dot11_cfo_estimate(sync_index, rx_signal)
    length_stf_signal = 160;
    length_ltf_signal = 160;

    % The LTF starts after the STF
    ltf_start_index = sync_index + length_stf_signal;
    ltf_end_index = ltf_start_index + length_ltf_signal - 1;

    % Extract the LTF samples from rx_signal
    rx_ltf_signal = rx_signal(ltf_start_index:ltf_end_index);

    % Remove CP from LTF symbols
    ltf1 = rx_ltf_signal(16+1 :16+64 ); % First LTF symbol (after CP)
    ltf2 = rx_ltf_signal(16+65:16+128); % Second LTF symbol (after CP)

    % Estimate CFO from phase difference between ltf1 and ltf2
    angle_tmp = -angle(sum(conj(ltf1) .* ltf2));
    cfo_est = angle_tmp / 64 / 2 / pi;

    n = (0:length(rx_signal) - sync_index).';
    rx_signal_corrected = rx_signal(sync_index:end) .* exp(2j * pi * cfo_est * n);
end

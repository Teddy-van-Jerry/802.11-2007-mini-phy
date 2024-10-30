% dot11_channel_estimate.m
% This function estimates the channel response using the received LTF signal.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function channel_estimate = dot11_channel_estimate(rx_ltf_signal)
    % Perform FFT on the received LTF symbol
    rx_ltf_fft = fft(rx_ltf_signal(17:16+64), 64);

    % Get the known LTF sequence in frequency domain
    known_ltf_freq = dot11_ltf_known_freq();

    % Estimate the channel response
    channel_estimate = rx_ltf_fft ./ known_ltf_freq;
end

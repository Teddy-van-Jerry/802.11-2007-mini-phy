% dot11_packet_detect.m
% This function detects the start of a packet by cross-correlating
% the delayed version of the received signal.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [idx, metric] = dot11_packet_detect(rx_signal, PD_THRESHOLD)
    if nargin < 2
        PD_THRESHOLD = 0.5;
    end

    num_samples = length(rx_signal);

    L = 16; % Length of the repeating pattern in STF
    metric = zeros(num_samples, 1);

    % Compute self-correlation and normalization
    for n = 1:num_samples - 2 * L
        r1 = rx_signal(n:n+L-1);
        r2 = rx_signal(n+L:n+2*L-1);
        metric(n+L) = abs(sum(r1 .* conj(r2))) / (sum(abs(r1).^2) + eps);
    end

    % Threshold for packet detection
    packet_detect_indices = find(metric > PD_THRESHOLD);
    if isempty(packet_detect_indices)
        idx = 0; % <-- indicate packet not detected
    else
        idx = packet_detect_indices(1);
    end
end

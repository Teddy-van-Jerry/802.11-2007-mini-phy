% dot11_QPSK_demodulate.m
% This function demodulates QPSK symbols into bits,
% matching the mapping used in dot11_QPSK_modulate.m
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function bits = dot11_QPSK_demodulate(qpsk_symbols, num_padding_bits)
    bits = zeros(length(qpsk_symbols) * 2, 1);
    mapping = [1+0j, 0+1j, -1+0j, 0-1j]; % not the widely used one!!!
    % Here we are not using the decison boundary but the brute-force method
    % to provide extra flexibility for the project.
    for i = 1:length(qpsk_symbols)
        [~, index] = min(abs(qpsk_symbols(i) - mapping));
        bits(2*i-1:2*i) = [floor((index-1) / 2), mod(index-1, 2)];
    end
    bits = bits(1:end-num_padding_bits);
end

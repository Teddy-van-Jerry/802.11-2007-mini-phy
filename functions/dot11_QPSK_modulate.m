% dot11_QPSK_modulate.m
% This function performs QPSK modulation on input bits.
% NOTE: Not the widely used QPSK mapping! Not Gray coding!
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [qpsk_symbols, num_padding_bits] = dot11_QPSK_modulate(bits)
    % Ensure the number of bits is even
    num_padding_bits = mod(2 - mod(length(bits), 2), 2);
    if num_padding_bits > 0
        bits = [bits; zeros(num_padding_bits, 1)];
    end
    bits_reshaped = reshape(bits, 2, []).';
    mapping = [1+0j, 0+1j, -1+0j, 0-1j]; % not the widely used one!!! not Gray coding!
    indices = bits_reshaped(:,1) * 2 + bits_reshaped(:,2) + 1;
    qpsk_symbols = mapping(indices).';
end

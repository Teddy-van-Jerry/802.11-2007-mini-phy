% dot11_QPSK_modulate.m
% This function performs QPSK modulation on input bits.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function qpsk_symbols = dot11_QPSK_modulate(bits)
    % Ensure the number of bits is even
    if mod(length(bits), 2) ~= 0
        bits = [bits; 0];
    end

    % Reshape bits into pairs
    bits_reshaped = reshape(bits, 2, []).';

    % Map bit pairs to QPSK symbols
    mapping = [1+0j, 0+1j, -1+0j, 0-1j]; % [00, 01, 10, 11]
    indices = bits_reshaped(:,1) * 2 + bits_reshaped(:,2) + 1;
    qpsk_symbols = mapping(indices).';
end

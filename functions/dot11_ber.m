% dot11_ber.m
% This function calculates the number of bit errors and bit error rate (BER).
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [n_err, ber] = dot11_ber(tx_bits, rx_bits)
    n_err = sum(tx_bits ~= rx_bits);
    ber = n_err / length(tx_bits);
end

% dot11_QPSK_demodulate.m
% This function demodulates QPSK symbols into bits.

function bits = dot11_QPSK_demodulate(qpsk_symbols, num_padding_bits)
    bits = zeros(length(qpsk_symbols) * 2, 1);
    decision_bound = 0;
    for k = 1:length(qpsk_symbols)
        real_part = real(qpsk_symbols(k));
        imag_part = imag(qpsk_symbols(k));
        bits(2*k-1) = real_part < decision_bound;
        bits(2*k)   = imag_part < decision_bound;
    end
    bits = bits(1:end-num_padding_bits);
end

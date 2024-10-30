% dot11_OFDM_modulate.m
% This function performs OFDM modulation (IFFT and cyclic prefix addition).
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function tx_signal = dot11_OFDM_modulate(ofdm_symbols_matrix)
    num_total_subcarriers = 64;
    cyclic_prefix_length = 16;

    % Perform IFFT on each OFDM symbol
    ofdm_time_domain = ifft(ofdm_symbols_matrix, num_total_subcarriers);

    % Add cyclic prefix
    cyclic_prefix = ofdm_time_domain(end - cyclic_prefix_length + 1:end, :);
    ofdm_with_cp = [cyclic_prefix; ofdm_time_domain];

    % Serialize the OFDM symbols
    tx_signal = ofdm_with_cp(:);
end

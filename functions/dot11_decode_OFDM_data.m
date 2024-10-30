% dot11_decode_OFDM_data.m
% This function decodes OFDM data symbols.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function symbols = dot11_decode_OFDM_data(rx_signal_corrected, num_ofdm_symbols, channel_estimate)
    length_stf_signal = 160;
    length_ltf_signal = 160;

    data_start_index = length_stf_signal + length_ltf_signal + 1;
    rx_data_signal = rx_signal_corrected(data_start_index:end);

    % Initialize matrix to hold received data symbols
    rx_ofdm_symbols_data = zeros(48, num_ofdm_symbols); % only data subcarriers

    % For each OFDM data symbol
    for k = 1:num_ofdm_symbols
        symbol_start = (k - 1) * 80 + 1 + 16; % Skip CP
        symbol_end = symbol_start + 63;
        if symbol_end > length(rx_data_signal)
            break; % Avoid index exceeding array bounds
        end
        rx_symbol = rx_data_signal(symbol_start:symbol_end);
        
        % Perform FFT
        rx_fft = fft(rx_symbol, 64);
        
        % Equalize using channel estimate
        rx_eq = rx_fft ./ channel_estimate;
        
        % Extract data subcarriers
        data_subcarrier_indices = dot11_data_subcarrier_indices();
        rx_data = rx_eq(data_subcarrier_indices);
        
        % Store the data symbols
        rx_ofdm_symbols_data(:, k) = rx_data; % Now dimensions match
    end

    % Reshape received data symbols into a vector
    symbols = rx_ofdm_symbols_data(:);
end

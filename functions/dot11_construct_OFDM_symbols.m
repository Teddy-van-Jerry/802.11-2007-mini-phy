% dot11_construct_OFDM_symbols.m
% This function constructs OFDM symbols with pilots from QPSK symbols.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [ofdm_symbols_matrix, num_ofdm_symbols] = dot11_construct_OFDM_symbols(qpsk_symbols)
    num_data_subcarriers = 48;
    num_pilot_subcarriers = 4;
    num_total_subcarriers = 64;

    % Calculate the number of OFDM symbols needed
    num_ofdm_symbols = ceil(length(qpsk_symbols) / num_data_subcarriers);

    % Pad QPSK symbols if necessary
    total_symbols_needed = num_ofdm_symbols * num_data_subcarriers;
    qpsk_symbols_padded = [qpsk_symbols; zeros(total_symbols_needed - length(qpsk_symbols), 1)];

    % Reshape into data symbols matrix
    data_symbols_matrix = reshape(qpsk_symbols_padded, num_data_subcarriers, num_ofdm_symbols);
    % **pilot assumed to be 1+0j in this project**
    % > The pilots shall be BPSK modulated by a pseudo-binary sequence to prevent the generation of spectral lines.
    pilot_symbols_matrix = ones(num_pilot_subcarriers, num_ofdm_symbols);

    % Initialize the frequency domain OFDM symbols
    ofdm_symbols_matrix = zeros(num_total_subcarriers, num_ofdm_symbols);

    % Correct data subcarrier indices (MATLAB indexing)
    data_subcarrier_indices = dot11_ifft_index_map([-26:-22, -20:-8, -6:-1, 1:6, 8:20, 22:26]); % Total of 48 indices

    % Correct pilot subcarrier indices (MATLAB indexing)
    pilot_subcarrier_indices = dot11_ifft_index_map([-21, -7, 7, 21]);

    % Map data symbols
    ofdm_symbols_matrix(data_subcarrier_indices, :) = data_symbols_matrix;

    % Map pilot symbols
    ofdm_symbols_matrix(pilot_subcarrier_indices, :) = pilot_symbols_matrix;
end

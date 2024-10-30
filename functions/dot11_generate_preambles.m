% dot11_generate_preambles.m
% This function generates the STF and LTF preambles.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [stf_signal, ltf_signal] = dot11_generate_preambles()
    num_total_subcarriers = 64;
    cyclic_prefix_length = 16;

    %% Generate STF
    stf_freq_domain = zeros(num_total_subcarriers, 1);

    % Define STF subcarrier numbers (n): -24, -20, -16, -12, -8, -4, +4, +8, +12, +16, +20, +24
    stf_subcarrier_numbers = [-24, -20, -16, -12, -8, -4, +4, +8, +12, +16, +20, +24];
    stf_subcarrier_indices = dot11_ifft_index_map(stf_subcarrier_numbers);

    % Define STF values for these subcarriers
    stf_values = [1+1j, -1-1j, 1+1j, -1-1j, -1-1j, 1+1j, -1-1j, -1-1j, 1+1j, 1+1j, 1+1j, 1+1j].' * sqrt(13/6);

    % Map STF values into frequency domain
    stf_freq_domain(stf_subcarrier_indices) = stf_values;

    % Compute IFFT to get time-domain STF
    stf_time_domain = ifft(stf_freq_domain, num_total_subcarriers);

    % Create STF signal by repeating the first 16 samples
    stf_signal = repmat(stf_time_domain(1:16), 10, 1);

    %% Generate LTF
    ltf_freq_domain = zeros(num_total_subcarriers, 1);

    % Define LTF subcarrier numbers (n): -26 to -1, 1 to 26 (excluding DC)
    ltf_subcarrier_numbers = [-26:-1, 1:26];
    ltf_subcarrier_indices = dot11_ifft_index_map(ltf_subcarrier_numbers);

    % Define LTF values for these subcarriers
    ltf_values = [ ...
         ... % n from -26 to -1
         1,  1, -1, -1,  1,  1, -1,  1, ...
        -1,  1,  1,  1,  1,  1,  1, -1, ...
        -1,  1,  1, -1,  1, -1,  1,  1, ...
         1,  1, ...
         ... % n from +1 to +26
         1, -1, -1,  1,  1, -1,  1, -1, ...
         1, -1, -1, -1, -1, -1,  1,  1, ...
        -1, -1,  1, -1,  1, -1,  1,  1, ...
         1,  1 ...
    ]';

    % Map LTF values into frequency domain
    ltf_freq_domain(ltf_subcarrier_indices) = ltf_values;

    % Compute IFFT to get time-domain LTF
    ltf_time_domain = ifft(ltf_freq_domain, num_total_subcarriers);

    % Add cyclic prefix to LTF
    ltf_cyclic_prefix = ltf_time_domain(end - cyclic_prefix_length * 2 + 1:end);
    ltf_signal = [ltf_cyclic_prefix; ltf_time_domain; ltf_time_domain]; % Two repetitions of LTF
end

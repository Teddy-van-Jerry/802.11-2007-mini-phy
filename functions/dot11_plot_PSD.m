% dot11_plot_PSD.m
% This function plots the power spectral density of the entire OFDM packet (including cyclic prefix).
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function dot11_plot_PSD(tx_packet, plt_save, plt_options)
    if nargin < 2
        plt_save = false;
    end
    if nargin < 3
        plt_options = {'LineWidth', 1.5};
    end
    
    num_subcarriers = 64;

    % Compute PSD using pwelch
    window = hamming(num_subcarriers); % Window length
    noverlap = length(window)/2;       % 50% overlap
    nfft = num_subcarriers;            % Number of FFT points for resolution
    fs = 1;                            % Sampling frequency (normalized)
    [psd, freq] = pwelch(tx_packet, window, noverlap, nfft, fs, 'centered', 'psd');

    % Plot PSD
    figure;
    plot(freq, 10 * log10(psd), plt_options{:});
    title('Power Spectral Density of OFDM Packet');
    xlabel('Normalized Frequency');
    ylabel('Power/Frequency (dB/Hz)');
    grid on;

    % Save plot as eps
    if plt_save
        saveas(gcf, 'plots/PSD_OFDM_Packet.eps', 'epsc');
    end
end

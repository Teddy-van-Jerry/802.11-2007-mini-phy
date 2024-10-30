% dot11_print_est_channel.m
% This function prints the estimated channel for each subcarrier.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function dot11_print_est_channel(channel_estimate)
    disp('Estimated channel for each subcarrier:');
    for i = [-26:-1, 1:26]
        idx = dot11_ifft_index_map(i);
        disp(['Subcarrier #', num2str(i), ': ', num2str(channel_estimate(idx))]);
    end
end

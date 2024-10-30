% dot11_data_subcarrier_indices.m
% This function returns the indices of data subcarriers.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function data_subcarrier_indices = dot11_data_subcarrier_indices()
    % Subcarrier numbers from -26 to -1 and 1 to 26, excluding pilot subcarriers
    data_subcarrier_indices = [[-26:-22, -20:-8, -6:-1] + 65, [1:6, 8:20, 22:26] + 1];
end

% dot11_ifft_index_map.m
% Maps the indices of the IFFT output according to the 802.11-2007 standard.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function mapped_indices = dot11_ifft_index_map(indices)
    idx_p = find(indices <= +26 & indices >= +1);
    idx_n = find(indices >= -26 & indices <= -1);
    mapped_indices = zeros(size(indices));
    % add an additional 1 because of MATLAB indexing
    mapped_indices(idx_p) = indices(idx_p) + 1;
    mapped_indices(idx_n) = indices(idx_n) + 65;
    mapped_indices(indices == 0) = 1; % in case there you have 0
end

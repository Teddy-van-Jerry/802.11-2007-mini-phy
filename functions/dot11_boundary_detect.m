% dot11_boundary_detect.m
% This function detects the boundary of a received signal by cross-correlating
% it with the segment of STF signal.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function [idx, cross_corr] = dot11_boundary_detect(rx_signal, BD_THRESHOLD)
    if nargin < 2
        BD_THRESHOLD = 0.8;
    end

    [stf_signal, ~] = dot11_generate_preambles();
    cross_corr = abs(xcorr(rx_signal, stf_signal(1:16)));
    cross_corr = cross_corr(end-length(rx_signal)-15:end);
    % Find peaks in the cross-correlation result
    [~, locs] = findpeaks(cross_corr, 'MinPeakHeight', BD_THRESHOLD * max(cross_corr));
    % The first peak corresponds to the start of LTF
    idx = locs(1) - 16;
end

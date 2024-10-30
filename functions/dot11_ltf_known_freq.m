% dot11_ltf_known_freq.m
% This function returns the known LTF sequence in frequency domain.
%
% by Wuqiong Zhao <wqzhao@ucsd.edu>

function known_ltf_freq = dot11_ltf_known_freq()
    [~, ltf_signal] = dot11_generate_preambles();
    known_ltf_freq = fft(ltf_signal(17:16+64), 64);
end

function timing = GenerateMultiPulsePattern(stim,pwidth,pint,pnum,pstart)
if (nargin > 1)
    if ~exist('pstart') pstart = 0; end
    stim = [stim,pwidth,pint,pnum,pstart];
end

CHANNEL = 1;
WIDTH = 2;
INTERVAL = 3;
NUMBER = 4;
START = 5;

num_channels = size(stim,1);

timing = [];

for ch = 1:num_channels
    for i=1:stim(ch,NUMBER)
        timing = [timing; ...
            stim(ch,START) + (i-1)*stim(ch,INTERVAL), stim(ch,CHANNEL), 1; ...
            stim(ch,START) + (i-1)*stim(ch,INTERVAL) + stim(ch,WIDTH), stim(ch,CHANNEL), 0];
    end
end

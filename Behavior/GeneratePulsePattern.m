function timing = GeneratePulsePattern(valve,pwidth,pint,pnum,pstart)
if ~exist('pstart') pstart = 0; end

% timing = zeros(pnum*2*length(pstart),3);
timing = [];
for r = 1:length(pstart)
    for i=1:pnum
%         timing(2*i-1,:) = [pstart(r) + (i-1)*pint,          valve, 1];
%         timing(2*i,:)   = [pstart(r) + (i-1)*pint + pwidth, valve, 0];
        timing = [timing; ...
                    pstart(r) + (i-1)*pint,          valve, 1; ...
                    pstart(r) + (i-1)*pint + pwidth, valve, 0];
    end
end

% if pstart > 0 timing = [0, valve, 0; timing]; end
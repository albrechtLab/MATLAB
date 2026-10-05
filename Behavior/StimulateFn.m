function StimulateFn

% Read data from figure window
userdata = get(gcf,'UserData');
Valve = userdata.Valve;
h = userdata.h;
a = userdata.Arduino;
PinConfig = userdata.PinConfig;
if isfield(userdata,'MVP') 
    mvp = true;
    MVP = userdata.MVP; 
else
    mvp = false;
end

set(h(1),'BackgroundColor',[0.5 1 0.5]);
set(h(2),'BackgroundColor',[.94 .94 .94]);

%---

valves = length(Valve);
if valves > 0
    numswitches = size(Valve(1).Program,1);
else
    numswitches = 0;
end

swtime = []; for v = 1:valves; swtime = [swtime; Valve(v).Program(:,1) v*(Valve(v).Program(:,2)*2-1)]; end
if mvp swtime = [swtime; MVP(:,1) 0.1*MVP(:,2)]; end
swtime = sortrows(swtime,1)

swlist = unique(swtime(:,1));
vdisp = ['off';'on '];

dM = 0.003; % MATLAB delay

starttime = now; datestr(starttime)
set(h(4),'BackgroundColor',[0.8 1 0.8]);
tic; dt = 0; out = []; outstr = [];
for n = 1:length(swlist)
    
    swt = swlist(n);
    delaytime = max(swt - toc - dM,0);
%     delaytime = max(swt - toc - dt - dM,0);
    pause(delaytime);
    StopValveTiming = strcmp(get(100,'Tag'),'stop');
    if StopValveTiming 
        disp('Program aborted');
        set(h(2),'BackgroundColor',[1 0 0]);
        drawnow;
        break; 
    end

    ts = toc;
    swv = swtime(find(swtime(:,1)==swt),2);
    for vn = 1:length(swv)
        
        v = abs(swv(vn)); val = swv(vn) > 0;
        
        tstart = toc;
        if v >= 1
            writeDigitalPin(a, ['D' num2str(PinConfig(v))], val);
            % ValveBank(v,val);
        else
            val = round(v*10);
            v = 0;
            SetHamiltonPosition(val);
            %pause(0.2);
        end
        
        current = [n, swt, tstart, toc, v, val];
        out = [out; current];

        if exist('h') && length(h) == 5 && ishandle(h(5))
            subplot(h(5)); 
            if v >= 1
                scatter(current(3)/60,(val-0.5)*0.8+v);
                scatter(current(4)/60,(val-0.5)*0.8+v, 'x');
                outstr = [outstr; time2str(current(4)/3600,'24','hms',-3),' V',...
                  num2str(v),' ',vdisp(val+1,:)];
            else
                scatter(current(3)/60,(val-1)*0.2 - 1);
                scatter(current(4)/60,(val-1)*0.2 - 1, 'x');
                outstr = [outstr; time2str(current(4)/3600,'24','hms',-3),' MVP #',...
                  num2str(val)];
            end
            set(h(4),'String',outstr,'Value',size(outstr,1));
            set(h(3),'String',['Next: ',...
                time2str(swlist(min(n+1,length(swlist)))/3600,'24','hms',0)]);
        else
            disp(current);
        end
        
        userdata.out = out;
        set(100,'UserData',userdata);
        
    end
    dt = toc-ts;
end

if StopValveTiming
    set(h(4),'BackgroundColor',[1 0.8 0.8]);
else
    set(h(4),'BackgroundColor',[0.94 0.94 0.94]);
end
set(h(1),'BackgroundColor',[0.94 0.94 0.94]);

% All Valves off at end
if valves > 0
    for v = 1:length(PinConfig); 
        writeDigitalPin(a, ['D',num2str(PinConfig(v))], 0); 
    end
end
% ValveBank(1:4,0);

%Write output file
try
    pathname = [getenv('USERPROFILE') '\StimulusFiles'];
    if ~exist(pathname) mkdir(pathname); end
    filename = ['Stim' datestr(starttime,30) '.mat'];
    save(fullfile(pathname,filename),'userdata');
catch
    disp(['Couldn''t save to:' fullfile(pathname,filename)]);
end

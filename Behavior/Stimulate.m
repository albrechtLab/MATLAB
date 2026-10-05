function output = Stimulate(timing,PinConfig)

% output = Stimulate(timing,PinConfig)
%
%       timing is an n x 3 matrix of n valve changes.  Each row contains
%       [time(s) valve# setting] where setting 0 is off, 1 is on.
%           e.g. [ 0 1 0 ; 0 2 1; 10 1 1; 10 2 0 ]
%                sets valve 1 off, 2 on at time 0s, then valve 1 on valve 2
%                off at 10s.
%           valve 0 is the Hamilton MVP rotational positioner with
%                valid settings 1-8
%
%       PinConfig is a 1 x n vector with pin numbers for each stimulus
%           default = [ 7 6 5 4 11 10 9 8 ]

%clear all -except timing PinConfig

if size(timing,2) ~= 3
    error('timing format incorrect.  type ''help ValveBankTiming''');
end
if ~exist('PinConfig')
    PinConfig = [ 7 6 5 4 11 10 9 8 ];
end

global StopValveTiming
    
% %-----------------------------
% % SET PROGRAM
% %-----------------------------
% leadtime = 0 * 60; % sec
% endtime = 0 * 60; % sec
% repeat = 1;
% cycletime = 0 * 60; % sec (manually set cycle time; set to 0 for auto) 
% 
% %pat = pulseSwitchList(30,[10 20 60 10 20 60],120);
% %pat = pulseSwitchList(30,[10 20 40 60 90 180],120);
% %pat = pulseSwitchList(30,fliplr([10 20 40 60 90 180]),120);
% 
% %pat = freqSwitchList(5*60,4)+5*60;
% %pat = freqSwitchList(10*60,6);
% 
% %pat = freqSwitchList([30 20 10],[6 9 18]);
% %pat = freqSwitchList([5],[120]);
% 
% pat = freqSwitchList([10 20 30 45 60 90],[18 9 6 4 3 2]);
% %pat = freqSwitchList(fliplr([10 20 30 45 60 90]),fliplr([18 9 6 4 3 3]));
% %pat = mseqSwitchList(-mseq(2,7,1,2),20);
% %pat = 60*[0 1; 4 7; 10 15; 18 18];   
% %pat = freqSwitchList(1,30);
% 
% if cycletime == 0
%     cycletime = max(pat(:,2));
% end
% 
% pl = [];
% for r = 1:repeat
%     pl = [pl; leadtime + pat + cycletime*(r-1)];
% end
% pl = [pl; [1 1]*(leadtime + repeat*cycletime + endtime)];
% pulse = onlist2timeconc(pl);

numvalves = max(timing(:,2));
Valve = [];
MVP = [];

for v = 1:numvalves;
    Valve(v).Program = timing(timing(:,2) == v,[1 3]); 
end
MVP = timing(timing(:,2) == 0,[1 3]);

% Initialize and close valves

% First, delete any existing Arduino systems with baudrate 115200
% ser = instrfind;
% for s = 1:length(ser);
%     if (ser(s).BaudRate == 115200) delete(ser(s)); end
% end

if numvalves > 0 
    fig = findobj('type','figure','number',100);
    if ~isempty(fig)
        userdata = get(fig.Number,'UserData');
        a = userdata.Arduino;
    else
        try
            a = arduino();  % may need to add code for computers with multiple com ports
        catch
            error('Communication error with Arduino, please reset and check COM ports or type ''clear all''');
        end
    end
    for v = 1:length(PinConfig); 
        writeDigitalPin(a, ['D',num2str(PinConfig(v))], 0); 
    end
    %ValveBank(1:4,0);
else
    a = 0;
end

% set MVP to position 1
if ~isempty(MVP)
    SetHamiltonPosition(1);
end



% Set up UI
%---------------------------
fig = figure(100); clf;
set(fig, ...
    'Name','Stimulate', ...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'CloseRequestFcn', @closeStimulate);
uipos = [ .1 .4 .6 .55; .1 .1 .25 .15; .45 .1 .25 .15; .75 .1 .2 .15; .75 .4 .2 .55];

h(1) = uicontrol('Style', 'pushbutton',...
       'Units','normalized',...
       'Position', uipos(2,:),...
       'String', 'START',...
       'FontSize',12,...
       'CallBack', 'StopValveTiming = 0; set(100,''Tag'',''''); delete(findobj(100,''type'',''scatter'')); StimulateFn;');

h(2) = uicontrol('Style', 'pushbutton',...
       'Units','normalized',...
       'Position', uipos(3,:),...
       'String', 'END',...
       'FontSize',12,...
       'CallBack', 'StopValveTiming = 1; set(100,''Tag'',''stop'');');
   
h(3) = uicontrol('Style', 'text',...
       'Units','normalized',...
       'Position', uipos(4,:),...
       'FontSize',12);
   
h(4) = uicontrol('Style', 'listbox',...
       'Units','normalized',...
       'Position', uipos(5,:));

h(5) = subplot('Position',uipos(1,:)); cla; hold on;

userdata.h = h;
userdata.Valve = Valve;
userdata.MVP = MVP;
userdata.Arduino = a;
userdata.PinConfig = PinConfig;
set(gcf,'UserData',userdata);

for v = 1:length(Valve)
    stairs(Valve(v).Program(:,1)/60, (Valve(v).Program(:,2)-0.5)*0.8 + v);
end
set(gca,'YLim',[.25 length(Valve)+.65],'YTick',1:length(Valve));
xlabel('Time (min)'); ylabel('Valve');

if ~isempty(MVP)
    hold on;
    stairs(MVP(:,1)/60, (MVP(:,2)-1)*0.2 - 1, 'r');
    set(gca,'YLim',[-1.1 length(Valve)+.65],'YTick',[-1:.2:0.4,1:length(Valve)]);
    set(gca,'YTickLabel',[[repmat('M',8,1);repmat('V',length(Valve),1)],num2str([1:8,1:length(Valve)]')]);
end

    
%     Valve(v).totalmins = sum(diff(Valve(v).Program(:,1)) .* Valve(v).Program(1:end-1,2)) / 60;
%     text(max(Valve(v).Program(:,1))/60/2,v,[num2str(Valve(v).totalmins),' min'],'FontSize',16);

output = userdata;


% Close valves
if numvalves > 0
    for v = 1:length(PinConfig); 
        writeDigitalPin(a, ['D',num2str(PinConfig(v))], 0); 
    end
end

% set MVP to position 1
if ~isempty(MVP)
    SetHamiltonPosition(1);
end

end % main function


%------------


function closeStimulate(src, ~)
% Safely delete Arduino object stored in figure UserData, then close figure
    if ~isgraphics(src)
        return;
    end

    disp('Window close triggered');

    delete(src);
    disp('Closed window');
    
    clear all
    disp('Cleared all');
   
end

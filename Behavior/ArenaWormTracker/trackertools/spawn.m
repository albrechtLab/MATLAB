% spawn function
%


if ~(exist('SpawnSetting') && isfield(SpawnSetting,'Save') && isfield(SpawnSetting,'Startup'))
    SpawnSetting.Save = 1;
    SpawnSetting.Startup = 'load';
end

if ~isfield(SpawnSetting,'Exit')
    SpawnSetting.Exit = 0;
end

if ~isfield(SpawnSetting,'MatlabFlags')
    SpawnSetting.MatlabFlags = [];
end

if SpawnSetting.Save
    %cd(matlabroot)
    %save;
    cd(TempFolder);
    save('matlab.mat');
    if ~any(strfind(SpawnSetting.Startup,'load'))
        SpawnSetting.Startup = ['load;',SpawnSetting.Startup];
    end
end

Matlabfile = [fullfile(matlabroot,'bin','matlab.exe')];

com = sprintf('!"%s" -nosplash %s -r %s &',Matlabfile,SpawnSetting.MatlabFlags,SpawnSetting.Startup);
%disp(com)
eval(com);

if SpawnSetting.Exit
    exit
end


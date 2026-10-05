function background = getbackground(RawMovieName,method,batchmode,StartFrame,EndFrame,FrameInterval)

%this function adds every "frameinterval" frames and averages to obtain the background
%image
%-----------------------------------------------------------------------
 
MovieObj = VideoReader(RawMovieName);
m = MovieObj.Width;
n = MovieObj.Height;
%cdatasum = zeros(n,m,3,'double'); %for 24-bit movies
 cdatasum = zeros(n,m,'double');   %for 8-bit movies
% Mov = aviread(RawMovieName, 1);
% Movcolormap = Mov.colormap;

%--------modified 1/7/2008 DRA--------
FrameNum = MovieObj.NumberOfFrames;
if nargin < 6, FrameInterval = 20; end
if nargin < 5, EndFrame = FrameNum; end
if nargin < 4, StartFrame = 1; end
%--------end modified-----------------

disp(['Background calculating from ',int2str(StartFrame),' to ',int2str(EndFrame),' in increments of ',int2str(FrameInterval)]);

progbars = 10;
for Frame = StartFrame:FrameInterval:EndFrame
%     tic
%    Frame
    
    Mov = read(MovieObj, Frame);
%     toc
    MovX64 = double(Mov(:,:,2))/255;
    cdatasum = cdatasum + MovX64;
%     Frame
%     imshow(Mov.cdata(:,:,3));
    if mod(Frame * progbars,(EndFrame-StartFrame+1)) < progbars*FrameInterval fprintf(':'); end
end
fprintf('\n');

cdataaverage = cdatasum./round((EndFrame-StartFrame+1)/FrameInterval);
background = uint8(round(cdataaverage*255));

%the following is necessary only if you want to save background image for later re-analysis
if ~batchmode
OriginalFileName = FileInfo.Filename;
[pathstr,name,ext,versn] = fileparts(OriginalFileName);
[FileName,PathName] = uiputfile('*.bmp', 'Save Background Image', name);
    if FileName ~= 0
    imwrite(background,[PathName, FileName], 'bmp');
    end
end

% imshow(background);
% pause;
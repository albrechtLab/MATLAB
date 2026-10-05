%Edge Analysis
for fnum = 1:length(BinFileList)
    EdgeAnalysis20130416fn(char(BinFileList(fnum)));
end

% LocalEdgeAnalysis
for fnum = 1:length(BinFileList)
    Answer = inputdlg({'Genotype','ExcludeBins'}, BinFileList{fnum}, 1, {'N2','[1:60]'},'on');
    
    Info(fnum).Genotype = char(Answer{1});
    Info(fnum).ExcludeBins = str2num(Answer{2});
    Info(fnum).Odors = [];
    Info(fnum).Pattern = [];
    Info(fnum).OdorPattern = [];
    Info(fnum).Round = [];
    Info(fnum).Date = '20100000';
    Info(fnum).AnimalSize = [];
    Info(fnum).Animals = [];
    
    Info(fnum).FullName = BinFileList{fnum};
end

ExperimentDatafromXLS;

clear s
LocalStripeEdgeAnalysis_newspd;
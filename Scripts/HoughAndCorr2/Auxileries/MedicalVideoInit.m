function [infoDB, medicalFile, nFrames] = MedicalVideoInit(pathname, filename)

% Load DICOMDIR index:
infoDB = dicominfo(fullfile(pathname, filename));
Series = GetSeries(infoDB);

% Find TC-Short-Axis series ("Realtime Perfusion"):
base = -1;
for k = 1:length(Series{2})
    if strcmp(Series{2}(k),'TC Short Axis')
        base = k;
        break;
    end
end
if (base < 0)
    error('Could not find TC-Short-Axis series');
end

% Load frames index:
medicalFile = eval(['infoDB.DirectoryRecordSequence.Item_',...
    num2str(Series{1}(base)+1),'.ReferencedFileID']);

% Number of frames:
nFrames = Series{3}(base);
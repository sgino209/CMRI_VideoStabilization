function Series = GetSeries(info)

N = length(fieldnames(info.DirectoryRecordSequence));
SeriesIndices = zeros(N,1);
SeriesTitles  = cell(N,1);
SeriesLengths = zeros(N,1);
count = 1;
len = 0;

for k=1:N
    Item_k = ['info.DirectoryRecordSequence.Item_',num2str(k)];
    
    if strcmp(eval([Item_k,'.DirectoryRecordType']), 'IMAGE')
        len = len + 1;
    end
    
    if strcmp(eval([Item_k,'.DirectoryRecordType']), 'SERIES')
        SeriesIndices(count) = k;
        SeriesTitles{count} = eval([Item_k,'.SeriesDescription']);
        if (count>1)
            SeriesLengths(count-1) = len;
        end

        count = count + 1;
        len = 0;
    end
end

SeriesLengths(count-1) = len;

Series = { SeriesIndices(1:count-1), ...
           SeriesTitles(1:count-1), ...
           SeriesLengths(1:count-1)};
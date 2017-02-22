function [NextDCM_Path,varargout] = GetNextDCM(DB, CurrDCM_info)

% Retrieve CurrDCM parameters:
TGT_SN = CurrDCM_info.SeriesNumber;
TGT_IN = CurrDCM_info.InstanceNumber + 1;

% Retrieve DB DRS:
DB_DRS = DB.DirectoryRecordSequence;
DB_DRS_len = length(fieldnames(DB_DRS));

WakeUp_flag = 0;
WrapAround_flag = 0;

NextDCM_Path = '';
for k=1:DB_DRS_len
    
    DRS = eval(['DB_DRS.Item_',num2str(k)]);
    DRS_Type = DRS.DirectoryRecordType;
        
    % Target Series was found --> WakeUp!
    if strcmp(DRS_Type,'SERIES') && (DRS.SeriesNumber == TGT_SN)
        WakeUp_flag = 1;
    
    % WakeUp search:
    elseif (WakeUp_flag)

        if strcmp(DRS_Type,'IMAGE')
            
            DRS_IN   = DRS.InstanceNumber;
            DRS_Path = DRS.ReferencedFileID;

            % Save path of first DCM for WrapAround scenario:
            if (DRS_IN == 1)
                WrapAround_Path = DRS_Path;
            end

            % Match! --> Return DRS_Path:
            if (DRS_IN == TGT_IN)
                NextDCM_Path = DRS_Path;
                break;
            end
        
        % Return WrapAround path in case CurrDCM is the last one:
        elseif strcmp(DRS_Type,'SERIES')
            NextDCM_Path = WrapAround_Path;
            WrapAround_flag = 1;
            break
        end
    end
end

if (nargout>1)
    if (WrapAround_flag || strcmp(NextDCM_Path,''))
        varargout = {-1};
    else
        varargout = {1};
    end
end
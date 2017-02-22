function [pathname, filename, uBasepath] = GetVideoFileName(Flow)

uBasepath = '../../';

switch Flow.DemoScheme
    
    %===================================================================
    %% Manual user selection:
    case 0      
        [filename, pathname] = uigetfile( ...
            {  'DICOMDIR', 'Medical video (DICOMDIR)'; ...
            '*.avi;*.mpg;*.wmv;*.asf;*.asx','Standard video'; ...
            '*.mp4 ; *.m4v',  'Windows7 only (*.mp4 , *.m4v)'}, ...
            'Pick a file', uBasepath);
    
    %===================================================================
    %% Synthetic #1 ("Hard", w/o noise, w/o deformations):        
    case 1
        filename = 'DemoHard_Full.avi';
        pathname = [uBasepath,'/Tracking/InputVideos/Synthetic/'];
    
    %===================================================================        
    %% Synthetic #2 ("Soft" with noise and with deformations):
    case 2
        filename = 'DemoSoft_Full_WithDeforms_Noise.avi';
        pathname = [uBasepath,'/Tracking/InputVideos/Synthetic/'];
    
    %===================================================================
    %% Synthetic #3 ("Soft Filled", w/o noise, w/o deformations):    
    case 3
        filename = 'DemoSoftFilled.avi';
        pathname = [uBasepath,'/Tracking/InputVideos/Synthetic/'];

    %===================================================================
     %% Synthetic #4 ("Soft Filled" with noise and with deformations):
    case 4
        filename = 'DemoSoftFilled_withDeforms_withNoise.avi';
        pathname = [uBasepath,'/Tracking/InputVideos/Synthetic/'];
    
    %===================================================================
    %% Medical CMRI demo - patient #1 ("Anonymous"):
    case 5
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_12.08.12/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_12.08.12/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_12.08.12/'];
        end
        
    %===================================================================
    %% Medical CMRI demo - patient #2 ("Karni"):
    case 6
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Karni/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Karni/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Karni/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #3 ("Mclean"):
    case 7
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Mclean/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Mclean/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Mclean/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #4 ("Argelazi"):
    case 8
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Argelazi/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Argelazi/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_28.04.13_Argelazi/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #5 ("Arazi"):
    case 9
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Arazi/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Arazi/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Arazi/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #6 ("Dadush"):
    case 10
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Dadush/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Dadush/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Dadush/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #7 ("Eilon"):
    case 11
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eilon/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eilon/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eilon/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #8 ("Eretz"):
    case 12
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eretz/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eretz/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Eretz/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #9 ("Gabai"):
    case 13
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gabai/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gabai/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gabai/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #10 ("Gehi"):
    case 14
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gehi/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gehi/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Gehi/'];
        end
    %===================================================================
    %% Medical CMRI demo - patient #11 ("Stav"):
    case 15
        filename = 'DICOMDIR';
        if strcmp(getenv('COMPUTERNAME'),'IVSOF-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/ShaharG/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Stav/';
        elseif strcmp(getenv('COMPUTERNAME'),'SHAHARG-PC')  % Patch for running from TAU (DropBox issue..)
            pathname = 'D:/Perforce/shaharg/ShaharG_shaharg-PC_1/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Stav/';
        else
            pathname = [uBasepath,'/HDRCompanding/DataBase/MRI/Shiba_MRI_Heart_03.09.13_Stav/'];
        end
        
    %===================================================================
    otherwise
        warning('MATLAB:paramAmbiguous','Unexpected DemoScheme: %s.',Flow.DemoScheme);
end

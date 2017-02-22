function [Params, Flow] = include()

%------------------------------------------------------------------------------------------------------------------------    
%% User Parameters
Params.Rotate        = -pi/32:pi/32:pi/32;   % Complexity (<--> RunTime) is:
Params.Scale         = 0.95:0.05:1.05;       %  O(Rotate*Scale*Offset^2*ContourPts)
Params.Offset        = -7:1:7;
Params.ContourPts    = 50;              % Contour resolution (number of points).
Params.Update_Thr1   = 1.5;             % Threshold for update-contour decision (Max/Mean>Thr1).
Params.Update_Thr2   = 1; %TBD          % Threshold for update-contour decision (Max/Max4>Thr2).
Params.Flush_Thr1    = 1.2;             % Threshold for history-flush decision  (Max/Mean<Thr1).
Params.Flush_Thr2    = 0.15;            % Threshold for history-flush decision  (|1-EdgeDiff|>Thr2).
Params.HistoryWeight = 0; %TBD;         % history weight (0=NoHistory , 1=OnlyHistory).
Params.WinSize       = 11;              % Window size around each of the counter points (for each channel).
Params.FE_Shrink     = 0.8;             % Shrink factor for fine-engine.
Params.FE_Expand     = 1.2;             % Expand factor for fine-engine.
Params.FE_CostMode   = 'ShrinkOnly';    % Cost mode: either 'ShrinkOnly', 'ExpandOnly' or 'NoCostLimit'.
Params.ChannelsEn    = [1 1];           % Enabling mask for the 2 channels: [Contour, Region].

%------------------------------------------------------------------------------------------------------------------------
%% Flow parameters:
Flow.DemoScheme      = 9;              % See "Demos Handling" section below.
Flow.SubMovie        = 1;                 k=Flow.SubMovie;
Flow.StartAtFrm      = max(40*(k-1),1); % Start at a required frame (note that medical slices are 1, 41, 81, ...).        
Flow.StopAtFrm       = 40*(k)-1;        % Stop at a required frame, for "natural-death" use Inf.
Flow.Manual_CA       = 0;               % Manual Contour-Adjust each Manual_CA frames, for None use 0.
Flow.PlotEn          = 1;               % Enable plotting to screen.
Flow.VideoEn         = 1;               % Save result as a video-clip.
Flow.VideoName       = 'Tracking';      % Video-clip name (in case VideoEn=1).
Flow.DebugPlotEn     = 1;               % Enable debug figures.
Flow.DebugPlotAdvEn  = 0;               % Enable advanced debug figures.
Flow.DebugVerboseEn  = 1;               % Enable verbosity prints to command window.
Flow.usePCA_forME    = 0;               % Use PCA for ME stage (boosts timing), o.w. area-similarity is used.
Flow.TempFilt_enable = 0;               % Enable Temporal-Filtering (FT).
Flow.RegionMetric    = 'MSE';          % Metric to be used for region comparison (either 'MSE', 'SSIM' or 'MI').
Flow.CE_usePriors    = 1;               % Use priors for better accuracy of CA_CE core (CMRI TC-ShortAxis).
Flow.FE_useSnake     = 0;               % Use snake for FE non-linear engine.
Flow.CA_FE_enable    = 2;               % 0 = Disable FE, 1 = Enable FE, 2 = Enable FE only upon flush.


%------------------------------------------------------------------------------------------------------------------------
%% Demos Handling:
%------------------------------------------------------------------------------------------------------------------------
switch Flow.DemoScheme   % 0 = NoDemo: user chooses manually a video and sets the initial contour.
                         % 1-4 = Synthetic Demo: 1 - "Hard", w/o noise, w/o deformations.
                         %                       2 - "Soft" with noise and with deformations.
                         %                       3 - "Soft Filled", w/o noise, w/o deformations.
                         %                       4 - "Soft Filled" with noise and with deformations.
                         % 5-15 = Medical CMRI:  5 - patient #1  ("Anonymous").
                         %                       6 - patient #2  ("Karni").
                         %                       7 - patient #3  ("Mclean").
                         %                       8 - patient #4  ("Argelazi").
                         %                       9 - patient #5  ("Arazi").
                         %                      10 - patient #6  ("Dadush").
                         %                      11 - patient #7  ("Eilon").
                         %                      12 - patient #8  ("Eretz").
                         %                      13 - patient #9  ("Gabai").
                         %                      14 - patient #10 ("Gehi").
                         %                      15 - patient #11 ("Stav").
    %========================================================================================================================
    case 1
        %% DEMO #1:  Synthetic #1 - "Hard", w/o noise, w/o deformations:
        Flow.DemoContour = [170, 171, 202, 254, 277, 271, 243, 190, 170 ; ...
                            171, 142, 130, 135, 153, 180, 203, 197, 171 ];
    %========================================================================================================================
    case 2
        %% DEMO #2:  Synthetic #2 - "Soft" with noise and with deformations:
        Flow.DemoContour = [172, 175, 196, 239, 254, 250, 227, 188, 172 ; ...
                            173, 147, 127, 132, 158, 179, 192, 185, 173 ];
    %========================================================================================================================
    case 3
        %% DEMO #3:  Synthetic #3 - "Soft Filled", w/o noise, w/o deformations:
        Flow.DemoContour = [178, 196, 236, 257, 257, 241, 199, 182, 178 ; ...
                            152, 128, 125, 147, 168, 184, 188, 178, 152 ];
    %========================================================================================================================
    case 4
        %% DEMO #4:  Synthetic #4 - "Soft Filled" with noise and with deformations:
        Flow.DemoContour = [173, 188, 227, 249, 250, 237, 196, 178, 173 ; ...
                            157, 135, 129, 147, 167, 184, 190, 182, 157];
    %========================================================================================================================
    case 5
        %% DEMO #5:  Medical CMRI demo - patient #1 ("Anonymous"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 93, 142, 155, 163, 165, 165, 163, 159, 149, 136, 123, 111, 102,  95,  89,  93 ;
                                    132, 148, 144, 135, 125, 115,  98,  88,  81,  77,  79,  88,  96, 106, 121, 132 ];
            case 2
                Flow.DemoContour = [ 89, 134, 149, 160, 163, 160, 145, 127, 117, 101,  90,  89
                                    136, 145, 146, 137, 120, 105,  92,  82,  84, 100, 118, 136];                         
            case 3
                Flow.DemoContour = [ 92, 103, 120, 141, 153, 164, 168, 168, 166, 156, 147, 127, 119, 108,  96,  89,  89,  92 ;
                                    135, 135, 139, 145, 144, 140, 133, 125, 112,  99,  94,  85,  85,  96, 107, 118, 125, 135 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 6
        %% DEMO #6:  Medical CMRI demo - patient #2 ("Karni"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 81, 107, 124, 145, 160, 162, 161, 157, 147, 138, 125, 108, 102, 101,  90,  80,  68,  53,  57,  68,  81 ;
                                    145, 151, 156, 155, 146, 132, 119, 108,  92,  79,  71,  67,  70,  87, 104, 118, 134, 149, 152, 149, 145 ];
            case 2
                Flow.DemoContour = [ 65,  82,  98, 111, 138, 148, 160, 164, 164, 160, 153, 147, 134, 116, 100,  91,  80,  72,  68,  65 ;
                                    147, 146, 148, 150, 153, 151, 143, 132, 120, 111, 103,  97,  93,  92,  91,  97, 112, 128, 139, 147 ];
            case 3
                Flow.DemoContour = [ 90, 111, 122, 135, 153, 161, 162, 161, 146, 134, 114, 104,  95,  89,  85,  90 ;
                                    144, 147, 149, 149, 144, 139, 121, 111,  99,  94,  94,  98, 109, 126, 145, 144 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 7
        %% DEMO #7:  Medical CMRI demo - patient #3 ("Mclean"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 57,  63,  74,  79,  96, 113, 128, 139, 148, 152, 152, 150, 146, 143, 136, 121, 108, 100,  90,  81,  74,  70,  57,  53,  57 ;
                                    140, 136, 132, 131, 139, 145, 150, 147, 136, 124, 114, 105,  93,  80,  75,  73,  73,  79,  89, 102, 110, 121, 128, 133, 140 ];        
            case 2
                Flow.DemoContour = [ 55,  63,  73,  86, 106, 119, 129, 139, 149, 154, 154, 151, 150, 143, 126, 113,  99,  86,  75,  71,  68,  60,  55,  55 ;
                                    144, 140, 137, 139, 145, 150, 152, 149, 139, 126, 116, 108,  98,  90,  81,  77,  83,  95, 108, 120, 126, 129, 136, 144 ];
            case 3
                Flow.DemoContour = [ 60,  73,  82,  98, 118, 125, 136, 145, 154, 155, 154, 146, 140, 127, 114, 100,  93,  86,  78,  73,  65,  60 ;
                                    140, 135, 135, 141, 150, 153, 151, 145, 137, 126, 117, 105,  96,  87,  81,  82,  92, 101, 111, 124, 127, 140 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 8
        %% DEMO #8:  Medical CMRI demo - patient #4 ("Argelazi"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 81, 101, 113, 123, 131, 140, 148, 150, 148, 137, 132, 120, 107, 105, 110,  95,  84,  79,  78,  78,  81 ;
                                    139, 150, 150, 152, 152, 148, 137, 121, 101,  84,  79,  75,  73,  76,  84,  92, 104, 114, 124, 135, 139 ];
            case 2
                Flow.DemoContour = [ 85,  97, 114, 132, 143, 149, 152, 148, 139, 135, 119, 111, 104,  93,  87,  80,  75,  85 ;
                                    142, 148, 151, 151, 150, 137, 120, 106,  97,  90,  82,  81,  86,  96, 103, 118, 131, 142 ];
            case 3
                Flow.DemoContour = [ 87,  97, 113, 124, 134, 145, 152, 153, 151, 148, 140, 132, 126, 117, 108,  99,  87,  80,  75,  81,  87 ;
                                    142, 146, 149, 149, 147, 144, 133, 119, 113, 106,  99,  91,  87,  84,  83,  93, 104, 117, 129, 134, 142 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 9
        %% DEMO #9:  Medical CMRI demo - patient #5 ("Arazi"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [141, 139, 139, 147, 157, 166, 176, 192, 212, 244, 277, 293, 304, 308, 307, 289, 265, 237, 212, 183, 163, 141 ;
                                    288, 275, 262, 243, 226, 212, 197, 188, 181, 187, 204, 221, 240, 270, 287, 309, 317, 320, 317, 309, 301, 288 ];
            case 2
                Flow.DemoContour = [140, 198, 230, 275, 309, 325, 319, 279, 240, 205, 169, 153, 137, 130, 140 ;
                                    296, 306, 312, 307, 298, 261, 236, 209, 199, 200, 211, 222, 251, 276, 296 ];
            case 3
                Flow.DemoContour = [187, 221, 254, 281, 299, 301, 300, 292, 230, 175, 176, 187 ;
                                    242, 220, 211, 224, 241, 268, 289, 296, 307, 292, 257, 242 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 10
        %% DEMO #10:  Medical CMRI demo - patient #6 ("Dadush"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 75,  89, 100, 113, 131, 158, 160, 147, 135, 117,  94,  83,  75 ;
                                    128, 135, 146, 154, 154, 140, 118, 102,  95,  94, 103, 114, 128 ];
            case 2
                Flow.DemoContour = [ 72,  84,  98, 122, 131, 150, 163, 166, 157, 144, 119, 105,  85,  73,  72 ;
                                    123, 135, 152, 155, 156, 148, 137, 120, 102,  93,  84,  85,  95, 113, 123 ];
            case 3
                Flow.DemoContour = [ 81,  83,  87, 100, 117, 132, 154, 158, 158, 154, 138, 130, 111, 100,  89,  81 ;
                                    127, 114, 101,  93,  89,  88,  99, 112, 129, 140, 147, 150, 147, 146, 140, 127 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 11
        %% DEMO #11:  Medical CMRI demo - patient #7 ("Eilon"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 76,  94, 129, 147, 156, 151, 139, 120, 101,  89,  77,  76 ;
                                    135, 146, 144, 130, 112,  95,  85,  84,  91, 101, 116, 135 ];
            case 2
                Flow.DemoContour = [ 75, 101, 115, 144, 151, 152, 147, 133, 113, 95,  80,  73,  75 ;
                                    136, 153, 157, 149, 133, 107,  90,  86,  84, 95, 109, 122, 136 ];
            case 3
                Flow.DemoContour = [ 77, 101, 120, 142, 155, 156, 150, 135, 109,  84,  75,  77 ;
                                    138, 153, 158, 153, 143, 124,  98,  87,  87, 102, 117, 138 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 12
        %% DEMO #12:  Medical CMRI demo - patient #8 ("Eretz"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 72,  82, 101, 120, 141, 153, 152, 145, 127, 109,  84,  67,  72 ;
                                    147, 148, 155, 161, 158, 143, 126, 113, 105, 106, 125, 142, 147 ];
            case 2
                Flow.DemoContour = [ 73, 103, 135, 148, 161, 156, 149, 117,  88,  71,  71,  73 ;
                                    142, 154, 157, 154, 136, 117, 103,  92, 102, 122, 139, 142 ];
            case 3
                Flow.DemoContour = [ 74, 103, 126, 147, 157, 151, 138, 116, 93,  78,  69,  74 ;
                                    140, 151, 157, 155, 136, 117,  99,  87, 89, 106, 126, 140 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 13
        %% DEMO #13:  Medical CMRI demo - patient #9 ("Gabai"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [100, 121, 140, 160, 171, 176, 170, 158, 140, 117,  99,  84, 100 ;
                                    133, 139, 139, 138, 129, 113,  92,  78,  73,  84, 104, 123, 133 ];
            case 2
                Flow.DemoContour = [ 99, 134, 155, 174, 179, 174, 161, 142, 122, 102,  88,  96,  99 ;
                                    131, 143, 149, 142, 121, 101,  82,  75,  85, 102, 119, 129, 131 ];
            case 3
                Flow.DemoContour = [ 99, 130, 157, 171, 171, 165, 153, 138, 115,  99,  88,  99 ;
                                    130, 145, 145, 133, 115,  98,  87,  83,  94, 108, 120, 130 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 14
        %% DEMO #14:  Medical CMRI demo - patient #10 ("Gehi"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 91, 116, 142, 160, 173, 173, 167, 159, 136, 104, 93,  81,  76,  91 ;
                                    142, 154, 157, 155, 137, 114,  98,  78,  64,  69, 92, 108, 127, 142 ];
            case 2
                Flow.DemoContour = [ 85, 124, 147, 168, 174, 168, 146, 127, 104, 95,  83,  78,  85 ;
                                    139, 149, 149, 140, 118,  88,  70,  66,  74, 91, 112, 129, 139 ];
            case 3
                Flow.DemoContour = [ 87, 113, 143, 161, 172, 172, 158, 139, 116, 101,  87,  80,  87 ;
                                    137, 148, 147, 143, 131, 110,  91,  77,  73,  79, 103, 121, 137 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    case 15
        %% DEMO #15:  Medical CMRI demo - patient #11 ("Stav"):
        switch Flow.SubMovie
            case 1
                Flow.DemoContour = [ 78,  96, 132, 149, 159, 155, 147, 134, 119, 102,  92,  77,  78 ;
                                    142, 152, 155, 152, 134, 115, 105,  93,  87,  90, 102, 119, 142 ];
            case 2
                Flow.DemoContour = [ 76, 100, 129, 148, 158, 155, 145, 122, 108, 95,  83,  75,  76 ;
                                    140, 150, 156, 149, 136, 114, 102,  90,  88, 96, 111, 122, 140 ];
            case 3
                Flow.DemoContour = [ 82, 109, 134, 149, 158, 155, 145, 127, 114, 101,  94,  84,  78,  82 ;
                                    144, 154, 156, 149, 138, 119, 111,  99,  92,  98, 109, 120, 130, 144 ];
            otherwise
                warning('MATLAB:paramAmbiguous','Unexpected SubMovie: %d',k);
        end
    %========================================================================================================================
    otherwise
        Flow.DemoContour = -1;
end

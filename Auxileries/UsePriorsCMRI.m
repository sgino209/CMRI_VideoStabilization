function [Rotation, Line] = UsePriorsCMRI(Contour, I, Flow)

xmin   = 0.85 * min(Contour(1,:));
ymin   = 0.85 * max(Contour(2,:));
width  = 1.2 * ( max(Contour(1,:)) - min(Contour(1,:)) );
height = 30;
rect   = [ xmin ymin width height ];

[Rotation,Line_pre] = HoughEngine4ROI(I, rect, Flow);

Line = Line_pre + repmat(round([xmin,ymin]),2,1);

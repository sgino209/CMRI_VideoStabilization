function Contour_out = RotateScaleOffsetContour(Contour, R, S, dx, dy)

N = length(Contour);

center = CalcContourCentroid(Contour);
centerX = center(1);
centerY = center(2);

Rotation_Matrix = [cos(R) , -sin(R) , centerX*(1-cos(R))+centerY*sin(R) ; ...
                   sin(R) ,  cos(R) , centerY*(1-cos(R))-centerX*sin(R) ; ...
                     0         0                      1                 ];

ContourXY_Rot = round( Rotation_Matrix * [Contour ; ones(1,N)] );

ContourX_out = centerX + round( S*(ContourXY_Rot(1,:)-centerX) ) + dx;
ContourY_out = centerY + round( S*(ContourXY_Rot(2,:)-centerY) ) + dy;

Contour_out = round( [ContourX_out ; ContourY_out] );

function center = CalcContourCentroid(Contour)

ContourX = Contour(1,:);
ContourY = Contour(2,:);

B = ContourX(1:end-1) .* ContourY(2:end) - ContourX(2:end) .* ContourY(1:end-1);

A = sum(B) / 2;

Cx = sum( (ContourX(1:end-1) + ContourX(2:end)) .* B ) / (6*A);
Cy = sum( (ContourY(1:end-1) + ContourY(2:end)) .* B ) / (6*A);

center = [round(Cx), round(Cy)];
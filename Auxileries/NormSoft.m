function out = NormSoft(in)

if (sum(in,2) == 0)
	out = in;
else
	out = in ./ repmat(sum(abs(in),2),1,size(in,2));
end
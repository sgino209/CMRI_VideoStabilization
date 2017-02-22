function out = NormHard(in)

N = size(in,2);

out = in - repmat(min(in,[],2),1,N);
out = out ./ repmat(max(out,[],2),1,N);

out(isnan(out))=0;
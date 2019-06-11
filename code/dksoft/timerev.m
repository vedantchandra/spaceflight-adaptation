function res = timerev(x,lag)
% res = timerev(x,lag) calculates a time reversal asymmetry statistic.
% x --- the time series
% lag --- a time scale (in samples) default 1
% Copyright (c) 1996 by D. Kaplan, All Rights Reserved

if nargin < 2
  lag = 1;
end

foo = lagembed(x,3,lag);
a = foo(:,1);
b = foo(:,2);
c = foo(:,3);

res = mean( a.*a.*b - b.*c.*c);
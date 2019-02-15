function [yM,lagV] = LagDifference(xV,lagV)
% yV = LagDifference(xV,lagV)
% LAGDIFFERENCE takes a time series 'xV' and computes the time series 'yV'
% of the differences at given lags in 'lagV', i.e. y(t)=x(t)-x(t-lag),
% t=lag+1,...n, where 'n' is the length of 'xV' and 'lag' is a component of
% 'lagV'. 
% INPUTS:
% - xV      : vector of a scalar time series
% - lagV    : vector of lags (can be a single lag as well)
% OUTPUTS:
% - yM      : a matrix of the lag differenced time series.
% - lagV    : the vector of valid lags (in case given lags are <=0)
%========================================================================
%     <LagDifference.m>, v 1.0 2010/02/11 22:09:14  Kugiumtzis & Tsimpiris
%     This is part of the MATS-Toolkit http://eeganalysis.web.auth.gr/

%========================================================================
% Copyright (C) 2010 by Dimitris Kugiumtzis and Alkiviadis Tsimpiris 
%                       <dkugiu@gen.auth.gr>

%========================================================================
% Version: 1.0

% The FreeBSD Copyright:	
% Copyright 1992-2012 The FreeBSD Project. All rights reserved.	

% Redistribution and use in source and binary forms, with or without modification, 
% are permitted provided that the following conditions are met:	

% Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.	
% Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.	

% "THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS' AND ANY EXPRESS OR IMPLIED WARRANTIES,
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
% OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
% ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
% IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."

% The views and conclusions contained in the software and documentation are those of the authors and should not
% be interpreted as representing official policies, either expressed or implied, of the FreeBSD Project.

%=========================================================================
% Reference : D. Kugiumtzis and A. Tsimpiris, "Measures of Analysis of Time Series (MATS): 
% 	          A Matlab  Toolkit for Computation of Multiple Measures on Time Series Data Bases",
%             Journal of Statistical Software, Vol. 33, Issue 5, 2010
% Link      : http://eeganalysis.web.auth.gr/
%========================================================================= 

 
xV = xV(:);
n = length(xV);
lagV = lagV(lagV>0 & lagV<n/2);
if isempty(lagV) 
    yM=[];
else
    nlag = length(lagV);
    yM = NaN*ones(n,nlag);
    for ilag=1:nlag
        yM(1:n-lagV(ilag),ilag) = xV(lagV(ilag)+1:n)-xV(1:n-lagV(ilag));
    end
end
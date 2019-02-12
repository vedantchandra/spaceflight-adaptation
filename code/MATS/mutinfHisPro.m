function mutV=mutinfHisPro(xV,tauV,b,ioxV,ixV)
% mutV=mutinfHisPro(xV,tauV,b,ioxV,ixV)
% mutinfHisPro computes the mutual information on the time series 'xV' 
% for given delays in 'tauV'. The estimation of mutual information is 
% based on 'b' partitions of equal probability at each dimension. 
% The last two input parameters are the ordered time series and the
% corresponding indices that will be used in the equiprobable binning 
% (they both have been computed before and therefore they are passed 
% here rather than computing it again).
%========================================================================
%     <mutinfHisPro.m>, v 1.0 2010/02/11 22:09:14  Kugiumtzis & Tsimpiris
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

 
n = length(xV);
ntau = length(tauV);
mutV = NaN*ones(ntau,1);
hM = NaN*ones(b,b);
cumhM = zeros(b,b+1);  
cpxV = [1/b:1/b:1]';
for itau=1:ntau
    tau = tauV(itau);
    ntotal = n-tau;    
    rxV = [0;round(cpxV*ntotal)];
    ix1V = ixV;
    ix1V(ioxV(end-tau+1:end)) = [];
    x2prV = prctile(xV(ix1V+tau),cpxV*100);
    for i = 1:b
        for j = 1:b
            cumhM(i,j+1) = length(find(xV(ix1V(rxV(i)+1:rxV(i+1))+tau)<=x2prV(j)));
        end
        hM(i,:) = diff(cumhM(i,:));
    end
    % The use of formula H(x)=1, when log_b is used.
    mutS = 2;
    for j=1:b
        for i=1:b
            if hM(i,j) > 0
                mutS=mutS+(hM(i,j)/ntotal)*log(hM(i,j)/ntotal)/log(b);
            end
        end
    end 
    mutV(itau) = mutS;
end

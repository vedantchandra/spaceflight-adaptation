%========================================================================
%     <imgfreeplotbutton.m>, v 1.0 2010/02/11 22:09:14  Kugiumtzis & Tsimpiris
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

 
clear all
ndata = 5;
nmea = 3;
randn('state',0);
meaM = randn(ndata,nmea);
buttonsize = [150 120];

h = figure(1);
clf
axes('position',[0.12 0.16 0.80 0.65])
h1 = plot(meaM(:,1),'o-','Markersize',10,'linewidth',3);
hold on
plot(meaM(:,2),'x--k','Markersize',10,'linewidth',3)
plot(meaM(:,3),'+-.r','Markersize',10,'linewidth',3)
set(gca,'XTickLabelMode','Manual');
set(gca,'XTickLabel',num2str([1:ndata]'));
set(gca,'XTickMode','Manual');
set(gca,'XTick',[1:ndata]');
set(gca,'YTickLabelMode','Manual');
set(gca,'YTickLabel','');
set(gca,'YTickMode','Manual');
set(gca,'YTick',[]);
leg = legend('measure 1','measure 2','measure 3','location','NorthEastOutside');
set(leg,'EdgeColor',[1 1 1])
set(leg,'FontSize',24)
legpos = get(leg,'Position');
ax = axis;
dyax = 0.1*(ax(4)-ax(3));
text(5.2,ax(3)+4*dyax,'1: time series 1','fontsize',24)
text(5.2,ax(3)+3*dyax,'2: time series 2','fontsize',24)
text(5.2,ax(3)+2*dyax,'3: time series 3','fontsize',24)
text(5.2,ax(3)+dyax,'4: time series 4','fontsize',24)
text(5.2,ax(3),'5: time series 5','fontsize',24)
xlabel('time series index','fontsize',50)
ylabel('measure','fontsize',50)
title('free plot','fontsize',80)
% print -r300 -djpeg90 buttonfreeplot.jpg
print -r300 -dbmp buttonfreeplot.bmp

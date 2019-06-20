function out = ichimoku(name,month)
% Tenkan-Sen (Conversion Line ) = (Highest High + Lowest Low) / 2, for the past x periods 
% Kijun-Sen (Base Line) = (Highest High + Lowest Low) / 2, for the past y periods
% Chikou Span (Lagging Span) = Today's closing price plotted y periods behind 
% Senkou Span A = (Tenkan-Sen + Kijun-Sen) / 2, plotted y periods ahead
% Senkou Span B = (Highest High + Lowest Low) / 2, for the past z periods, plotted y periods ahead 
if nargin==0
    name = 'Mobarakeh Steel-a';
    month = 12;
end
% format short;
tenkansenp=9; % x periods
kijunsenp=26; % y periods
chikouspanp=52; % z periods
chartprices=[]; % price array width prices+kijunsenp length
tenkansen=[];
kijunsen=[];
chikouspan=[];
senkouspana=[];
senkouspanb=[];
[prices,dates,datesStr,volumes,openes,highes,lowes]=opencsv2(strcat('csv/',strcat(name,'.csv')),month);
for i=1:length(prices)+kijunsenp
   chartprices(i)=NaN;
   chartlowes(i)=NaN;
   charthighes(i)=NaN;
   chartopenes(i)=NaN;
   tenkansen(i)=NaN;
   kijunsen(i)=NaN;
   chikouspan(i)=NaN; 
   senkouspana(i)=NaN;
   senkouspanb(i)=NaN;
end  


for i=1:length(prices)
    % prices
    chartprices(i)=prices(i);
    chartlowes(i)=lowes(i);
    charthighes(i)=highes(i);
    chartopenes(i)=openes(i);
    % tenken sen    
    tenkansen(i)=(highesthight(highes,tenkansenp,i)+lowestlow(lowes,tenkansenp,i))/2;
    % kijun sen
    kijunsen(i)=(highesthight(highes,kijunsenp,i)+lowestlow(lowes,kijunsenp,i))/2;
    % chikou span
    if i>chikouspanp
         chikouspan(i-chikouspanp)=prices(i);
    end
    % Senkou Span A
    senkouspana(i+kijunsenp)=(tenkansen(i)+kijunsen(i))/2;
    % Senkou Span B
    senkouspanb(i+kijunsenp)=(highesthight(highes,chikouspanp,i)+lowestlow(lowes,chikouspanp,i))/2;
end
x=[1:length(dates)+kijunsenp];

% exterm min , max
% [xmax,imax,xmin,imin] = extrema(chartprices);
%  plot(imax,xmax,'mo','MarkerFaceColor', 'g','MarkerSize',10)
% hold on;
%  plot(imin,xmin,'mo','MarkerFaceColor', 'r','MarkerSize',10)
% hold on;


% draw line between two line
% p1=1;
% p2=11;
% plot([imax(p1),imax(p2)],[xmax(p1),xmax(p2)],'Color','r','LineWidth',2)

% cross tenkensen m kijunsen / Collision -> buy sell signal
[xout,yout] = curveintersect(x,tenkansen,x,kijunsen);
for i=1:length(xout)-1
    if (xout(i)+1)~=xout(i+1)
        if tenkansen(round(xout(i))+1) > kijunsen(round(xout(i))+1)
            plot(xout(i),yout(i),'go','MarkerFaceColor', 'g','MarkerSize',10);hold on;
        else
            plot(xout(i),yout(i),'ro','MarkerFaceColor', 'r','MarkerSize',10);hold on;
        end
    end
end

% drow chart
% % scrollplot;
candle(charthighes', chartlowes', chartprices',chartopenes', 'k');
hold on;
plot(x,tenkansen,'r-');
hold on;
plot(x,kijunsen,'b-');
hold on;
plot(x,chikouspan,'g-');
hold on;
plot(x,senkouspana,'Color',[.7 .5 0]);
hold on;
plot(x,senkouspanb,'Color',[0.5 0.5 0.5]);
hold on;
% fill komu
for i=1:length(senkouspanb)-1
    if senkouspanb(i)~=NaN
        f=i;
        t=i+1;
        x=f:1:t;                  %#initialize x array
        y1=senkouspana(f:t);                      %#create first curve
        y2=senkouspanb(f:t);                   %#create second curve
        X=[x,fliplr(x)];                %#create continuous x value array for plotting
        Y=[y1,fliplr(y2)];              %#create y values for out and then back
        if senkouspana(i)>senkouspanb(i) fill(X,Y,[.7 .5 0],'EdgeColor','none','facealpha',.5,'linewidth',1);  else fill(X,Y,[0.5 0.5 0.5],'EdgeColor','none','facealpha',.5,'linewidth',1); end
    end
end
hold on;



aa=[];
for i=1:7
    aa(i)=floor(length(dates)/7)*i;
end
ax = gca;
set(ax,'XTick',aa)

bb=[];
for i=1:length(aa)
    bb(i)=dates(aa(i));
end
set(gca,'Xticklabel',datestr(bb,'mm/dd'));

dcm = datacursormode(gcf);
datacursormode on;
set(dcm, 'updatefcn', {@myupdatefcn,dates})


 %camroll(90); %rotate plot
 

 


% update data cursor
function output_txt = myupdatefcn( obj,event_obj,dates)
dataIndex = get(event_obj,'DataIndex');
pos = get(event_obj,'Position');

output_txt = {[ 'X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

try
    p=get(event_obj,'Target');
    output_txt{end+1} = ['Date: ',datestr((dates(round(pos(1)))))];
end

% highest hight
function out=highesthight(array,period,index)
    out=0;
    for i=index-period:index
        if i>0
            if array(i)>out
                out=array(i);
            end
        end    
    end
% lowest low
function out=lowestlow(array,period,index)
    out=10000000;
    for i=index-period:index
        if i>0
            if array(i)<out
                out=array(i);
            end
        end    
    end    

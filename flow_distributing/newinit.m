clear all;
global nodenum
global linknum
global flowsnum
global lidu
lidu=1;
nodenum=100;
linknum=1000;
flowsnum=1000;
passlinknum=1;
passnodenum=1;

%生成数据的规模
linkdelay=rand(1,linknum)/2; %w1,时延
linkpassratio=0.95+rand(1,linknum)/20; %w2,传包率
linkjitter=rand(1,linknum)/2; %w3,抖动
linkbandwidth=ceil(2*(1+2*rand(1,linknum))); %带宽
flowmaxdelay=3+rand(1); %flow的最大延迟
flowminpassratio=0.5+rand(1)/10;%flow的最小传包率
flowmaxjitter=5+rand(1); %flow的最大抖动
flowbandwidth=ceil(6*(1+rand(1))); %flow的带宽
%初始化点数据

flowsfrom=ceil(nodenum*rand(1,flowsnum));
flowsto=ceil(nodenum*rand(1,flowsnum));


for i=1:nodenum
    node{i}.id=i;
end

for i=1:passlinknum
    passlink(i)=ceil(linknum*rand());
end

for i=1:passnodenum
    passnode(i)=ceil(nodenum*rand());
end

%初始化link数据
%初始化一个0,1邻接矩阵表示连通情况
 A=createMap(nodenum,linknum); 
 w=0;
 
 for i=1:nodenum
     for j=1:nodenum
         if(A(i,j)==1)
             w=w+1;
             linkfromnode(w)=i;%每一条边的起点
             linktonode(w)=j;%每一条边的终点
         end
     end
 end
 
 for i=1:linknum
     link{i}.id=i;
     link{i}.fromnode=linkfromnode(i);
     link{i}.tonode=linktonode(i);
     link{i}.w1=linkdelay(i);
     link{i}.w2=1-linkpassratio(i);%丢包率
     link{i}.w3=linkjitter(i);
     link{i}.bandwidth=linkbandwidth(i);
     link{i}.cost=100*rand();
     link{i}.realcost=link{i}.cost;
     link{i}.restbandwidth=linkbandwidth(i);
 end

%初始化flow数据
flow.fromnode=ceil(nodenum*rand());
flow.tonode=ceil(nodenum*rand());

if (flow.tonode==flow.fromnode)
    flow.tonode=ceil(nodenum*rand());
end
flow.pathnum=0;
flow.path=[];
flow.pathp=[flow.tonode];
flow.sumw1=0;
flow.prow2=0;
flow.sumw3=0;
flow.sumcost=0;
flow.realcost=0;
flow.bandwidth=flowbandwidth;
flow.maxdelay=flowmaxdelay;
flow.maxlossratio=1-flowminpassratio;
flow.maxjitter=flowmaxjitter;
flow.rank=ceil(7*rand());
flow.div=0;


Mapcost=zeros(nodenum,nodenum);
Mapw1=zeros(nodenum,nodenum);
Mapw2=zeros(nodenum,nodenum);
Mapw3=zeros(nodenum,nodenum);
Mapbw=zeros(nodenum,nodenum);
linjieLINK=zeros(nodenum,nodenum);
for i=1:linknum
    Mapcost(link{i}.fromnode,link{i}.tonode)=link{i}.cost;%路线A->B的带宽
    Mapw1(link{i}.fromnode,link{i}.tonode)=link{i}.w1;
    Mapw2(link{i}.fromnode,link{i}.tonode)=link{i}.w2;
    Mapw3(link{i}.fromnode,link{i}.tonode)=link{i}.w3;
    Mapbw(link{i}.fromnode,link{i}.tonode)=link{i}.restbandwidth;
    linjieLINK(link{i}.fromnode,link{i}.tonode)=i;%路线A->B是哪个link
end

%初始化flows数据
for i=1:flowsnum
    flows{i}.fromnode=flowsfrom(i);
    if flowsto(i)~=flowsfrom(i)
        flows{i}.tonode=flowsto(i);
    else
        flows{i}.tonode=flowsto(i)+1;
    end
    flows{i}.pathnum=0;
    flows{i}.path=[];
    flows{i}.pathp=[flows{i}.tonode];
    flows{i}.sumw1=0;
    flows{i}.prow2=0;
    flows{i}.sumw3=0;
    flows{i}.sumcost=0;
    flows{i}.realcost=0;
    flows{i}.bandwidth=0;
    Map=Mapcost;
    for k=1:nodenum
        for j=1:nodenum
            if (Map(k,j)==0)
                Map(k,j)=999999;
            end
        end
    end
    [f,flo,lin]=dij(flows{i},Map,link,linjieLINK);
    flows{i}.maxdelay=rand()+flo.sumw1*(2+rand())+1;
    flows{i}.maxlossratio=flo.prow2*(1+rand())+0.2;
    flows{i}.maxjitter=flo.sumw3*(1+rand())+1;
    minband=99999;
    for k=1:length(flo.path)
        if(minband>link{flo.path(k)}.restbandwidth)
            minband=link{flo.path(k)}.restbandwidth;
        end
    end
    flows{i}.bandwidth=minband;
    for k=1:length(flo.path)
        link{flo.path(k)}.restbandwidth=link{flo.path(k)}.restbandwidth-flows{i}.bandwidth;
    end
    flows{i}.pathnum=flo.pathnum;
    flows{i}.path=flo.path;
    flows{i}.pathp=flo.pathp;
    flows{i}.sumw1=flo.sumw1;
    flows{i}.prow2=flo.prow2;
    flows{i}.sumw3=flo.sumw3;
    flows{i}.sumcost=flo.sumcost;
    flows{i}.realcost=flo.sumcost;
    flows{i}.rank=ceil(7*rand());
    flows{i}.div=0;
end

sumhe=0.0;
for i=1:linknum
    sumhe=sumhe+(link{i}.bandwidth-link{i}.restbandwidth)/link{i}.bandwidth;
end
disp(['占用率:' num2str(sumhe/linknum)])
save chushijuzhen.mat
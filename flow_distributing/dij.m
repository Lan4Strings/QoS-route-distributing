function [f,flo,lin]=dij(flow,Map,link,linjieLINK)%Map为邻接矩阵，值为总权重，无数字为9999999
s=flow.fromnode;
t=flow.tonode;
n=size(Map,1);
visit=zeros(1,n);%已访问节点记录
visit(s)=1;
for i=1:n
    D(i)=Map(s,i);
    linkpre(i)=linjieLINK(s,i);%每个节点的Pre边,用于记录最短路径
    pre(i)=s;%每个节点的Pre点,用于记录最短路径
end
D(s)=0;
%dij算法
next=s;
for i=1:n
    min=999999999;
    for j=1:n
        if(visit(j)==0)
            if(D(j)<min)
                min=D(j);
                next=j;
            end
        end
    end
    visit(next)=1;
    for j=1:n
        if((D(next)+Map(next,j))<D(j))
            D(j)=D(next)+Map(next,j);
            pre(j)=next;
            linkpre(j)=linjieLINK(next,j);
        end
    end
end

tempt=t;

%写入新的记录
while(tempt~=s)
    if(linkpre(tempt)==0)
        break;
    end
    flow.path=[linkpre(tempt) flow.path];
    flow.pathp=[link{linkpre(tempt)}.fromnode flow.pathp];
    flow.pathnum=flow.pathnum+1;
    tempt=pre(tempt);
end

for i=1:flow.pathnum
    flow.sumw1=flow.sumw1+link{flow.path(i)}.w1;
    flow.prow2=1-(1-flow.prow2)*(1-link{flow.path(i)}.w2);%丢包率
    flow.sumw3=flow.sumw3+link{flow.path(i)}.w3;
    flow.sumcost=flow.sumcost+link{flow.path(i)}.cost;
    flow.realcost=flow.realcost+link{flow.path(i)}.realcost;
end




flo=flow;
%lin=Map;
lin=link;
f=D(t);
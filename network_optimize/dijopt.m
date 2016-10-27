%对数据流编号为fl的数据进行单链路优化
%优化方案为带权重dij，不满足约束则更改权重直到满足


function [f,flo,lin]=dijopt(flow,link,linjieLINK,n,fl,GG,cost)%输入为数据流结构，网络结构，网络连通状态，节点数,待优化数据流，基于花费的权值矩阵，总花费
flo=flow;
lin=link;
s=flow{fl}.fromnode;%起点
t=flow{fl}.tonode;%终点
temp=flow{fl}.pathnum;
bandwidth=flow{fl}.bandwidth;

%剔除路径
for i=1:temp
    link{flow{fl}.path(i)}.unbandwidth=link{flow{fl}.path(i)}.unbandwidth+bandwidth;
end
G=GG;
for i=1:n
    for j=1:n
        if(linjieLINK(i,j)~=0)
        if(link{linjieLINK(i,j)}.unbandwidth<bandwidth)%删除带宽不满足的边
            G(i,j)=999999;
        end
        end
    end
end


visit=zeros(n);%已访问节点记录
visit(s)=1;
for i=1:n
    D(i)=G(s,i);
    linkpre(i)=linjieLINK(s,i);%每个节点的Pre边,用于记录最短路径
    pre(i)=s;%每个节点的Pre点,用于记录最短路径
end
D(s)=0;

%dij算法
for i=1:n
    next=s;
    min=999999;
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
        if((D(next)+G(next,j))<D(j))
            D(j)=D(next)+G(next,j);
            pre(j)=next;
            linkpre(j)=linjieLINK(next,j);
        end
    end
end

sumdelay=0;
sumpassratio=1;
sumcost=0;
f=D(t);


%判断是否满足约束条件
    if(D(t)~=999999)
        tempt=t;
        while(tempt~=s)
            %[fl s t linkpre(tempt)]
            sumdelay=sumdelay+link{linkpre(tempt)}.delay;
            sumcost=sumcost+link{linkpre(tempt)}.cost*bandwidth;
            sumpassratio=sumpassratio*(1-link{linkpre(tempt)}.lossratio);
            tempt=pre(tempt);
            
        end
        if (sumdelay>flow{fl}.maxdelay)
            display('delay:');display(fl);f=-1;
        else
            flow{fl}.nowdelay=sumdelay;
        end
        if (sumpassratio<1-flow{fl}.maxlossratio)
            display('loss');display(fl);f=-1;
        else
            flow{fl}.nowlossradio=1-sumpassratio;
        end
        if (sumcost>=cost)
            display('cost');display(fl);f=-1;
        else
            flow{fl}.nowcost=sumcost;
        end
    else
        display('bandwidth');display(fl);f=-1;
    end


if(f~=-1)
    %可以优化，满足约束
    %删除所有曾经包含上述路径的记录
    for i=1:temp
        link{flow{fl}.path(i)}.flows(find(link{flow{fl}.path(i)}.flows==fl))=[];
        link{flow{fl}.path(i)}.flowsnum=link{flow{fl}.path(i)}.flowsnum-1;
    end
    flow{fl}.path=[];
    flow{fl}.pathnum=0;
    tempt=t;


    %写入新的记录
    while(tempt~=s)
        link{linkpre(tempt)}.flowsnum=link{linkpre(tempt)}.flowsnum+1;
        link{linkpre(tempt)}.flows=[link{linkpre(tempt)}.flows fl];
        link{linkpre(tempt)}.unbandwdith=link{linkpre(tempt)}.unbandwidth-bandwidth;
        flow{fl}.path=[flow{fl}.path linkpre(tempt)];
        flow{fl}.pathnum=flow{fl}.pathnum+1;
        tempt=pre(tempt);
    end
    flo=flow;
    lin=link;
else
    for i=1:temp
        link{flow{fl}.path(i)}.unbandwidth=link{flow{fl}.path(i)}.unbandwidth-bandwidth;
    end
end
   
    
    
end
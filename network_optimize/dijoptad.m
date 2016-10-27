%对fl进行单链路优化，删除fl占用空间，求fl的加权最短路，若不满足则优化权重，直到找到满足条件填充
%优化方案为带权重dij，不满足约束则更改权重直到满足


function [f,flo,lin]=dijoptad(flow,link,linjieLINK,n,fl,GG,cost)%输入为数据流结构，网络结构，网络连通状态，节点数,待优化数据流，基于花费的权值矩阵，总花费
    f=-1;
    flo=flow;
    lin=link;
    G=GG;
%初始化权值
    a1=1;
    a2=0;
    a3=0;
    a4=0;
    
time=0;%初始化迭代次数
%开始迭代权值
while(f==-1 && time<100)
    time=time+1;
    if(time==99)
        aaaa=0;
    end
    
        bandwidth=flow{fl}.bandwidth;

%初始化边权G
    for i=1:n
    for j=1:n
        if(linjieLINK(i,j)==0)
            G(i,j)=999999;
        else
        G(i,j)=a1/100*link{linjieLINK(i,j)}.cost+a2*link{linjieLINK(i,j)}.delay+a3*20*link{linjieLINK(i,j)}.lossratio+a4*link{linjieLINK(i,j)}.unbandwidth/flow{fl}.bandwidth;
        end
    end
end
    for i=1:n
        for j=1:n
            if(linjieLINK(i,j)~=0)
            if(link{linjieLINK(i,j)}.unbandwidth<bandwidth)%删除带宽不满足的边
                G(i,j)=999999;
            end
            end
        end
    end    
    
    flo=flow;
    lin=link;
    s=flow{fl}.fromnode;
    t=flow{fl}.tonode;
    temp=flow{fl}.pathnum;
    %剔除路径
    for i=1:temp
        link{flow{fl}.path(i)}.unbandwidth=link{flow{fl}.path(i)}.unbandwidth+bandwidth;
    end


    visit=zeros(n);%已访问节点记录
    visit(s)=1;
    for i=1:n
        D(i)=G(s,i);
        linkpre(i)=linjieLINK(s,i); %每个节点的Pre边,用于记录最短路径
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

%不满足则进行以下权值调整
            if (sumcost>=cost)
               % display('cost');display(fl);
               if(a1==1)
                   break;
               end
               f=-1;
                a1=a1+a2*0.5+a3*0.5;
                a2=a2*0.5;
                a3=a3*0.5;
                
            else
                flow{fl}.nowcost=sumcost;
                if (sumdelay>flow{fl}.maxdelay && sumpassratio<1-flow{fl}.maxlossratio)
                    a2=a2+a1*0.5/3;
                    a3=a3+a1*0.5/3;
                    a4=a4+a1*0.5/3;
                    a1=a1*0.5;
                else
                    if (sumdelay>flow{fl}.maxdelay)
                       % display('delay:');display(fl);
                       f=-1;
                        a2=a2+a3*0.5;
                        a2=a2+a1*0.5;
                        a2=a2+a4*0.5;
                        a3=a3*0.5;
                        a1=a1*0.5;
                        a4=a4*0.5;
                    else
                        flow{fl}.nowdelay=sumdelay;
                        if (sumpassratio<1-flow{fl}.maxlossratio)
                            %display('loss');display(fl);
                            f=-1;
                            a3=a3+a1*0.5;
                            a3=a3+a2*0.5;
                            a3=a3+a4*0.5;
                            a2=a2*0.5;
                            a1=a1*0.5;
                            a4=a4*0.5;
                        else
                            flow{fl}.nowlossradio=1-sumpassratio;
                        end
                    end
                end
            end
        else
            %display('bandwidth');display(fl);
            f=-1;
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
end
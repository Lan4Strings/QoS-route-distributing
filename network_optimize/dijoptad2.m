%对数据流列表a中的所有数据流先剔除，后重新排列
%优化方法为带权重dij


function [f,flo,lin]=dijoptad2(flow,link,linjieLINK,n,a,GG,cost)%输入为数据流结构，网络结构，网络连通状态，节点数,待优化数据流list，基于花费的权值矩阵，总花费
    
time=0;
flo=flow;
lin=link;


%剔除list中的路径
for i=1:length(a)
    fl=a{i};
    bandwidtha=flow{fl}.bandwidth;
    temp=flow{fl}.pathnum;
       for i=1:temp
            link{flow{fl}.path(i)}.unbandwidth=link{flow{fl}.path(i)}.unbandwidth+bandwidtha;
        end
end


%对每一个数据进行带权重dij，说明见dijoptad.m
for kkk=1:length(a)
    fl=a{kkk};
    flow{fl}.nowcost=nooptcost(flow,link,fl);
    bandwidtha=flow{fl}.bandwidth;
    temp=flow{fl}.pathnum;
    f=-1;
    G=GG;
    a1=1;
    a2=0;
    a3=0;
    a4=0;
    while(f==-1 && time<100)
        time=time+1;
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
                if(link{linjieLINK(i,j)}.unbandwidth<bandwidtha)
                    G(i,j)=999999;
                end
                end
            end
        end    
        s=flow{fl}.fromnode;
        t=flow{fl}.tonode;
        visit=zeros(n);
        visit(s)=1;
        for i=1:n
            D(i)=G(s,i);
            linkpre(i)=linjieLINK(s,i);
            pre(i)=s;
        end
        D(s)=0;
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
        [fl D(t)];
            if(D(t)~=999999)
                tempt=t;
                while(tempt~=s)
                    %[fl s t linkpre(tempt)]
                    sumdelay=sumdelay+link{linkpre(tempt)}.delay;
                    sumcost=sumcost+link{linkpre(tempt)}.cost*bandwidtha;
                    sumpassratio=sumpassratio*(1-link{linkpre(tempt)}.lossratio);
                    tempt=pre(tempt);

                end
                if (sumcost>=flow{fl}.nowcost)
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
                f=-1;
            end
        if(f~=-1)
            %可以交换
            for i=1:temp
                link{flow{fl}.path(i)}.flows(find(link{flow{fl}.path(i)}.flows==fl))=[];
                link{flow{fl}.path(i)}.flowsnum=link{flow{fl}.path(i)}.flowsnum-1;
            end
            flow{fl}.path=[];
            flow{fl}.pathnum=0;
            %删除所有包含上述路径的
            tempt=t;
            while(tempt~=s)
                link{linkpre(tempt)}.flowsnum=link{linkpre(tempt)}.flowsnum+1;
                link{linkpre(tempt)}.flows=[link{linkpre(tempt)}.flows fl];
                link{linkpre(tempt)}.unbandwdith=link{linkpre(tempt)}.unbandwidth-bandwidtha;
                flow{fl}.path=[flow{fl}.path linkpre(tempt)];
                flow{fl}.pathnum=flow{fl}.pathnum+1;
                tempt=pre(tempt);
            end
            flo=flow;
            lin=link;
        end
    end

end
end
%深度优先搜索对数据流进行放置


clear all
load aaa.mat
tianchong=0;
for i=1:flownum
    tf=zeros(nodenum,nodenum);
    pre=zeros(1,linknum);
    fn=flow{i}.fromnode;
    tn=flow{i}.tonode;
    topP=0; %栈顶P指针
    lastlink=0; %前衔节点
    pre=zeros(1,linknum);
    jishuqi=0;
    while(1==1)
        jishuqi=jishuqi+1;
        for j=1:nodenum
            nocircle=0; %判断是否死循环
            if (linjie(fn,j)~=0 && tf(fn,j)==0) %检验是否在队列中，是否连通                
                if (lastlink==0)
                    check=0;
                else
                    check=lastlink;
                end
                
                while(check~=0)
                    if (link{check}.tonode==link{linjieLINK(fn,j)}.tonode)
                        nocircle=1;
                        break
                    end
                    check=pre(check);
                end
                if (nocircle==0)
                    topP=topP+1;
                    P(topP)=linjieLINK(fn,j); %进栈P
                    tf(fn,j)=1;
                    pre(P(topP))=lastlink; %标记父亲
                end
              
            end
        end
        if(topP==0)
            break;
        end
        fn=link{P(topP)}.tonode;
        lastlink=P(topP); %更改前衔节点
        tf(link{P(topP)}.fromnode,link{P(topP)}.tonode)=0; %标记还原
        topP=topP-1; %出栈
        if (topP==0 && link{lastlink}.fromnode~=flow{i}.fromnode)
            break;
        end
        if (fn==tn) %开始检测约束条件
            sumdelay=0;% 总延迟初始化
            sumpassratio=1; %总传包率初始化
            cost=0;%初始金钱
            check=P(topP+1);
            checkright=0;
            while(link{check}.unbandwidth>=flow{i}.bandwidth && sumdelay<=flow{i}.maxdelay && sumpassratio>1-flow{i}.maxlossratio)
                sumdelay=sumdelay+link{check}.delay;
                sumpassratio=sumpassratio*(1-link{check}.lossratio);
                cost=cost+link{check}.cost*flow{i}.bandwidth;
                check=pre(check);
                if (check==0)
                    checkright=1;
                    flow{i}.nowdelay=sumdelay;
                    flow{i}.nowlossratio=1-sumpassratio;
                    flow{i}.nowcost=cost;
                    break
                end
            end
            if (checkright==1)
                break;
            else
                %不满足
                if (topP==0)
                    break
                end;
                fn=link{P(topP)}.tonode;
                lastlink=P(topP); %更改前衔节点
                tf(link{P(topP)}.fromnode,link{P(topP)}.tonode)=0; %标记还原
                topP=topP-1; %出栈 
            end
        end
    end
    if(checkright==1)
        check=P(topP+1);
        tianchong=tianchong+1;
        while(check~=0)
            flow{i}.pathnum=flow{i}.pathnum+1;
            flow{i}.path(flow{i}.pathnum)=check;
            link{check}.flowsnum=link{check}.flowsnum+1;
            link{check}.flows(link{check}.flowsnum)=i;
            link{check}.unbandwidth=link{check}.unbandwidth-flow{i}.bandwidth;
            check=pre(check);
        end
    end
end
function [flo qiangzhan]=jisuan(flows,Map,link,linjieLINK,Mapcost,Mapw1,Mapw2,Mapw3)
    global nodenum
    global lidu
    n=nodenum;
    global M
    global linknum
    global flowsnum
    global flow_q
    queue_first=flow_q(1);
    Q=[];%抢占临时剔除数据
    fenliu=0;
    qiangzhan=[];
    
    %寻找最大花费%
    maxcost=0;
    for i=1:linknum
        if (maxcost<link{i}.cost)
            maxcost=link{i}.cost;
        end
    end
    %%%%%%%%%%%%%

    tic
    %%%%%%%%%%虚假抢占%%%%%%%%%%
    for i=1:flowsnum
        if (flows{i}.rank<queue_first.rank)
            if (flows{i}.bandwidth==0)
                continue
            end
            Q=[Q i];%存入临时
            for j=1:length(flows{i}.path)
                needdel=flows{i}.path(j);
                link{needdel}.restbandwidth=link{needdel}.restbandwidth+flows{i}.bandwidth;
                link{needdel}.cost=link{needdel}.cost+maxcost;
                Mapcost(link{needdel}.fromnode,link{needdel}.tonode)=link{needdel}.cost;
            end
        end
    end
    for i=1:linknum
        Mapbw(link{i}.fromnode,link{i}.tonode)=link{i}.restbandwidth;
    end 
    
    %带宽连通性判断%
    liantong=0;
    Map=Mapcost;
    for i=1:n
        for j=1:n
            if (Map(i,j)==0 || Mapbw(i,j)<queue_first.bandwidth)
                Map(i,j)=999999;
            end
        end
    end
    [f,flo,lin]=dij(queue_first,Map,link,linjieLINK);  
    if(flo.pathnum<1)
        disp(['虚假抢占后仍然带宽不满足'])
        fenliu=1;
    end
    %%%%%%%%%%%%%%%
    etime=toc;
    disp(['抢占耗时：',num2str(etime),'s'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    
    
    %%%%%%%%%%%求解%%%%%%%%%%%%
    if (fenliu==0)
        youjie=0;
        tic
        qiujienew
        for i=1:length(flo.path)
            link{flo.path(i)}.restbandwidth=link{flo.path(i)}.restbandwidth-flo.bandwidth;
        end
        if (youjie==0)
            return;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%   
    
    
    
    %%%%%%%%%%%恢复抢占，执行分流%%%%%%%%%%
    if (fenliu==1)
        tic
        for i=1:length(Q)
            for j=1:length(flows{Q(i)}.path)
                needadd=flows{Q(i)}.path(j);
                link{needadd}.restbandwidth=link{needadd}.restbandwidth-flows{Q(i)}.bandwidth;
                link{needadd}.cost=link{needadd}.cost-maxcost;
            end
        end
        flow_q(1)=[];
        mintempbw=lidu*floor(queue_first.bandwidth/lidu/2);
        if(mintempbw==0)
            disp(['已分流到最小粒度，无解'])
            return
        end
        if(queue_first.div>2)%限制最大分流次数为2
            disp(['已超过最大分流次数'])
            return;
        else
            tempflo=queue_first;
            tempflo.bandwidth=mintempbw;
            tempflo.div=queue_first.div+1;
            flow_q=[flow_q tempflo];
            tempflo.bandwidth=queue_first.bandwidth-mintempbw;
            flow_q=[flow_q tempflo];
            etime=toc;
            disp(['分流耗时：',num2str(etime),'s'])
            return;            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    %%%%%%%%%%%%%恢复抢占，对无法恢复的加入队首%%%%%%%%%%%%%
    tic
    sumlost=0;
    for i=1:length(Q)
        norecover=0;
        for j=1:length(flows{Q(i)}.path)
            needadd=flows{Q(i)}.path(j);
            if(link{needadd}.restbandwidth<flows{Q(i)}.bandwidth)
                norecover=1;%不能恢复
                break;
            end
        end
        if(norecover==0)%可以恢复
            for j=1:length(flows{Q(i)}.path)
                needadd=flows{Q(i)}.path(j);
                link{needadd}.restbandwidth=link{needadd}.restbandwidth-flows{Q(i)}.bandwidth;
                link{needadd}.cost=link{needadd}.cost-maxcost;
            end
        else
            sumlost=sumlost+1;
            flow_q=[flow_q flows{Q(i)}];
            qiangzhan=[qiangzhan Q(i)];
        end
    end
    disp(['有',num2str(sumlost),'条被抢占'])
    etime=toc;
    disp(['恢复抢占耗时：',num2str(etime),'s'])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
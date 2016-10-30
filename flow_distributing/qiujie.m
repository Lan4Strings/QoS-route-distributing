needw1=0;needw2=0;needw3=0;N=1;
a0=1;a1=0;a2=0;a3=0;
youjie=0;
min=9999999;
while(N<M)
    r=1.5+rand();
    if (needw1==1)
        a1=a1+a0/r+a2/r+a3/r;
        a2=a2-a2/r;
        a3=a3-a3/r;
        a0=1-a1-a2-a3;
    else
        if (needw2==1)
            a2=a2+a0/r+a1/r+a3/r;
            a1=a1-a1/r;
            a3=a3-a3/r;
            a0=1-a1-a2-a3;
        else
            if (needw3==1)
                a2=a2+a0/r+a1/r+a3/r;
                a1=a1-a1/r;
                a3=a3-a3/r;
                a0=1-a1-a2-a3;
            else
                if(needw2==0 && needw3==0 && needw1==0)
                    a0=a0+a1/r+a2/r+a3/r;
                    a1=a1-a1/r;
                    a2=a2-a2/r;
                    a3=1-a1-a2-a0;                    
                end 
            end
        end
    end
    needw1=0;needw2=0;needw3=0;
    Map=a0*Mapcost+a1*Mapw1+a2*Mapw2+a3*Mapw3;
    for i=1:n
        for j=1:n
            if (Map(i,j)==0 || Mapbw(i,j)<queue_first.bandwidth)
                Map(i,j)=999999;
            end
        end
    end
    [f,flo,lin]=dij(queue_first,Map,link,linjieLINK);
    if (flo.sumw1<=flo.maxdelay)
        if(flo.prow2<=flo.maxlossratio)
            if(flo.sumw3<=flo.maxjitter)
                if(flo.sumcost<min)
                    fflow=flo;flin=lin;
                    min=flo.sumcost;%最优解
                    etime=toc;
                    youjie=1;
                    disp(['求解耗时：',num2str(etime),'s'])
                end
            else
                needw3=1;
            end
        else
            needw2=1;
        end
    else needw1=1;
    end
    N=N+1;
end
if (youjie==0)
    disp(['无满足约束的解，需要调整约束!'])
    flow_q(1)=[];
    return;
    %fenliu=1;
else
    %fflow%输出分配结果
    link=flin;
    youjie=1;
    flow_q(1)=[];%删除队首元素，表示已经分配
    
end

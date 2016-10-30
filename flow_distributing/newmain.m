clear all
load chushijuzhen.mat
nowtime=datestr(now,30)
save(nowtime)
global flow_q
global M
n=nodenum;
M=10000;
N=1;
global jishu;
jishu=0;
flow_q=[];
flow_q=[flow_q flow];
allans=[];

while(length(flow_q)~=0)
    jishu=jishu+1;
    fprintf('\n\n第%d组解\n待处理全部数据：%s\n', jishu,num2str([flow_q.bandwidth]))
    disp(['当前处理数据：',num2str(flow_q(1).bandwidth)])
    [flo qiangzhan]=jisuan(flows,Map,link,linjieLINK,Mapcost,Mapw1,Mapw2,Mapw3);
    l=length(qiangzhan);
    for i=1:l%还原被抢占的数据
        ll=length(flows{i}.path);
        for k=1:ll
            link{flows{i}.path(k)}.restbandwidth=link{flows{i}.path(k)}.restbandwidth+flows{i}.bandwidth;
        end
        flows{i}.bandwidth=0;%删除该流，已存入待处理队列内    
    end
    l=length(flo.path);
    for i=1:l
        link{flo.path(i)}.restbandwidth=link{flo.path(i)}.restbandwidth-flo.bandwidth;
    end
    allans=[allans flo];
    fprintf('realcost:%f\n',flo.realcost);
end
save([nowtime 'ans'])
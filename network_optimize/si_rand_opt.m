%单链路优化：无顺序随机选取k个

sumopt=0;
sumnoopt=0;
%netnet;
%clear all;load chushijuzhen.mat;
temp2=[];
temp1=[];
tianchong=0;%默认填充0个
for i=1:flownum
    temp2=[temp2 nooptcost(flow,link,i)];
end
sumnoopt=sum(temp2);%计算优化前花费
k=round(flownum*rand());%随机生成k
tfcheck=zeros(1,flownum);
for i=1:k%随机优化第m个流，共优化k次
    m=1+round(k*rand());
    while(tfcheck(m)==1)
        m=1+round(k*rand());
    end
    tfcheck(m)=1;
    if(sumnoopt==0)
        [temp1,tempflow,templink]=dijoptad(flow,link,linjieLINK,nodenum,m,G,999999);
    else
        [temp1,tempflow,templink]=dijoptad(flow,link,linjieLINK,nodenum,m,G,temp2(m));
    end
    if(temp1~=-1)
        flow=tempflow;
        link=templink;
    end
end

for i=1:flownum
    temp1=[temp1 nooptcost(flow,link,i)];
end
sumopt=sum(temp1);%计算优化后价钱


    if(sumnoopt==0)
    sumnoopt=9999999;
    end
for i=1:flownum
    if(flow{i}.nowcost~=0 && flow{i}.pathnum~=0)
        tianchong=tianchong+1;
    
    end
end
    tianchong
[sumopt sumnoopt]
100*sumopt/sumnoopt

%单链路优化，从id=1到id=flownum进行顺序优化
%优化方式为带权值的dij

sumopt=0;
sumnoopt=0;
%clear all;load chushijuzhen.mat;
temp2=[];
temp1=[];
tianchong=0;
for i=1:flownum
    temp2=[temp2 nooptcost(flow,link,i)];
end
    sumnoopt=sum(temp2);%计算优化前花费
    
for i=1:flownum
    if(sumnoopt==0)
        [temp1,tempflow,templink]=dijoptad(flow,link,linjieLINK,nodenum,i,G,999999);%对编号为i的流优化
    else
        [temp1,tempflow,templink]=dijoptad(flow,link,linjieLINK,nodenum,i,G,temp2(i));
    end
    if(temp1~=-1)
        flow=tempflow;
        link=templink;
    end
end

for i=1:flownum
    temp1=[temp1 nooptcost(flow,link,i)];
end
sumopt=sum(temp1);%计算优化后花费


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

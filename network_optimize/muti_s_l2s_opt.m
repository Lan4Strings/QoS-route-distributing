%随机选取K个数据流，并对其带宽倒序排序，剔除K条数据流，从带宽大到带宽小依次放入
%优化方案为带权值的dij

sumopt=0;
sumnoopt=0;
%clear all;load chushijuzhen.mat;
temp2=[];
temp1=[];
tianchong=0;
for i=1:flownum
    temp2=[temp2 nooptcost(flow,link,i)];

end
    sumnoopt=sum(temp2);

%生成随机的k个数据（此处为w1~w2)
w1=round(flownum*rand())
w2=w1+round((flownum-w1)*rand())
ffn=w2-w1
a={};
b={};
for i=1:(w2-w1)
    a{i}=flow{i+w1}.id;
    b{i}=flow{i+w1}.bandwidth;
end

%对k个数据排序编号存入a
for i=1:ffn
    for k=1:(ffn-i)
        if(b{k}<b{k+1})
            temp=b{k};
            b{k}=b{k+1};
            b{k+1}=temp;
            temp=a{k};
            a{k}=a{k+1};
            a{k+1}=temp;
        end
    end
end


%对排好序的数据流列表a进行优化操作
    if(sumnoopt==0)
        [temp1,tempflow,templink]=dijoptad2(flow,link,linjieLINK,nodenum,a,G,999999);
    else
        [temp1,tempflow,templink]=dijoptad2(flow,link,linjieLINK,nodenum,a,G,temp2(a{i}));
    end
        flow=tempflow;
        link=templink;
 

for i=1:flownum
    temp1=[temp1 nooptcost(flow,link,i)];

end
sumopt=sum(temp1);


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



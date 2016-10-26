%计算当前花费

function f=nooptcost(flow,link,k)
f=0;
n=flow{k}.pathnum;
bandwidth=flow{k}.bandwidth;
for i=1:flow{k}.pathnum
    templink=flow{k}.path(i);
    f=f+link{templink}.cost*bandwidth;
end

end
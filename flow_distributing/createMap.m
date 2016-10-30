function A = createMap(nodenum,linknum)
    k=1/(1-linknum/nodenum/nodenum);
    A=boolean(k*rand(nodenum,nodenum)>1);
    while (sum(sum(A))>linknum)
        A=boolean(k*rand(nodenum,nodenum)>1);
    end
    for i=1:nodenum
        A(i,i)=0;
    end
    while(sum(sum(A))<linknum)
        t=nodenum*nodenum*rand();
        if(floor((t/nodenum)+1)~=floor(mod(t,nodenum)+1))
            A(floor((t/nodenum)+1),floor(mod(t,nodenum)+1))=1;
        end
    end
end
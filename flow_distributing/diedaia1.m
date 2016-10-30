if(Na1<Ma)%a1的最大迭代次数
    if(Na1==0)
        a1=0.99999;
        [ba0 ba1 ba2 ba3]=daoshu(a1,a2,a3);
        Na1=Na1+1;
        continue;
    end
    if(a1==0.99999)
        if(flo.sumw1>flo.maxdelay)
            disp(['第1约束违反最小'])
            %flo%无解输出
            wujie=1;
            return;
        else
            a1max=a1;
            a1=0.5;%w1一定有可行解
            [ba0 ba1 ba2 ba3]=daoshu(a1,a2,a3);
            Na1=Na1+1;
            continue;            
        end
    end
    if (flo.sumw1>flo.maxdelay)%w1不可行，需要增大
            a1min=a1;%a1min一定不可行
            a1=(a1+a1max)/2;
            [ba0 ba1 ba2 ba3]=daoshu(a1,a2,a3);
            Na1=Na1+1;
            continue;
    else%w1可行
            a1max=a1;%a1max一定可行
            a1=(a1min+a1)/2;
            [ba0 ba1 ba2 ba3]=daoshu(a1,a2,a3);
            Na1=Na1+1;
            continue;
    end
end
if(a1max~=1)
    a1=a1max;
else
    if(a1min~=0)
        disp(['第1约束违反最小'])
        fflo
        wujie=1;
        return;
    end
end
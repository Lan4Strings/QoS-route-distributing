    Map=ba0*Mapcost+ba1*Mapw1+ba2*Mapw2+ba3*Mapw3;
    for i=1:n
        for j=1:n
            if (Map(i,j)==0 || Mapbw(i,j)<queue_first.bandwidth)
                Map(i,j)=999999999;
            end
        end
    end
    [f,flo,lin]=dij(queue_first,Map,link,linjieLINK);
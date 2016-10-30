function [d a b c]=daoshu(w1,w2,w3)
    %a=w1/(1-w1)/(1-w2)/(1-w3);
    %b=w2/(1-w2)/(1-w3);
    %c=w3/(1-w3);
    a=w1;
    b=(1-w1)*w2;
    c=(1-w1)*(1-w2)*w3;
    d=(1-w1)*(1-w2)*(1-w3);
    
end
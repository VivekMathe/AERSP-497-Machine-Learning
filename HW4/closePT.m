function [x1,y1,id]=closePT(x,y,x0,y0)
    d=sqrt((y-y0).^2+(x-x0).^2);
    id=find(d==min(d));
    id=id(1);
    x1=x(id); y1=y(id);
end
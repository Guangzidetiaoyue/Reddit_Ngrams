function figshape(x,y)
%% figshape(x,y)
%% 
%% resize current figure's shape to have dimensions x and y

tmppos = get(gcf,'position');
set(gcf,'position',[tmppos(1:2) x y]);

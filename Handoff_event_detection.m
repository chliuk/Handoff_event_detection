clc
clear

minSpeed = 1;
maxSpeed = 15;
minT = 1;
maxT = 6;
dMtoBS = zeros(910,19);%每一秒mobile device與19個BS的距離
xysT = zeros(910,4); %每一秒mobile device要往x移動多少單位(第一行)、往y移動多少單位(第二行)、速度(第三行)、時間(第四行)
MSxyc1c2 = zeros(910,4);%每一秒mobile device的絕對x位置(第一行)、絕對y位置(第二行)、原本的cell(第三行)、下一秒的cell(第四行)
MSxyc1c2(1,1)=250;MSxyc1c2(1,2)=0;MSxyc1c2(1,3)=1;MSxyc1c2(1,4)=1;%mobile device的初始資訊
BS = [0 0 250*sqrt(3) 250*sqrt(3) 0 -250*sqrt(3) -250*sqrt(3) 0 250*sqrt(3) 500*sqrt(3) 500*sqrt(3) 500*sqrt(3) 250*sqrt(3) 0 -250*sqrt(3) -500*sqrt(3) -500*sqrt(3) -500*sqrt(3) -250*sqrt(3);
    0 500 250 -250 -500 -250 250 1000 750 500 0 -500 -750 -1000 -750 -500 0 500 750]; %BS的位置
count = 1;%時間(第幾秒)
for j=1:19
    dMtoBS(1,j) = sqrt((250-BS(1,j))^2+(0-BS(2,j))^2);
end
handoff = zeros(50,3);%紀錄handoff的表格

while count < 900
    t = int16(minT+(maxT-minT)*rand(1));%這一次會持續移動幾秒
    sp = minSpeed+(maxSpeed-minSpeed)*rand(1); %這一次移動的速度
    [x,y]=pol2cart(2*pi*rand(1),1);%%這一次移動的x、y方向(單位向量)
    
    for i = count:count+t-1 %填入每一秒的資料
        xysT(i,1)=x;
        xysT(i,2)=y;
        xysT(i,3) = sp;
        xysT(i,4) = t;
    end
    count = count + int16(t); %秒數計數
end

for i=2:910 
    MSxyc1c2(i,1) = MSxyc1c2(i-1,1) + xysT(i,1)*xysT(i,3);%每一次移動後的x座標
    MSxyc1c2(i,2) = MSxyc1c2(i-1,2)+ xysT(i,2)*xysT(i,3);%每一次移動後的y座標
    MSxyc1c2(i,3)=MSxyc1c2(i-1,4);%上一次移動後的cell = 這一次移動前的cell
    
    %找出距離哪個BS最近
    closestIndex = 0;
    closestDistance = 500/sqrt(3);
    for j=1:19
        dMtoBS(i,j) = sqrt((MSxyc1c2(i,1)-BS(1,j))^2+(MSxyc1c2(i,2)-BS(2,j))^2);
    end
       
    for j=1:19
        if dMtoBS(i,j) <= closestDistance
            closestDistance = dMtoBS(i,j);
            closestIndex = j;
        end
    end
    MSxyc1c2(i,4) = closestIndex; %找到最近的BS後記錄其cell
end

%篩選有handoff的秒數並創建表格
k=1;
for i=2:910
    if MSxyc1c2(i,4) ~= MSxyc1c2(i-1,4)
        handoff(k,1) = i;
        handoff(k,2) = MSxyc1c2(i,3);
        handoff(k,3) = MSxyc1c2(i,4);
        k = k + 1;
    end
end
for j = 1 : 51-k
    handoff(k,:)=[];
end
array2table(handoff,'VariableNames',{'Time' , 'Source cell ID' , 'Destination cell ID'})
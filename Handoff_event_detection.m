clc
clear

minSpeed = 1;
maxSpeed = 15;
minT = 1;
maxT = 6;
dMtoBS = zeros(910,19);%�C�@��mobile device�P19��BS���Z��
xysT = zeros(910,4); %�C�@��mobile device�n��x���ʦh�ֳ��(�Ĥ@��)�B��y���ʦh�ֳ��(�ĤG��)�B�t��(�ĤT��)�B�ɶ�(�ĥ|��)
MSxyc1c2 = zeros(910,4);%�C�@��mobile device������x��m(�Ĥ@��)�B����y��m(�ĤG��)�B�쥻��cell(�ĤT��)�B�U�@��cell(�ĥ|��)
MSxyc1c2(1,1)=250;MSxyc1c2(1,2)=0;MSxyc1c2(1,3)=1;MSxyc1c2(1,4)=1;%mobile device����l��T
BS = [0 0 250*sqrt(3) 250*sqrt(3) 0 -250*sqrt(3) -250*sqrt(3) 0 250*sqrt(3) 500*sqrt(3) 500*sqrt(3) 500*sqrt(3) 250*sqrt(3) 0 -250*sqrt(3) -500*sqrt(3) -500*sqrt(3) -500*sqrt(3) -250*sqrt(3);
    0 500 250 -250 -500 -250 250 1000 750 500 0 -500 -750 -1000 -750 -500 0 500 750]; %BS����m
count = 1;%�ɶ�(�ĴX��)
for j=1:19
    dMtoBS(1,j) = sqrt((250-BS(1,j))^2+(0-BS(2,j))^2);
end
handoff = zeros(50,3);%����handoff�����

while count < 900
    t = int16(minT+(maxT-minT)*rand(1));%�o�@���|���򲾰ʴX��
    sp = minSpeed+(maxSpeed-minSpeed)*rand(1); %�o�@�����ʪ��t��
    [x,y]=pol2cart(2*pi*rand(1),1);%%�o�@�����ʪ�x�By��V(���V�q)
    
    for i = count:count+t-1 %��J�C�@�����
        xysT(i,1)=x;
        xysT(i,2)=y;
        xysT(i,3) = sp;
        xysT(i,4) = t;
    end
    count = count + int16(t); %��ƭp��
end

for i=2:910 
    MSxyc1c2(i,1) = MSxyc1c2(i-1,1) + xysT(i,1)*xysT(i,3);%�C�@�����ʫ᪺x�y��
    MSxyc1c2(i,2) = MSxyc1c2(i-1,2)+ xysT(i,2)*xysT(i,3);%�C�@�����ʫ᪺y�y��
    MSxyc1c2(i,3)=MSxyc1c2(i-1,4);%�W�@�����ʫ᪺cell = �o�@�����ʫe��cell
    
    %��X�Z������BS�̪�
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
    MSxyc1c2(i,4) = closestIndex; %���̪�BS��O����cell
end

%�z�靈handoff����ƨóЫت��
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
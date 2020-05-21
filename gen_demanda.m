clear;clc
close all

%Simulación de la distribución anual de la demanda desde las bocas de riego de una redondeada

%Fase 1: Determinación dotación de caudal en cada boca

filas=["Avellano";"Olivo";"Lechuga";"Tomate";"Patata";"Pimiento";"Cebolla"];

%Necesidades hidrícas mensuales (en columnas) de los cultivos (en filas) expresadas en mm/dia.
Hr= [
0.00 0.00 0.00 0.29 0.79 2.21 3.91 2.40 0.34 0.00 0.00 0.00;...
0.00 0.10 0.58 0.69 0.55 1.67 2.09 1.02 0.00 0.00 0.00 0.00;...
0.00 0.00 0.00 0.69 1.90 3.80 0.00 0.00 0.00 0.00 0.00 0.00;...
0.00 0.00 0.00 0.44 1.24 1.08 5.96 3.75 0.91 0.00 0.00 0.00;...
0.00 0.00 0.00 0.44 1.46 4.08 5.50 3.03 0.00 0.00 0.00 0.00;...
0.00 0.00 0.00 0.44 1.38 3.61 4.99 2.98 0.00 0.00 0.00 0.00;...
0.33 0.87 1.61 2.12 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.04];

%Distribución cultivos
distCult=[0.137;0.262;0.085;0.220;0.023;0.099;0.174];

%Superficie a regar desde cada boca (ha)
S=[30;30;30;30;30;30;30;30];

%Relación Ra/(1-Cd)
rend=0.9;

%Grados de libertad bocas
tGL=[6 12 16];
GL=24./tGL;
distGL=[31.6 50.8 17.6;23.8 45.7 30.5;43.3 22.8 33.9;61.7 31.7 6.6;60.2 8.1 31.7;92.5 0.1 7.4;18.1 50.2 31.7;94.7 2.7 2.6]./100;

%Tiempo operación estación bombeo por meses
tfunc=18;

%Caudal ficticio continuo (L/s)
necRiego=sum(distCult.*Hr,1)./rend;%Necesidades de riego (mm/dia) mediante ponderación según la distribución de cultivos por meses
qfc=transpose(max(transpose(S*necRiego.*(1e4/24/3600))));%Caudal ficticio continuo (L/s) necesario en cada boca

%Caudal asignado a cada boca según Grado de Libertad
qGL1=distGL(:,1).*qfc.*GL(1);
qGL2=distGL(:,2).*qfc.*GL(2);
qGL3=distGL(:,3).*qfc.*GL(3);
qboca=5.*ceil(sum([qGL1 qGL2 qGL3],2)./5);%Caudal (L/s) de dotación de cada boca en proyecto redondeada a múltiplos de 5


%Fase 2: Simulación de la demanda

planillaRiego=zeros(numel(S),24);
q=planillaRiego;
diaAgno=0;

%Tiempo necesario (h) para suministrar la demanda por meses y GLs
triegoGL1=necRiego.*S./qGL1.*1e4./3600.*distGL(:,1);
triegoGL2=necRiego.*S./qGL2.*1e4./3600.*distGL(:,2);
triegoGL3=necRiego.*S./qGL3.*1e4./3600.*distGL(:,3);

for k=1:12
  
  horaComienzoGL1=floor(rand(numel(S),12).*(tfunc-triegoGL1));
  horaComienzoGL2=floor(rand(numel(S),12).*(tfunc-triegoGL2));
  horaComienzoGL3=floor(rand(numel(S),12).*(tfunc-triegoGL3));
  
  duracRiegoGL1=ceil(triegoGL1);
  duracRiegoGL2=ceil(triegoGL2);
  duracRiegoGL3=ceil(triegoGL3);  

  for j=1:30

    diaAgno=diaAgno+1;
    planillaRiegoGL1=planillaRiego;
    planillaRiegoGL2=planillaRiego;
    planillaRiegoGL3=planillaRiego;
    
    for i=1:numel(S)
      
      planillaRiegoGL1(i,(1+horaComienzoGL1(i,k)):(1+(horaComienzoGL1(i,k)+duracRiegoGL1(i,k))))=1;
      planillaRiegoGL2(i,(1+horaComienzoGL2(i,k)):(1+(horaComienzoGL2(i,k)+duracRiegoGL2(i,k))))=1;
      planillaRiegoGL3(i,(1+horaComienzoGL3(i,k)):(1+(horaComienzoGL3(i,k)+duracRiegoGL3(i,k))))=1;
      
    endfor
    
    %Matriz de caudal (L/s) demandado (boca,hora,diaAño)
    q(:,:,diaAgno)=planillaRiegoGL1.*qGL1+planillaRiegoGL2.*qGL2+planillaRiegoGL3.*qGL3;
    

  endfor

endfor

Q=sum(q,1);
distQ=reshape(Q,1,[]);%Vector distribución caudales horarios de 12 meses y 30 dias por mes.

plot(distQ)
hold on
plot(sort(distQ))
xlabel('horas de un año')
ylabel('Q(L/s)')
hold off

caudales=reshape(q,8,[]);

%Se guardan los caudales demandados de las bocas durante las aproximadamente 8640 horas de un año
save('cauddemandbocas.m','caudales','-append')
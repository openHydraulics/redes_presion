%Cálculo de red de distribución a presión
clear;clc

%Constante suavizado convergencia solución
cte=100;

%Enlace a funciones en carperta ./src/
addpath('./src/');

resultado=[];
resultado2=[];
resultado3=[];
resultado4=[];
indicadores=[];
distBocas=[];

#Se cargan los datos del caso a estudiar
datos;

## Caudal q y altura de presión h demandados en cada nodo (boca)
q=[q;0.1;-0.1].*(24/16*16/8);
hreq=[hreq;0;0];

%Aportación bombeo
Hbombeo=40;
H0=z0+Hbombeo;


## x, abcisas de los nudos
## y, ordenadas de los nudos
## z, cotas de de los nudos

x=[x;3000;3000];
y=[y;-500;-500];
z=[z;125;125];
 
D=[D;0.45135;0.45135];
L=[L;500;500];
k=[k;4e-5;4e-5];

## Matriz de conexiones
## Tramos a recorrer hasta la boca i
Mconexmalla_hf(1,:) =[Mconex_hf(1,:) 0 0];
Mconexmalla_hf(2,:) =[Mconex_hf(2,:) 0 0];
Mconexmalla_hf(3,:) =[Mconex_hf(3,:) 0 0];
Mconexmalla_hf(4,:) =[Mconex_hf(4,:) 0 0];
Mconexmalla_hf(5,:) =[Mconex_hf(5,:) 0 0];
Mconexmalla_hf(6,:) =[Mconex_hf(6,:) 0 0];
Mconexmalla_hf(7,:) =[Mconex_hf(7,:) 0 0];
Mconexmalla_hf(8,:) =[Mconex_hf(8,:) 0 0];
Mconexmalla_hf(9,:) =[1 1 1 1 0 0 0 0 1 0];
Mconexmalla_hf(10,:)=[1 0 0 0 0 1 1 0 0 1];

Mconexmalla_Q=transpose(Mconexmalla_hf);

%Vector 1 al número de bocas
vectorBocas=(1:1:10);

for p=0.05:0.05:1
##p=1;
  for i=1:100
    %Caudal de cada tramo (tubería)
    
    ## Demanda cuando una boca abastece a uno sólo usuario
    ##qdemand=q.*(rand(10,1)>p);
    
    ## Demanda cuando una boca abastece a múltiples usuarios
    qdemand=q.*p.*rand(10,1);

    H_nodo=hreq+z;
    H_nodo_ant=zeros(10,1);    
    
    while max(abs(H_nodo-H_nodo_ant))>1e-3
      
      H_nodo_ant=H_nodo;
      
      Q=Mconexmalla_Q*qdemand;
      Qbombeo=max(Q);

      %Pérdida de carga en cada tramo
      hf=IWC(Q,D,k,nu).*L;

      %Carga en cada nodo
      H_nodo=H0-Mconexmalla_hf*hf;
      
      ##Mallado
      %Pareja de nodos ficticios 9,10
      if abs(H_nodo(9)-H_nodo(10))>1e-1
          qdemand(9)=qdemand(9)*(cte+H_nodo(9))/(cte+H_nodo(10))*sign(H_nodo(9)-H_nodo(10));
          qdemand(10)=-qdemand(9);
      endif
      [H_nodo(9) H_nodo(10) qdemand(9)];
      
    endwhile
    
    %%Indicadores
    %Indicador rendimiento energético
    rendEnerg=sum(qdemand.*H_nodo.*((H_nodo-z)>hreq))/((z0+Hbombeo)*Qbombeo);
    %Coeficiente déficit energético
    coefDef=sum(qdemand.*H_nodo.*((H_nodo-z)<hreq))/sum(qdemand.*H_nodo.*hreq);

    if max(Q)>0
      %Columnas vector resultado [c1:caudal cabeza c2: presión máxima
      resultado=[resultado;Qbombeo max((H_nodo-z).*(hreq>0)) min((H_nodo-z).*(hreq>0))];
      resultado2=[resultado2 H_nodo];
      resultado3=[resultado3 H_nodo-(z+hreq)==min(H_nodo-(z+hreq))];
      resultado4=[resultado4 qdemand];
      
      %Indicadores
      indicadores=[indicadores; Qbombeo rendEnerg coefDef];
    endif
    [p i]
  endfor
endfor

subplot(1,3,1)
plot(resultado(:,1),resultado(:,2),'+')
axis([0 max(resultado(:,1)) min(resultado(:,3)) max(resultado(:,2))])
xlabel('Q');ylabel('Exceso altura presión (max y min)')
hold on
plot(resultado(:,1),resultado(:,3),'+')
plot([0 sum(q)],[min(resultado(:,3)) min(resultado(:,3))])
hold off

%resultado(lookup(resultado(:,2),max(resultado(:,2))),:)

% Distribución de bocas que determinan la altura en cabeza
for i=1:8
  distBocas=[distBocas sum(resultado3(i,:))];
endfor
distBocas=distBocas./sum(distBocas);
subplot(1,3,2)
bar(distBocas)
xlabel('boca presión mínima');ylabel('frecuencia')

subplot(1,3,3)
plot(indicadores(:,1),indicadores(:,2),'+')
axis([0 max(indicadores(:,1)) 0 max(indicadores(:,2))])
xlabel('Q'); ylabel('rend. Energético')
hold on
plot(indicadores(:,1),indicadores(:,3),'+')
hold off
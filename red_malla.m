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
distBocas=[];

## z0, cota del origen del agua
## D, diámetros de los tramos
## L, longitudes de los tramos
## k, aspereza de arena equivalente del material de los tubos de los tramos
## nu, viscosidad cinemática

z0=125;H0=165;
%Aportación bombeo
Hbombeo=H0-z0;
D=transpose([1.27662 0.78176 0.63831 0.45135 0.45135 0.78176 0.45135 0.45135 0.45135 0.45135]);
L=transpose([1000 1000 1000 1000 1000 1000 1000 1000 500 500]);
k=transpose([4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5]);
nu=1.3e-6;

## Caudal q y altura de presión h demandados en cada nodo (boca)
q=transpose([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 -0.1]).*(24/16*16/8);
hreq=transpose([35 35 35 35 35 35 35 35 0 0]);


## x, abcisas de los nudos
## y, ordenadas de los nudos
## z, cotas de de los nudos

x=transpose([1000 1000 2000 3000 1000 2000 3000 2000 3000 3000]);
y=transpose([0 -1000 -1000 -1000 -2000 0 0 1000 -500 -500]);
z=transpose([125 125 125 125 125 125 125 125 125 125]);

## Matriz de conexiones
## Tramos a recorrer hasta la boca i
Mconex_hf(1,:) =[1 0 0 0 0 0 0 0 0 0];
Mconex_hf(2,:) =[1 1 0 0 0 0 0 0 0 0];
Mconex_hf(3,:) =[1 1 1 0 0 0 0 0 0 0];
Mconex_hf(4,:) =[1 1 1 1 0 0 0 0 0 0];
Mconex_hf(5,:) =[1 1 0 0 1 0 0 0 0 0];
Mconex_hf(6,:) =[1 0 0 0 0 1 0 0 0 0];
Mconex_hf(7,:) =[1 0 0 0 0 1 1 0 0 0];
Mconex_hf(8,:) =[1 0 0 0 0 1 0 1 0 0];
Mconex_hf(9,:) =[1 1 1 1 0 0 0 0 1 0];
Mconex_hf(10,:)=[1 0 0 0 0 1 1 0 0 1];

Mconex_Q=transpose(Mconex_hf);

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
      
      Q=Mconex_Q*qdemand;

      %Pérdida de carga en cada tramo
      hf=IWC(Q,D,k,nu).*L;

      %Carga en cada nodo
      H_nodo=H0-Mconex_hf*hf;
      
      ##Mallado
      %Pareja de nodos ficticios 9,10
      if abs(H_nodo(9)-H_nodo(10))>1e-1
          qdemand(9)=qdemand(9)*(cte+H_nodo(9))/(cte+H_nodo(10))*sign(H_nodo(9)-H_nodo(10));
          qdemand(10)=-qdemand(9);
      endif
      [H_nodo(9) H_nodo(10) qdemand(9)];
      
    endwhile

    if max(Q)>0
      resultado=[resultado;max(Q) max(H_nodo-(z+hreq)) min(H_nodo-(z+hreq))];
      resultado2=[resultado2 H_nodo];
      resultado3=[resultado3 H_nodo-(z+hreq)==min(H_nodo-(z+hreq))];
      resultado4=[resultado4 qdemand];
    endif
    [p i]
  endfor
endfor

subplot(1,2,1)
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
subplot(1,2,2)
bar(distBocas)
xlabel('boca presión mínima');ylabel('frecuencia')

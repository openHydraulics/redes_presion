%Cálculo de red de distribución a presión
clear;clc

%Enlace a funciones en carperta ./src/
addpath('./src/');

resultado=[];
indicadores=[];
distBocas=[];

#Se cargan los datos del caso a estudiar
datos;

for p=0.05:0.05:1 %p representa diversas situaciones: p bajos de escasa demanda (comienzo y final campaña) y p altos (periodo punta) 
  for i=1:100
    %Caudal de cada tramo (tubería)
    
    ## Demanda cuando una boca abastece a uno sólo usuario
    ##qdemand=q.*(rand(8,1)>p);
    
    ## Demanda cuando una boca abastece a múltiples usuarios
    qdemand=q.*p.*rand(8,1);

    H_nodonec=hreq+z;
     
    Q=Mconex_Q*qdemand;

    %Pérdida de carga en cada tramo
     hf=IWC(Q,D,k,nu).*L;

    %Carga necesaria en cabeza para satisfacer a cada nodo
    Hcabnec=H_nodonec+Mconex_hf*hf-z0;
    Hbombeo=max(Hcabnec);
    
    ##
    %Hbombeo=40;
    %Sugerencia a realizar: fijar un valor fijo para "Hbombeo" y analizarlo mediante indicadores.
    %Así enlazamos con el tema siguiente sobre bombeos.
    %De todas formas, se hace en el caso de red_malla.m
    ##
    
    Qbombeo=max(Q);
    
    %Carga en cada nodo
    H_nodo=z0+Hbombeo-Mconex_hf*hf;
    
    %%Indicadores
    %Indicador rendimiento energético
    rendEnerg=sum(qdemand.*H_nodo.*((H_nodo-z)>hreq))/((z0+Hbombeo)*Qbombeo);
    %Coeficiente déficit energético
    coefDef=sum(qdemand.*H_nodo.*((H_nodo-z)<hreq))/sum(qdemand.*H_nodo.*hreq);
      
    if max(Q)>0
      resultado=[resultado;Qbombeo Hbombeo vectorBocas*(Hcabnec==max(Hcabnec))];
      
      %Indicadores
      indicadores=[indicadores; Qbombeo rendEnerg coefDef];
    endif
    [p i]
  endfor
endfor

subplot(1,3,1)
plot(resultado(:,1),resultado(:,2),'+')
axis([0 max(resultado(:,1)) 0 max(resultado(:,2))])
xlabel('Q'); ylabel('H bombeo')
hold on
plot([0 sum(q)],[min(resultado(:,2)) min(resultado(:,2))])
hold off

%resultado(lookup(resultado(:,2),max(resultado(:,2))),:)

% Distribución de bocas que determinan la altura en cabeza
for i=1:8
  distBocas=[distBocas sum(resultado(:,3)==i)];
endfor
distBocas=distBocas./sum(distBocas);
subplot(1,3,2)
bar(distBocas)
xlabel('boca condiciona');ylabel('frecuencia')

subplot(1,3,3)
plot(indicadores(:,1),indicadores(:,2),'+')
axis([0 max(indicadores(:,1)) 0 max(indicadores(:,2))])
xlabel('Q'); ylabel('rend. Energético')
hold on
plot(indicadores(:,1),indicadores(:,3),'+')
hold off
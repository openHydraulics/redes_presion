%Cálculo de red de distribución a presión

%Enlace a funciones en carperta ./src/
addpath('./src/');

## H0, altura en cabeza de la red
## D, diámetros de los tramos
## L, longitudes de los tramos
## k, aspereza de arena equivalente del material de los tubos de los tramos
## nu, viscosidad cinemática

H0=50;D=transpose([0.29135 0.50463 0.65147 0.29135 0.29135]);L=transpose([1000 1000 1000 1000 1000]);k=transpose([4e-5 4e-5 4e-5 4e-5 4e-5]);nu=1.3e-6;

## x, abcisas de los nudos
## y, ordenadas de los nudos
## z, cotas de de los nudos

x=transpose([3000 2000 1000 2000 1000]);
y=transpose([0 0 0 -1000 -1000]);
z=transpose([10 10 10 0 0 ]);

## Matriz de conexiones
## Tramos a recorrer hasta la boca i
Mconex_hf(1,:)=[1 1 1 0 0];
Mconex_hf(2,:)=[0 1 1 0 0];
Mconex_hf(3,:)=[0 0 1 0 0];
Mconex_hf(4,:)=[0 1 1 1 0];
Mconex_hf(5,:)=[0 0 1 0 1];

Mconex_Q=transpose(Mconex_hf);

## Caudal q demandado en cada nodo (boca)
q=transpose([0.1 0.1 0.1 0.1 0.1]);


%Caudal de cada tramo (tubería)
Q=Mconex_Q*q;

%Pérdida de carga en cada tramo
hf=IWC(Q,D,k,nu).*L; 

%Carga en cada nodo
H=H0-Mconex_hf*hf;

%Altura de presión
h=H-z;

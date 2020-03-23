% Datos de la red

## z0, cota del origen del agua
## D, diámetros de los tramos
## L, longitudes de los tramos
## k, aspereza de arena equivalente del material de los tubos de los tramos
## nu, viscosidad cinemática

z0=125;
D=transpose([1.27662 0.78176 0.63831 0.45135 0.45135 0.78176 0.45135 0.45135]);
L=transpose([1000 1000 1000 1000 1000 1000 1000 1000]);
k=transpose([4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5 4e-5]);
nu=1.3e-6;

## Caudal q y altura de presión h demandados en cada nodo (boca)
q=transpose([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1]).*(24/16*16/8);
hreq=transpose([35 35 35 35 35 35 35 35]);


## x, abcisas de los nudos
## y, ordenadas de los nudos
## z, cotas de de los nudos

x=transpose([1000 1000 2000 3000 1000 2000 3000 2000]);
y=transpose([0 -1000 -1000 -1000 -2000 0 0 1000]);
z=transpose([125 125 125 125 125 125 125 125]);

## Matriz de conexiones
## Tramos a recorrer hasta la boca i
Mconex_hf(1,:)=[1 0 0 0 0 0 0 0];
Mconex_hf(2,:)=[1 1 0 0 0 0 0 0];
Mconex_hf(3,:)=[1 1 1 0 0 0 0 0];
Mconex_hf(4,:)=[1 1 1 1 0 0 0 0];
Mconex_hf(5,:)=[1 1 0 0 1 0 0 0];
Mconex_hf(6,:)=[1 0 0 0 0 1 0 0];
Mconex_hf(7,:)=[1 0 0 0 0 1 1 0];
Mconex_hf(8,:)=[1 0 0 0 0 1 0 1];

Mconex_Q=transpose(Mconex_hf);

%Vector 1 al número de bocas
vectorBocas=(1:1:8);
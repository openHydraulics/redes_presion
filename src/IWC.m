%Cálculo de la pendiente motriz en tubos segun White-Colebrook
%Q, D y k pueden ser vectores con el mismo numero de elementos

function I=IWC(Q,D,k,nu)
    I=1e-4*Q./Q ;Ia=2*I;
  while abs(I-Ia)>1e-6
    Ia=I;
    I=(4*Q/pi./D.^2./(-2*log10(k/3.7./D+2.51*nu./D./sqrt(2*9.80665*Ia.*D)))).^2/2/9.80665./D;
  endwhile
endfunction
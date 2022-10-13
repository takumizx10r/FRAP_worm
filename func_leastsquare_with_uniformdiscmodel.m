function [FitPara] = func_leastsquare_with_uniformdiscmodel(y,t,w,K0)

x0=10;
A=[];
b=[];
Aeq=[];
beq=[];
nonlcon=[];
lb=0.0;
ub=inf;
options = optimset('fmincon');
options.Algorithm=('interior-point');

FitPara = fmincon(@LeastSquare,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);

    function Q=LeastSquare(x)
        function F_=func_bessel_fit(x,time)
            F_=1.0+ ( exp(-K0)-1.0 )    ...
                * ( 1.0 - exp(-(w*w)/(2.0*x(1)*time))     ...
                * ( besselj( 0,(w*w/(2.0*x(1)*time) ) ) + besselj( 1,(w*w/(2.0*x(1)*time) ) ) )   );
        end
    sum=0.0;
    for i=1:size(y,1)
        if i==1
            t(i)=1E-20;
        end
        sum=sum+( y(i) - func_bessel_fit( x, t(i)) )^2;
    end
    Q=sum;
    end

end
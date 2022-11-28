function [Fit_initial_Para,D_pix,Sigma] = func_MaxLikelihood_GaussianDist(y,center,para_ini,Interval)


x0=[0.9, 0.5, 100, 0.1, 1.]; %% [a0, a1, rho^2, D, sigma]
A=[];
b=[];
Aeq=[];
beq=[];
nonlcon=[];
lb=[0,  0,  0 , 0,  0];
ub=[inf, inf,   inf,    inf,    inf];
options = optimset('fmincon');
options.Algorithm=('interior-point');

FitPara = fmincon(@MaxLikelihood,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
Fit_initial_Para=FitPara(1,1:3);
D_pix=FitPara(4);
Sigma=FitPara(5);
    function Q=MaxLikelihood(x)

        function F_=func_C_fit(x,r, time)
            F_= x(1)-x(2)/(x(3)+4.0*x(4)*time)...
                *exp( -r*r/(x(3) + +4.0*x(4)*time) );
        end

        sum=double(0.0);
        
        for k=1:size(y,3)
            for j=1:size(y,1)
                for i=1:size(y,2)
                    R = sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                        + (j-center(1,2))*(j-center(1,2) ) );
                    t=Interval*(k-1);
                    sum=sum + ( y(j,i,k) - func_C_fit( x , R,t  ) )^2;
                end
            end
        end

        Q=(-1) * ( -size(y,3)*size(y,1)*size(y,2)/2.0*log(2.0*pi*x(5)*x(5)) - sum / (2.0*x(5)*x(5)) );

    end
end
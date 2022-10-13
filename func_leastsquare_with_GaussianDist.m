function [FitPara] = func_leastsquare_with_GaussianDist(y,center,para_ini,Interval)


x0=1;
A=[];
b=[];
Aeq=[];
beq=[];
nonlcon=[];
lb=0;
ub=inf;
options = optimset('fmincon');
options.Algorithm=('interior-point');

FitPara = fmincon(@LeastSquare,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);

    function Q=LeastSquare(x)
        function F_=func_C_fit(D,r, time)
            F_= para_ini(1)-para_ini(2)/(para_ini(3)+4.0*D*time)...
                *exp( -r*r/(para_ini(3) + +4.0*D*time) );
        end

        sum=double(0.0);
        for k=1:size(y,3)
            for j=1:size(y,1)
                for i=1:size(y,2)
                    R = sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                        + (j-center(1,2))*(j-center(1,2) ) );
                    t=Interval*(k-1);
                    sum=sum+( y(j,i,k) - func_C_fit( x , R,t  ) )^2;
                end
            end
        end

        Q=sum;

    end
end
function [FitPara] = func_leastsquare_with_GaussianDist_determineInitialPara(y,center)

x0=[0.9, 5, 10];
A=[];
b=[];
Aeq=[];
beq=[];
nonlcon=[];
lb=[0.0 0.0 0.0];
ub=[inf inf inf];
options = optimset('fmincon');
options.Algorithm=('interior-point');

FitPara = fmincon(@LeastSquare,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);

    function Q=LeastSquare(x)
        function F_=func_C0_fit(x,r)
            F_= x(1)-x(2)/x(3)*exp( -r*r/x(3) );
        end

        sum=double(0.0);
        for j=1:size(y,1)
%         j=1
%             for i=19:40
            for i=1:size(y,2)
                R = sqrt ( (i-center(1,1)) * (i-center(1,1)) ...
                    + (j-center(1,2))*(j-center(1,2) ) );

                sum=sum+( y(j,i) - func_C0_fit( x , R  ) )^2;
            end
        end
        
        Q=sum;

    end

end
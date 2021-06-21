function z=mse(x,y)

x=double(x);

y=double(y);

[m,n]=size(x);

z=0;

for i=1:m

    for j=1:n

        z=z+(x(i,j)-y(i,j)).^2;

    end

end

z=z/(m*n);
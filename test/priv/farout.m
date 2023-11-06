function continuar = farout(counter,hubs,crd,maxdist)

%FAROUT continue = farout(counter,hubs,data,maxdist)
%       Calculates stop condition.  Stops if the point farthest from its
%       hub is within the average distance value.

index = 0;


    for i = 1:(counter-1)
        for j = i+1 : counter
            index = index + 1;
            dist(index)=norm(crd(hubs(i),:) - crd(hubs(j),:));
        end
    end
    
average_dist = sum(dist)/(2*index);
  if sqrt(maxdist) < average_dist
        continuar = 0;
        else continuar =1;
  end
end                             % end for farout

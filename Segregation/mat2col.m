function   col=mat2col(matrix)
c=0;
%convert half matrix (no diagno)
for i=1:size(matrix,1)-1
    for j=i+1:size(matrix,2)
        c=c+1;
       col(c,1)=matrix(i,j);
    end
end

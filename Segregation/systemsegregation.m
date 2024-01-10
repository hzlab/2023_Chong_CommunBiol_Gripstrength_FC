function [segregation, global_segregation]=systemsegregation(conn_mat, CA)
%conn_mat is the n x n input connectivity matrix. This matrix should only
%have positive connections
%CA is an n x 1 matrix containing modular assignments for each region n

%convert diagonals to 0
conn_mat(logical(eye(size(conn_mat))))=0;

%Only retain positive connections
conn_mat(conn_mat<0)=0;

%Convert CA into nodal assignment matrix CA_mat 
n=length(CA);
CA_mat=zeros(n,n);

for i=1:max(CA)
    CA_mat(CA==i,CA==i)=i;
end

%convert connectivity matrix to column form
conn_col=mat2col(conn_mat);

%compute segregation measure for each module in community structure CA
for c=1:max(CA)
    
    clear Widx Bidx W B
    %Get the indices of all within module connections for the particular
    %module c
    Widx=CA_mat==c;
    
    %Get the indices of all between module connections for the particular
    %module c
    %first identify all the connections linking all nodes in one module to
    %all other nodes in other systems
    Bidx=CA_mat~=c; %Identify all edges that is not assigned as intra-network connections in module c 
    Bidx(CA~=c, CA~=c)=0; %Further set as 0 all inter-network edges that are not connected to module c nodes
    
    %convert indices into column form
    Widx=mat2col(Widx);
    Bidx=mat2col(Bidx);
    
    %obtain mean within-module network connectivity score
    W=mean(conn_col(Widx==1));
    
    %obtain mean between-module network connectivity score
    B=mean(conn_col(Bidx==1));
       
    segregation(1,c)=(W-B)/W;
    
end

%compute global segregation measure - all within module connections versus
%all between module connections
clear Widx Bidx W B
%Get the indices of all within module connections for the particular
%module c
Widx=CA_mat~=0;

%Get the indices of all between module connections for the particular
%module c
Bidx=CA_mat==0; 

%convert indices into column form
Widx=mat2col(Widx);
Bidx=mat2col(Bidx);

%obtain mean within-module network connectivity score
W=mean(conn_col(Widx==1));

%obtain mean between-module network connectivity score
B=mean(conn_col(Bidx==1));

%compute global segregation
global_segregation=(W-B)/W;


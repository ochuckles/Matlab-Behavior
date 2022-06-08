%Determine matrix dimensions
n_cat=size(Y,1); %get rows
n_rep=size(Y,2); %get columns
%Alternatively:  [n_cat,n_rep]=size(Y);

%Create x-axis values
cat=1:n_cat; %enumerate categories
cat=cat'; %Convert into a vertical vector
X=repmat(cat,n_rep,1);


%Linearize the data matrix into a vector
Y=Y(:); 
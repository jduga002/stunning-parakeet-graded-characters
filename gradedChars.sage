Partitions.options.display="exp_high"

R.<q> = ZZ['q']

def gradedChars(n,k,r=0):
   exponents = [0] * n;
   exponents[n-1] = k;
   if r != 0:
      exponents[r-1] = 1
   root = Partition(exp=exponents);
   return root;

def sesAlg(xiPlus):
   l = xiPlus.length()
   
   if xiPlus[l-1] >= xiPlus[0]-1:
      xi = xiPlus.add_cell(l)
   else:
      xi = xiPlus.add_cell(l-1)
   
   first_corner = xi.corners()[0]
   xi = xi.remove_cell(first_corner[0])
   
   l = xi.length()
   
   poly = -q^(l-1)
   
   xi_last = xi[l-1]

   xiMinus = Partition(xi[:l-1])
   for i in range(xi_last):
      xiMinus = xiMinus.remove_cell(l-2)
   
   print(str(xiPlus)+" = " + str(xi) + str(poly) + str(xiMinus))
   
   return (xi,xiMinus,poly)

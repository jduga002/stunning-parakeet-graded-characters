Partitions.options.display="exp_high"

R.<q> = ZZ['q']

def gradedChars(n,k,s=0,r=0):
   root = makePartition(n,k,s=s,r=r)

   charGraph = makeCharGraph(root)

   charGraph.show(edge_labels=True)

   return charGraph

def sesAlg(xiPlus):
   l = xiPlus.length()
   
   if xiPlus[-1] >= xiPlus[0]-1:
      xi = xiPlus.add_cell(l)
   else:
      xi = xiPlus.add_cell(l-1)
   
   first_corner = xi.corners()[0]
   xi = xi.remove_cell(first_corner[0])
   
   l = xi.length()
   xi_last = xi[-1]
   
   poly = -q^((l-1)*(xi_last))

   xiMinus = Partition(xi[:l-1])
   for i in range(xi_last):
      xiMinus = xiMinus.remove_cell(l-2)
   
#   print(str(xiPlus)+" = " + str(xi) + str(poly) + str(xiMinus))

   return (xi,xiMinus,poly)

# Makes a partition of the form n^k (n-1)^s r
def makePartition(n,k,s=0,r=0):
   exponents = [0] * n;
   exponents[n-1] = k;
   exponents[n-2] = s;
   if r > 0 and r < n-1:
      exponents[r-1] = 1
   return Partition(exp=exponents);

def makeCharGraph(root):
   n = root[0]
   G = DiGraph([[root],[]])
   graph_iter = { root }
   
#  while graph_iter is not empty
   while graph_iter:
      p = graph_iter.pop()
      if (not p.is_empty() and p[0] == n):
         tuple = sesAlg(p)

#        TODO:
#        for efficiency's sake, should only add new partitions to
#        iterator if haven't already done them (since can get same
#        partition more than once through process)
         graph_iter.update(tuple[:2])

         G.add_vertices(tuple[:2])
         G.add_edges([(p,tuple[0],1), (p,tuple[1],tuple[2])])
   return G

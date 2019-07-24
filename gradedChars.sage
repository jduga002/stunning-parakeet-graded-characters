Partitions.options.display="exp_high"
Partitions.options.latex="exp_high"

R.<q> = ZZ['q']

def gradedChars(n,k,s=0,r=0,showGraph=False,showGradedChar=False):
   root = makePartition(n,k,s=s,r=r)

   charGraph = makeCharGraph(root)

   if showGraph:
      charGraph.show(edge_labels=True)

   gradedCharacter = calcGradedChar(charGraph,root)

   if showGradedChar:
      displayGradedChar(gradedCharacter)

   return charGraph, gradedCharacter

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
   G = DiGraph([[root],[]],weighted=True)
   graph_iter = { root }
   
#  while graph_iter is not empty
   while graph_iter:
      p = graph_iter.pop()
      if (not p.is_empty() and p[0] == n):
         xi, xiMinus, poly = sesAlg(p)

#        TODO:
#        for efficiency's sake, should only add new partitions to
#        iterator if haven't already done them (since can get same
#        partition more than once through process)
         graph_iter.update([xi, xiMinus])

         G.add_vertices([xi, xiMinus])
         G.add_edges([(p,xi,1), (p,xiMinus,poly)])
   return G

def calcGradedChar(charGraph,root):
   gradedCharDict = { }
   for node in charGraph.sinks():
      coeff_poly = 0
      for path in charGraph.all_paths(root, node, report_edges=True, labels=True):
         poly = 1
         for edge in path:
            poly *= edge[2]
         coeff_poly += poly
      if coeff_poly != 0:
         gradedCharDict[node] = coeff_poly
   return root, gradedCharDict

def displayGradedChar(gradedCharacter):
   root = gradedCharacter[0]
   gradedCharDict = gradedCharacter[1]
   output = '[' + repr(root) + '] = '
   k = 0
   for partition, poly in gradedCharDict.items():
      if k > 0:
         output += ' + '
      k += 1
      if poly != 1:
         if not poly.is_term():
            output += '('
         output += str(poly)
         if not poly.is_term():
            output += ')'
      output += '[' + repr(partition) + ']'
   print(output)

def latexGradedChar(gradedCharacter):
   root = gradedCharacter[0]
   gradedCharDict = gradedCharacter[1]
   output = '[' + latex(root) + '] = '
   k = 0
   for partition, poly in gradedCharDict.items():
      if k > 0:
         output += ' + '
      k += 1
      if poly != 1:
         if not poly.is_term():
            output += '('
         output += latex(poly)
         if not poly.is_term():
            output += ')'
      output += '[' + latex(partition) + ']'
   return output

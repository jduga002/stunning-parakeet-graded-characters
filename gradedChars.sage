Partitions.options.display="exp_high"
Partitions.options.latex="exp_high"

R.<q> = ZZ['q']

# calculates the graded character of a Demazure module D(m,Lambda) in terms
# of level l Demazure modules (default is l=n-1)
# NOTE: this code breaks if Lambda < m
def gradedCharOfDemazure(m,Lambda,l=1,showGraph=False,showGradedChar=False):
   root = DemazureToCV(m,Lambda)
   return gradedCharsFromPartition(root,l,showGraph,showGradedChar)

# calculates the graded character of a CV-module associated to the partition
# n^k,(n-1)^s,r for s >= 0, 0 <= r < n-1, in terms of level l Demazure modules
# (default is l = n-1)
def gradedChars(n,k,s=0,r=0,l=-1,showGraph=False,showGradedChar=False):
   root = makePartition(n,k,s=s,r=r)
   return gradedCharsFromPartition(root,l,showGraph,showGradedChar)

# calculates the graded character of a CV-module associated to the partition root,
# which must be of the form n^k,(n-1)^s,r for s >= 0, 0 <= r < n-1,
# in terms of level l Demazure modules (default is l=n-1)
def gradedCharsFromPartition(root,l=-1,showGraph=False,showGradedChar=False):

   if l < 0:
      l = root[0]-1

   charGraph = makeCharGraph(root,l)

   if showGraph:
      charGraph.show(edge_labels=True)

   gradedCharacter = calcGradedChar(charGraph,root)

   if showGradedChar:
      displayGradedChar(gradedCharacter)

   return charGraph, gradedCharacter

# xiPlus is a partition of the form n^k,(n-1)^s,r for s >= 0, 0 <= r < n-1
def sesAlg(xiPlus):
   l = xiPlus.length()  #l is number of parts of partition xi
   
   # We start constructing xi:
   if xiPlus[-1] >= xiPlus[0]-1: # if r = 0, we add a new row with one cell
      xi = xiPlus.add_cell(l)
   else:                         # otherwise, add a cell to the last row (so r becomes r+1)
      xi = xiPlus.add_cell(l-1) 

   # Then we remove a cell from one of the rows of length n to complete the construction of xi
   first_corner = xi.corners()[0]
   xi = xi.remove_cell(first_corner[0])
    
   l = xi.length()  # l is now the number of parts of xi
   xi_last = xi[-1] # xi_last is the last part of xi
    
   poly = -q^((l-1)*(xi_last)) # get grade shift

   # To get xiMinus, remove the last row of partition xi
   xiMinus = Partition(xi[:l-1])
   # Then remove same amount of cells from second to last row of partition
   for i in range(xi_last):
      xiMinus = xiMinus.remove_cell(l-2)
   
#   print(str(xiPlus)+" = " + str(xi) + str(poly) + str(xiMinus))

   return (xi,xiMinus,poly)

# Makes a partition of the form n^k,(n-1)^s,r for s >= 0, 0 <= r < n-1
def makePartition(n,k,s=0,r=0):
   exponents = [0] * n;
   exponents[n-1] = k;
   exponents[n-2] = s;
   if r > 0 and r < n-1:
      exponents[r-1] = 1
   return Partition(exp=exponents);

def makeCharGraph(root,l):
   n = root[0]
   G = DiGraph([[root],[]],weighted=True)
   graph_iter = { root }
   
#  while graph_iter is not empty
   while graph_iter:
      p = graph_iter.pop()
      if (not p.is_empty() and p[0] > l):
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
   gradedCharDict = [ ]
   for node in sorted(charGraph.sinks(), reverse=True):
      coeff_poly = 0
      for path in charGraph.all_paths(root, node, report_edges=True, labels=True):
         poly = 1
         for edge in path:
            poly *= edge[2]
         coeff_poly += poly
      if coeff_poly != 0:
         gradedCharDict.append((node, coeff_poly))
   return root, gradedCharDict

def displayGradedChar(gradedCharacter):
   root = gradedCharacter[0]
   gradedCharDict = gradedCharacter[1]
   output = '[' + repr(root) + '] = '
   k = 0
   for partition, poly in gradedCharDict:
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
   for partition, poly in gradedCharDict:
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

# Gives the partition associated to a level m Demazure module of highest
# weight Lambda when thinking about it as a CV-module
def DemazureToCV(m,Lambda):
   quotient = int(Lambda) / int(m)
   remainder = Lambda % m
   return makePartition(n=m,k=quotient,r=remainder) if remainder < m-1 else makePartition(n=m,k=quotient,s=1)

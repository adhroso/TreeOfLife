# TreeOfLife
Relationships between objects


#Download at: 
https://github.com/adhroso/TreeOfLife.git
or 
git@github.com:adhroso/TreeOfLife.git

Tree of life shows the relationship between objects with respect to some attribute.
In this prototype, we have demonstrated the similarity between 7 nucleotide 
sequences by using the minimum character substitution/insertion in order to convert
one sequence to another (using the Levenshtein Distance as the measuring device).
The algorithm clusters these sequences using single-linkage clustering 
(minimum of object distances).
Current implementation supports only the Levenshtein Distance as its measuring device,
however, it is trivial to add additional distance measuring algorithms. Height between
branches is currently set as a fixed distance. Future implementation should allow
the distance to be dynamic to give users insights on the data being visualized.
Current implementation does not have any restrictions on object types being clusters.
(one is able to visualize same data set via varius attributes. Prototype default is sequences similarity)


input file format: attribute:value,attribute,value....
output: dendrogram visualization

It is noteworthy to mention that this is a prototype and meant only as a proof of concept 
and not be used in a production environment. 

#how to run
0. Download or clone the repository from github
1. unzip 
2. Open Processing
3. Via Processing, click open and navigate to the unzipped location.
4. Select the tre_of_life.pde and click open.
5. Processing will warn you source file not being in a sketcher directory. Click OK.
6. Click the run button

note: make sure data file exists in the same directory as the source code


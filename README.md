#This is a ruby answer to the question -

How would you establish friendship chains to determine whether one person is connected to another person with a big-o notation of O(1) constant time.

(My solution is set up to place all connected in a single group. If two people in groups become friends, it looks for the member in the smallest group and recurses through and changes there group to the larger one.)
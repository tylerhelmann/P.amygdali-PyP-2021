
# Return True if an ortholog is present in single copy in all strains.

single_copy_ortholog <- function(row, matrix){
  # Quick check for disqualifying strains w/ multiple or 0 copies.
  for (col in c(2:ncol(matrix))) {
    if (matrix[row, col] != 1) {return(FALSE)}
  }
  return(TRUE)
}

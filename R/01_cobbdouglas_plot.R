# 01_cobbdouglas_plot.R

A = 1.2
alpha = 0.3
cobbdouglas = function(k) {
  return(A * k ^ alpha)
}

k = seq(0, 10, length.out=200)
y = cobbdouglas(k)
plot(k, y, type='l')

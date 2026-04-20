data {
  int<lower=0> n;
  array[n] int<lower=0> y;
  vector[n] prop_night;
  vector[n] prop_apartment;
  vector[n] avg_delay;
  vector[n] income;
}
parameters {
  real b0;
  real b1;
  real b2;
  real b3;
  real b4;
}
model {
  b0 ~ normal(3.32, 0.5);
  b1 ~ normal(0, 0.5);
  b2 ~ normal(0, 0.5);
  b3 ~ normal(0, 0.5);
  b4 ~ normal(0, 0.5);

  y ~ poisson_log(b0 + b1*prop_night + b2*prop_apartment +
                  b3*avg_delay + b4*income);
}

generated quantities {
  array[n] int y_rep;
  for (i in 1:n)
    y_rep[i] = poisson_log_rng(b0 + b1*prop_night[i] + b2*prop_apartment[i] +
                                b3*avg_delay[i] + b4*income[i]);
}

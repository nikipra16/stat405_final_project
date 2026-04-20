data {
  int<lower=0> n;
  int<lower=0> J;
  array[n] int<lower=0> y;
  vector[n] prop_night;
  vector[n] prop_apartment;
  vector[n] avg_delay;
  vector[n] income;
  array[n] int<lower=1, upper=J> neighbourhood_id;
}
parameters {
  real b0;
  real b1;
  real b2;
  real b3;
  real b4;
  real mu_b;
  real<lower=1e-6> tau_b;
  vector[J] u;
  real<lower=1e-6>sigma;
}
model {
  mu_b  ~ normal(0, 0.5);
  tau_b ~ exponential(1);
  
  b0 ~ normal(3.32, 0.5);
  b1 ~ normal(mu_b, tau_b);
  b2 ~ normal(mu_b, tau_b);
  b3 ~ normal(mu_b, tau_b);
  b4 ~ normal(mu_b, tau_b);
  
  sigma ~ exponential(0.3);
  u ~ normal(0, sigma);
  
  for (i in 1:n)
    y[i] ~ poisson_log(b0 + b1*prop_night[i] + b2*prop_apartment[i] +
                       b3*avg_delay[i] + b4*income[i] + u[neighbourhood_id[i]]);
}
generated quantities {
  array[n] int y_rep;
  for (i in 1:n)
    y_rep[i] = poisson_log_rng(b0 + b1*prop_night[i] + b2*prop_apartment[i] +
                                b3*avg_delay[i] + b4*income[i] + u[neighbourhood_id[i]]);
}

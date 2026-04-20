data {
  int<lower=0> n;
  int<lower=0> J;
  array[n] int<lower=0> y;
  vector[n] prop_night;
  vector[n] prop_apartment;
  vector[n] avg_delay;
  vector[n] income;
  array[n] int<lower=1, upper=J> neighbourhood_id;
  real prop_night_pred;
  real prop_apartment_pred;
  real avg_delay_pred;
  real income_pred;
  int<lower=1, upper=J> neighbourhood_id_pred;
}
parameters {
  real b0;
  real b1;
  real b2;
  real b3;
  real b4;
  vector[J] u;
  real<lower=1e-6> sigma;
}
model {
  b0~ normal(3.32,0.5);
  b1 ~ normal(0, 0.5);
  b2 ~ normal(0, 0.5);
  b3 ~ normal(0, 0.5);
  b4 ~ normal(0, 0.5);
  
  sigma ~ exponential(0.3);
  u ~ normal(0, sigma);
  for (i in 1:n)
    y[i] ~ poisson_log(b0 + b1*prop_night[i] + b2*prop_apartment[i] +
                       b3*avg_delay[i] + b4*income[i] + u[neighbourhood_id[i]]);
}
generated quantities {
  int y_pred = poisson_log_rng(b0 + b1*prop_night_pred + b2*prop_apartment_pred +
                                b3*avg_delay_pred + b4*income_pred + 
                                u[neighbourhood_id_pred]);
}

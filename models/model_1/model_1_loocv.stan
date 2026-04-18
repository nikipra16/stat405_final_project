data {
  int<lower=0> n;
  array[n] int<lower=0> y;
  vector[n] prop_night;
  vector[n] prop_apartment;
  vector[n] avg_delay;
  vector[n] prop_weekend;
  vector[n] income;
  real prop_night_pred;
  real prop_apartment_pred;
  real avg_delay_pred;
  real prop_weekend_pred;
  real income_pred;
}
parameters {
  real b0;
  real b1;
  real b2;
  real b3;
  real b4;
  real b5;
}
model {
  b0 ~ normal(3.32, 0.5);
  b1 ~ normal(0, 0.5);
  b2 ~ normal(0, 0.5);
  b3 ~ normal(0, 0.5);
  b4 ~ normal(0, 0.5);
  b5 ~ normal(0, 0.5);

  y ~ poisson_log(b0 + b1*prop_night + b2*prop_apartment +
                  b3*avg_delay + b4*income + b5*prop_weekend);
}

generated quantities {
  int y_pred = poisson_log_rng(b0 + b1*prop_night_pred + b2*prop_apartment_pred +
                                b3*avg_delay_pred + b4*income_pred +b5*prop_weekend_pred);
}

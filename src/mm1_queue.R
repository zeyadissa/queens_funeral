# Dependancies -----

source('const/glob.R')

# Override global options ----

#Time for respect
mu <- 4
#arrivals lambda
mu_2 <- 4
#queue size in m/m/1/k model
#queue_size <- 10
#Simulation time
sim_time <- 240

# Erlang-C (M/M/1 queue) ------

#Simple queuing model 1; 
#M/M/1/Inf - FIFO
#One server, in this case, the Queen,
#Infinite queue size, no pre-emption

set.seed(1234)

#Mourner trajectory
mourner <- simmer::trajectory() |> 
  simmer::log_('Mourner ARRIVES at the queue') |> 
  simmer::log_('Mourner is WAITING') |> 
  #mourner seizes the Queen
  simmer::seize('queen',1) |> 
  #Paying respects
  simmer::timeout(rexp(1,mu)) |> 
  simmer::log_('Mourner is PAYING RESPECTS') |> 
  simmer::release('queen',1) |> 
  simmer::log_('Mourner DEPARTS') 


mm1 <-simmer::simmer('sim') |>
  simmer::add_resource("queen", 
                       #There can only be one Queen
                       capacity = 1, 
                       queue_size=Inf)  |>
  simmer::add_generator("Mourner", mourner, function() rexp(1, mu_2)) |>
  simmer::run() 

#Actual simulation
mm1 <- parallel::mclapply(1:100, function(i) {
  simmer::simmer('sim') |>
    simmer::add_resource("queen", 
                         #There can only be one Queen
                         capacity = 1, 
                         queue_size=Inf)  |>
    simmer::add_generator("Mourner", mourner, function() rexp(1, mu_2)) |>
    simmer::run(until=sim_time) |> 
    simmer::wrap()
  },
  mc.set.seed = FALSE)

# Simulation outputs -----

arrivals <- simmer.plot::get_mon_arrivals(mm1,ongoing=T)
resources <- simmer.plot::get_mon_resources(mm1)
arrivals_per_resource <- simmer::get_mon_arrivals(mm1,per_resource=T)

# Resource utilisation -----

plot(resources, metric = "usage", c("queen"), items = "server")
plot(resources, metric = "utilization")

# Flow times -----
plot(arrivals, metric = "flow_time")


# Dependancies -----

source('const/glob.R')

# Override global options ----

#Time for respect
#mu <- 2
#arrivals lambda
#lambda <- 3
#queue size in m/m/1/k model
#queue_size <- 10
#Simulation time
#sim_time <- 100
#renege_time <- 5

# Deterministic Reneging System (M/M/1 queue) ------

#Simple queuing model 1; 
#M/M/1/Inf - FIFO
#One server, in this case, the Queen,
#Infinite queue size, no pre-emption
#Reneging is deterministically given

#Mourner trajectory with a reneging system
mourner <- simmer::trajectory() |> 
  simmer::log_('Mourner ARRIVES at the queue') |> 
  simmer::log_('Mourner is WAITING') |> 
  simmer::renege_in(renege_time, 
                    out = simmer::trajectory() |> 
                      simmer::log_("Mourner is RENEGING...")) |> 
  #mourner seizes the queen
  simmer::seize('queen',1) |> 
  simmer::renege_abort() |> 
  simmer::log_("Mourner is being ATTENDED ") |> 
  #Paying respects
  simmer::timeout(rexp(1,mu)) |> 
  simmer::log_('Mourner is PAYING RESPECTS') |> 
  simmer::release('queen',1) |> 
  simmer::log_('Mourner DEPARTS')

#Actual simulation
deterministic_mm1 <- simmer::simmer('sim') |>
  simmer::add_resource("queen", 
                       #There can only be one Queen
                       capacity = 1, 
                       queue_size=Inf, 
                       queue_size_strict=T, 
                       preemptive=F)  |>
  simmer::add_generator("Mourner", mourner, function() rexp(1, lambda)) |>
  simmer::run(until=sim_time)

# Simulation outputs -----

arrivals <- simmer.plot::get_mon_arrivals(mm1k,ongoing=T)
resources <- simmer.plot::get_mon_resources(mm1k)
arrivals_per_resource <- simmer::get_mon_arrivals(mm1k,per_resource=T)

# Resource utilisation -----

plot(resources, metric = "usage", c("queen"), items = "server")
plot(resources, metric = "utilization")

# Flow times -----
plot(arrivals, metric = "flow_time")
plot(arrivals, metric = "waiting_time")

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

# Finite Buffer (M/M/1/K queue) ------

#Simple queuing model 1; 
#M/M/1/k - FIFO
#One server, in this case, the Queen,
#FINITE queue size, no pre-emption

#Actual simulation
mm1k <- simmer::simmer('sim') |>
  simmer::add_resource("queen", 
                       #There can only be one Queen
                       capacity = 1, 
                       queue_size=queue_size, 
                       queue_size_strict=T, 
                       preemptive=F)  |>
  simmer::add_generator("Mourner", mourner, function() rexp(1, lambda), mon=1) |>
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

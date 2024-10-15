# Dependancies -----

source('const/glob.R')

# Erlang-C (M/M/1 queue) ------

#Simple queuing model 1; 
#M/M/1/Inf - FIFO
#One server, in this case, the Queen,
#Infinite queue size, no pre-emption

#Mourner trajectory
mourner <- simmer::trajectory() |> 
  simmer::log_('Mourner ARRIVES at the queue') |> 
  simmer::log_('Mourner is WAITING') |> 
  #mourner seizes the queen
  simmer::seize('queen',1) |> 
  #Paying respects
  simmer::timeout(rexp(1,mu)) |> 
  simmer::log_('Mourner is PAYING RESPECTS') |> 
  simmer::release('queen',1) |> 
  simmer::log_('Mourner DEPARTS') 

#Actual simulation
mm1 <- simmer::simmer('sim') |>
  simmer::add_resource("queen", 
                       #There can only be one Queen
                       capacity = 1, 
                       queue_size=Inf, 
                       queue_size_strict=T, 
                       preemptive=F)  |>
  simmer::add_generator("Mourner", mourner, function() rexp(1, lambda)) |>
  simmer::run(until=sim_time)

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

# Generalised Erlang-C (M/M/1/Inf queue) ------

#Simple queuing model 1; 
#This is a generalised solution of the above
#Infinite servers, in this case, the Queen,
#Infinite queue size, no pre-emption



# Dependencies -----

source('const/glob.R')

# Override global options ----

#Time for respect
mu <- 1
#arrivals lambda
lambda <- 117
#Simulation time
sim_time <- 240

# Deterministic Reneging System (M/M/2/Inf queue) ------

#This is the greatest question of our time: Did Holly Willoughby (and others) skip 
#the queue? We don't have the actual underlying data, but we have a best guess.

#There are two queues in this system, the disabled queue and the 
#the non-disabled queue. for ease, let's just assume 

#Assumptions:
#Queue length was 5 miles: 8km
#Assuming each person needed 50cm2 for space (which is unlikely) then
#the base estimate for that specific day is ~160,000 people.
#from news reports, this seems reasonable. we will consider that the base.
#Let us take arrival time then as 170,000/day; in other words, 7000 people an hour
# For ease of estimates, we will say that 7 units (a unit being 1,000 people) arrive
# every hour. In this case, we treat units as batches (note about how to do this in simmer)
# 117 per minute is 7000 per hour.

#FIRST POINT: mu2 = 117

#Then we need to think about the service time. How long does it take to say goodbye to queenie?
#I'm going to say it's probably a few minutes, at least according to news sources,
#so we can assume 3 minutes, therefore...

#SECOND POINT: MU = 0.05

#Now we need to think about the system: is there any renege? Who would, in their
#right mind, ever leave this greatest of all queues? OPEN QUESTION

#THIRD POINT: Reneging Y/N?

#What about K, does this queue have a limit?

#FOURTH POINT: K = Inf

holly <- simmer::trajectory() |> 
  simmer::log_('Mourner ARRIVES at the queue') |> 
  simmer::log_('Mourner is WAITING') |> 
  #mourner seizes the queen
  simmer::seize('queen',1) |> 
  #Paying respects
  simmer::timeout(rexp(1,mu)) |> 
  simmer::log_('Mourner is PAYING RESPECTS') |> 
  simmer::release('queen',1) |> 
  simmer::log_('Mourner DEPARTS')

holly_queue <- parallel::mclapply(1:100, function(i) {
  simmer::simmer('sim') |>
    simmer::add_resource("queen", 
                         #There can only be one Queen
                         capacity = 1)  |>
    simmer::add_generator("Mourner", holly, function() rexp(1,lambda)) |>
    simmer::run(until = sim_time) |> 
    simmer::wrap()
})

# Simulation outputs -----

arrivals <- simmer.plot::get_mon_arrivals(holly_queue,ongoing=T)
resources <- simmer.plot::get_mon_resources(holly_queue)

# Resource utilisation -----

plot(resources, metric = c("usage"), c("queen"),'server')
plot(resources, metric = "utilization")

# Flow times -----

plot(arrivals,'waiting_time')


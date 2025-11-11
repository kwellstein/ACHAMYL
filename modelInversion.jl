# Jo Modeling Script
using HierarchicalGaussianFiltering
using ActionModels
using StatsPlots
using Glob, CSV, DataFrames #For loading the data
using JLD2 #For saving the results

action_model = ActionModel(HGFSoftmax(; HGF = "binary_3level"))
agent = init_agent(action_model, save_history = :xbin_prediction_mean)

# create agent
get_states(agent)
get_parameters(agent)

# amend parameter values
set_parameters!(agent, (; xvol_initial_precision = 0.9))

# add inputs (experiment outcomes)
inputs = 
    [0,0,1,0,0,0,0,1,1,0,1,1,0,1,1,1,0,0,1,0,1,1,0,1,1,0,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,1,1,1,1,1,0,0,1,0,
     1,0,0,1,0,0,0,0,1,0,1,0,1,0,0,1,0,0,1,1,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,0,1,1,0,0,1,0,1,0,0,1,0,1,1,1,0,1,
     0,0,1,0,1,0,1,1,0,1,1,0,0,1,0,1,1,0,0,1,1,0,0,0,1,1,0,1,0,0,0,1,1,0,0,1,0,0,1,1,1,1,1,0,1,0,0,0,0,1,0,1,1,0,1,0,
     1,1,0,0,1,0,1,0,0,1,1,0,0,0,0,1,1,1,0,0,1,1,0,1,0,1,0,0,0,0,1,1,1,0,1,1,0,0,0,0,1,1,1,0,0,0,1,0,1,1,1,0,1,1,1,0,
     0,1,0,0,1,0,1,1,0,1,1,0,0,0,1,1,0,1,0,1,1,0,0,1,0,0,0,0,0,1,0,1,1,1,1,0,1,0,0,0,1,0,1,0,1,1,1,0,1,1,1,1,0,0,1,1,
     1,0,0,0,0,0,1,1,0,1,1,0,1,1,0,1,0,1,1,1,0,0,1,0,1,0,1,0,0,1,1,0,0,1,0,1,0,0,0,1]

# simulate agent
actions = simulate!(agent, inputs)

plot(agent, ("u", "input_value"))
plot!(agent, ("xbin", "prediction"))

plot(agent, ("u", "input_value"))
plot!(actions .+ 0.1, seriestype = :scatter, label = "action")
plot!(agent, ("xbin", "prediction"))

# use real behaviour
actions = [1,1,1,0,1,0,0,1,0,0,1,1,0,0,1,1,0,1,1,0,0,0,0,1,1,0,0,0,0,0,NaN64,1,0,1,1,1,1,1,1,0,1,0,0,1,0,0,1,1,0,1,1,1,
            0,0,1,0,1,1,1,0,0,1,0,1,1,0,1,0,1,0,0,1,0,0,1,1,0,0,1,0,1,0,0,0,0,1,1,0,0,1,1,0,1,1,1,1,1,1,0,0,1,0,0,0,1,
            1,0,1,0,0,0,1,0,1,1,1,0,1,1,0,1,1,0,0,0,1,0,0,0,1,1,1,1,1,1,0,0,1,1,0,1,1,0,0,1,1,1,0,0,0,1,0,0,1,1,1,1,0,
            0,1,1,0,1,0,0,1,0,1,0,0,0,1,1,1,1,0,0,1,1,1,0,0,0,1,0,1,0,0,1,1,0,1,1,0,1,1,1,1,0,0,1,0,0,0,1,0,1,1,0,1,1,
            1,0,1,0,1,0,1,1,0,0,1,0,0,1,1,1,1,0,1,1,1,1,0,0,1,0,1,1,0,0,0,0,1,0,1,0,0,1,0,0,1,1,0,1,0,0,0,1,1,0,1,0,1,
            1,1,1,0,0,0,1,1,0,1,1,0,0,0,0,1,0,1,1,1,1,0,1,0,0,1,1,0,1,0,0,1,1,1,1,1,0,0,1,1,1,0,1,0,0,0,1,0,1,0,0,1,1,1,0,1]

# fitting
prior = (; xprob_volatility = Normal(-7, 0.5))

#Create model
model = create_model(action_model, prior, inputs, check_parameter_rejections = true)

#Fit
posterior_chains = sample_posterior!(model, n_samples = 200, n_chains = 2)
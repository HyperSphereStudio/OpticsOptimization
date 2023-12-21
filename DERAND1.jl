"Adapted From: https://machinelearningmastery.com/differential-evolution-from-scratch-in-python/"
#Written By Johnathan Bizzano

export diffevorandomsinglebin!

#Mutate the genes
mutate(a, b, c, scalefactor) = a + scalefactor * (b - c) 

#Perform gene binomial crossover & clip the mutated genes
function clipNCrossover(mutated, bound, target, cr)
    if rand() >= cr
        return target
    end
    if mutated < first(bound)
        return first(bound)
    elseif mutated > last(bound)
        return last(bound)
    end
    return mutated
end

function choose_individual(population_size, excluded_individuals...)
    choice = rand(1:population_size)
    while choice in excluded_individuals
        choice = rand(1:population_size)
    end
    choice
end

init_rand(bound) = rand(bound)


"""Differential Evolution of DeRand1Bin algorithm. ScaleFactor ∈ [0, 2]. CrossoverRate ∈ [0, 1].
   Writes the outputs to the initial values.
   The throttle function takes in the index, current best error and best index. It returns if it should continue to the next iteration or not"""
function diffevorandomsinglebin!(error_func, initial_values, 
            bounds, population_size, iterations; 
            scalefactor = .8, crossoverrate = .7, throttleFunction=nothing)

    (scalefactor > 2 || scalefactor < 0) && error("Scale Factor ∈ [0, 2]")
    (crossoverrate > 1 || crossoverrate < 0) && error("Cross Over Rate ∈ [0, 1]")
    (population_size < 4) && error("Population Size Must Be > 3")

    dims = length(initial_values)
    mutated = similar(initial_values, dims)
    errors = similar(initial_values, population_size)
    
    #Create Population with Initial Values as first entry
    population = similar(initial_values, population_size, dims)

    #Create Population Views to avoid reallocing views 
    individuals = collect(eachrow(population))

    #Copy the initial values to the main population array
    copy!(individuals[1], initial_values)

    #Initialize Random
    broadcast!(init_rand, view(population, 2:population_size, 1:dims), bounds)

    #Init Eval
    broadcast!(error_func, errors, individuals)
 
    #Find the Best Init Performer
    best_idx = argmin(errors)
    best_error = errors[best_idx]
    prev_error = best_error

    for i in 1:iterations
        #Iterate all current Solutions
        for j in 1:population_size
            selected = individuals[j]
            #Choose Three Individuals in Population (Not Current)
            idx1 = choose_individual(population_size, j)
            idx2 = choose_individual(population_size, j, idx1)
            idx3 = choose_individual(population_size, j, idx1, idx2)
        
            broadcast!(mutate, mutated, individuals[idx1], individuals[idx2], individuals[idx3], scalefactor)
            broadcast!(clipNCrossover, mutated, mutated, bounds, selected, crossoverrate)

            #Check to see if crossover was better then current individual
            crossover_error = error_func(mutated)
            if crossover_error < error_func(selected)
                copy!(selected, mutated)
                errors[j] = crossover_error
            end
        end

        #Check Best Performer in this iteratation
        idx = argmin(errors) 
        if errors[idx] < prev_error
            prev_error = errors[idx]
            best_error = prev_error
            best_idx = idx
        end

        if throttleFunction !== nothing
            (!throttleFunction(i, best_error, best_idx)) && break
        end
    end

    copy!(initial_values, individuals[best_idx]) 

    return (initial_values, best_error)
end

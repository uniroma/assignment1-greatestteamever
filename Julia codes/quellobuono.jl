using CSV
using DataFrames
using Dates
using LinearAlgebra
using Plots

#Prova
# Load the dataset
df = CSV.read("/Users/edoardodicosimo/Documents/Magistrale/ctfme/current.csv", DataFrame)

# Clean the DataFrame by removing the row with transformation codes
df_cleaned = df[2:end, :]
date_format = "mm/dd/yyyy"
df_cleaned[!, :sasdate] = Dates.Date.(df_cleaned[!, :sasdate], date_format)


df_original = copy(df_cleaned)
df_cleaned = coalesce.(df_cleaned, NaN)
df_original = coalesce.(df_original, NaN)
## Create a DataFrame with the transformation codes
transformation_codes = DataFrame(Series = names(df)[2:end], 
                                 Transformation_Code = collect(df[1, 2:end]))

# Function to apply transformations based on the transformation code
function apply_transformation(series, code)
    if code == 1
        # No transformation
        return series
    elseif code == 2
        # First difference
        return mdiff(series)
    elseif code == 3
        # Second difference
        return mdiff(mdiff(series))
    elseif code == 4
        # Log
        return log.(series)
    elseif code == 5
        # First difference of log
        return mdiff(log.(series))
    elseif code == 6
        # Second difference of log
        return mdiff(mdiff(log.(series)))
    elseif code == 7
        # Delta (x_t/x_{t-1} - 1)
        return series ./ lag(series, 1) .- 1
    else
        throw(ArgumentError("Invalid transformation code"))
    end
end


# Helper function to lag a series; 
# Julia does not have a built-in lag function like R or pandas
function lag(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [nan; v[1:(end-l)]]
end

function lead(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [v[(l+1):end]; nan]
end

## mdiff function to calculate the first difference of a series
## keeping the missing values
function mdiff(v::Vector)
    return v .- lag(v, 1)
end


# Applying the transformations to each column in df_cleaned based on transformation_codes
for row in eachrow(transformation_codes)
    series_name = Symbol(row[:Series])
    code = row[:Transformation_Code]
    @show series_name, code
    df_cleaned[!, series_name] = apply_transformation(df_cleaned[!, series_name], code)
end


## The transformation create missing values at the top
## These remove the missing values at the top of the dataframe
df_cleaned = df_cleaned[3:end, :]


H = [1 4 8]
p = 4
end_date = "12/01/1999"
end_date = Dates.Date.(end_date,date_format)

y_hat = []


function calcolaforecast(target::Vector,x_var::Matrix)
   
    rt_df = filter(row -> row[:sasdate] <= end_date, df_cleaned)
    y_actual = []

    for h in H
        os = end_date + Dates.Month(h)
        push!(y_actual, (filter(row -> row[:sasdate] == os, df_cleaned)))
        #push!(y_actual, df_cleaned[df_cleaned[!,:sasdate] .== os, target] .* 100)
        #return rigayact = df_cleaned[]
        
    end
    y_actualissimo = vcat(y_actual[1],y_actual[2],y_actual[3])
    
   @show(y_actualissimo)

    #return y_actualissimo
    #y_raw = df_cleaned[!, :INDPRO]

    #x_raw = Matrix(df_cleaned[!, [:CPIAUCSL, :FEDFUNDS]])

    x_raw = x_var
    y_raw = target
    
    

    Y_target = lead(y_raw, 1)
    Y_lagged = hcat([lag(y_raw, p) for i in 1:p]...)
    X_lagged = hcat([lag(x_raw[:, j], i) for j in 1:size(x_raw, 2) for i in 1:p]...)
    
    X = hcat(ones(size(Y_lagged, 1)), Y_lagged, X_lagged)
  
    X_T = X[end, :]
    
    for h in H
        y_h = lead(y_raw, h)
        y  = y_h[p+1:(end-h)]
        X_ = X[p+1:(end-h), :]
        beta_ols = X_ \ y
        forecast = (X_T' * beta_ols) * 100

        push!(y_hat,forecast)
        
    end
    return y_hat


    errore = y_actualissimo[!,:INDPRO] - y_hat
    erroresqrd = ((sum(errore))^2)/size(errore,1)
    return erroresqrd

end

calcolaforecast(df_cleaned[!, :INDPRO],Matrix(df_cleaned[!, [:CPIAUCSL, :FEDFUNDS]]))

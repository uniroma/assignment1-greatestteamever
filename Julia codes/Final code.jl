using CSV
using DataFrames
using Dates
using LinearAlgebra
using Plots
using Statistics
# WORK WITH THE DATASET
### Load the dataset
df = CSV.read("C:\\Users\\tokyo\\Downloads\\current.csv", DataFrame)

### Clean the DataFrame by removing the row with transformation codes
df_cleaned = df[2:end, :]
date_format = "mm/dd/yyyy"
df_cleaned[!, :sasdate] = Dates.Date.(df_cleaned[!, :sasdate], date_format)


df_original = copy(df_cleaned)
df_cleaned = coalesce.(df_cleaned, NaN)
df_original = coalesce.(df_original, NaN)
### Create a DataFrame with the transformation codes
transformation_codes = DataFrame(Series = names(df)[2:end], 
                                 Transformation_Code = collect(df[1, 2:end]))

### Function to apply transformations based on the transformation code
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


### Helper function to lag a series (since Julia doesn't have a built-in function to lag)
function lag(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [nan; v[1:(end-l)]]
end

function lead(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [v[(l+1):end]; nan]
end

### mdiff function to calculate the first difference of a series
function mdiff(v::Vector)
    return v .- lag(v, 1)
end


### Applying the transformations to each column in df_cleaned based on transformation_codes
for row in eachrow(transformation_codes)
    series_name = Symbol(row[:Series])
    code = row[:Transformation_Code]
    @show series_name, code
    df_cleaned[!, series_name] = apply_transformation(df_cleaned[!, series_name], code)
end

### The transformation create missing values at the top, so let's remove them
df_cleaned = df_cleaned[3:end, :]

function compute_forecast(target = :INDPRO, x_var = [:CPIAUCSL, :FEDFUNDS],H = [1 4 8],p = 4)
    y_hat=[]

    y_raw = df_cleaned[!, target]
    x_raw = select(df_cleaned, x_var)    

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
end

# CREATE THE FORECASTING FUNCTION
function compute_error(target = :INDPRO, x_var = [:CPIAUCSL, :FEDFUNDS],H = [1 4 8],p = 4, end_date = Dates.Date("12/01/1999", date_format))
    y_hat = []
    y_actual = []
    rt_df = filter(row -> row[:sasdate] <= end_date, df_cleaned)
    

    for h in H
        os = end_date + Dates.Month(h)
        push!(y_actual, (filter(row -> row[:sasdate] == os, df_cleaned)))
    end

    y_raw = rt_df[!, target]
    x_raw = select(rt_df, x_var)    

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
    
    y_actual_matrix = vcat(y_actual[1],y_actual[2],y_actual[3])
    error_value = y_hat - y_actual_matrix[!,target] 
    error_value = hcat(error_value)
    
    return error_value
    

end

# CREATE THE ERROR-COMPUTING FUNCTION
function evaluate_model(target = :INDPRO, x_var = [:CPIAUCSL, :FEDFUNDS],H = [1 4 8],p = 4, t0 = "12/01/1999")

    t0 = Dates.Date(t0,date_format)
    e = []
    T = []
   

    for j in 1:10
        t0 = t0 + Dates.Month(1)
        ehat = compute_error(target,x_var,H,p, t0)
        ehat = ehat'
        push!(e,ehat)
        push!(T,t0)
    end
    a = vcat(e...)
    sqrd_a = a .^ 2
    mean_sqrd_a = (mean(sqrd_a, dims=1)) .^(0.5)
    return  mean_sqrd_a

end

# COMPUTING THE 3 DIFFERENT REGRESSIONS
forecast_INDPRO = compute_forecast(:INDPRO, [:CPIAUCSL, :TB3MS, :AWHMAN])
println(forecast_INDPRO)
forecast_CPI= compute_forecast(:CPIAUCSL, [:M1SL, :UNRATE, :FEDFUNDS, :OILPRICEx])
println(forecast_CPI)
forecast_FF = compute_forecast(:FEDFUNDS, [:CPIAUCSL, :UNRATE, :INDPRO, :TB3MS, :INVEST, :DTCTHFNM, :NONREVSL, :PCEPI])
println(forecast_FF)

regressione1 = evaluate_model(:INDPRO, [:CPIAUCSL, :TB3MS, :AWHMAN])
println(regressione1)
regressione2 = evaluate_model(:CPIAUCSL, [:M1SL, :UNRATE, :FEDFUNDS, :OILPRICEx])
println(regressione2)
regressione3 = evaluate_model(:FEDFUNDS, [:CPIAUCSL, :UNRATE, :INDPRO, :TB3MS, :INVEST, :DTCTHFNM, :NONREVSL, :PCEPI])
println(regressione3)
 

#   Import packages
using Pkg
Pkg.add("CSV")
using CSV
Pkg.add("DataFrames")
using DataFrames
Pkg.add("Dates")
using Dates
Pkg.add("LinearAlgebra")
using LinearAlgebra
Pkg.add("Plots")
using Plots

#   Load the data from Fred
df= CSV.read("/Users/edoardodicosimo/Documents/Magistrale/ctfme/current.csv", DataFrame)

df_cleaned=df[2:end, :]
#=  This line creates df_cleaned, this new dataset contains all the rows of df but the first one
":" indicates that all the df's column are included in df_cleaned
=#

date_format="mm/dd/yyyy"

df_cleaned[!, :sasdate] = Dates.Date.(df_cleaned[!, :sasdate], date_format) 
#=  df_cleaned[!, :sasdate]: This line selects the column named :sasdate from the DataFrame df_cleaned. 
    The ! indexing syntax is used to indicate that we're selecting a column by its name.
    Dates.Date.(df_cleaned[!, :sasdate], date_format): This applies the Dates.Date function to each element in the selected column df_cleaned[!, :sasdate]
    data_format specifes the format of the dates inside the dataset
    The result is then assigned back to the column :sasdate in the DataFrame df_cleaned.
    In summary, this line of code is likely used to convert the elements in the :sasdate column of df_cleaned from their current format to Date objects using the specified date_format.
=#

df_original=copy(df_cleaned)
#   df_original is the copy of df_cleaned

df_cleaned = coalesce.(df_cleaned, NaN)
df_original = coalesce.(df_original, NaN)
#=  This line replace each and every missing values with NaN.
    NaN stands for Not a Number and it is used to represent missing or undefined values
=#

transformation_codes = DataFrame(Series = names(df)[2:end], Transformation_Code = collect(df[1, 2:end]))
#=  New Dataset trasformation_codes which contains only two columns, Series and trasformation_code.
    Series contains every name of the series extract from the fisrt row of df (thanks to teh function Names).
    trasformation_code contains every value of the first row starting from the second column (df[1, 2:end]), the function collect makes it an array
=#

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
 #= We create a new Function "apply_transformation" tha takes two arguments series and code.
    Then we define the if else (with elseif nested in it).
    if the argument code meets a certain condition we perform the transformation as said in the FRED document
=#

function lag(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [nan; v[1:(end-l)]]
end
#=  We create the lag function, this takes two arguments a vector v and an Ineger l
    we create a vector nan of dimension l full of Nan.
    then we return a vector which is made by as many Nan as l  and then all the values of vector v strating from l to the end.
    this return the lagged vector. lag of period l
=#

function lead(v::Vector, l::Integer)
    nan = [NaN for _ in 1:l]
    return [v[(l+1):end]; nan]
end
# this is the lead function

function mdiff(v::Vector)
    return v .- lag(v, 1)
end
#= The mdiff function computes the first-order difference of the vector v by subtracting each element from its preceding element
    it calls the function lag with a lag of 1
=#

for row in eachrow(transformation_codes)
    series_name = Symbol(row[:Series])
    code = row[:Transformation_Code]
    @show series_name, code
    df_cleaned[!, series_name] = apply_transformation(df_cleaned[!, series_name], code)
end
#=  Overall, this loop iterates over each row of transformation_codes.
    it applies the specified transformation to the corresponding series in df_cleaned, and updates df_cleaned with the transformed series.
    Symbol function is similar to the Python function of Key in dictionaries.
    @show it prints the series_name and its attached code
=#

df_cleaned = df_cleaned[3:end, :]
# Clean the data set and drop missing value at the top

p1 = plot(df_cleaned.sasdate, df_cleaned.INDPRO, label="Industrial Production", legend=:none, xlabel="Date", ylabel="INDPRO", title="Industrial Production")
# Syntax (x axis, y axis)
p2 = plot(df_cleaned.sasdate, df_cleaned.CPIAUCSL, label="CPI", legend=:none, xlabel="Date", ylabel="CPIAUCSL", title="Consumer Price Index")

plot(p1, p2, layout=(2, 1), size=(800, 600))


                                                #*** FORECAST ***#

Y = df_cleaned[!, :INDPRO]
# Extract a vector of the value INDPRO. "!" is used the indicate that we are selecting a column by its name 

X = Matrix(df_cleaned[!, [:CPIAUCSL, :FEDFUNDS]])
#   We create a matrix with the values from the two columns CPIAUCSL and FEDFUNDS

                            #***    I THINK THE ASSIGNMENT STARTS FROM HERE    ***#

# questi sono i lag
h = 1 
p = 4
r = 4

# Create lagged versions of Y and X, and handle the dropping of missing values accordingly 

Y_target = lead(Y, 1)
Y_lagged = hcat([lag(Y, i) for i in 0:p]...)
X_lagged = hcat([lag(X[:, j], i) for i in 0:r, j in 1:size(X, 2)]...)

#= I puntini servono a unire i vettori in una gigola matrice;
senza di questi il risultato è una matrice 5x1 in cui ogni riga è un vettore 1x700ish =#

## For the forecast last row of the X which will get removed later
X_T = [1; [Y_lagged X_lagged][end,:]]

Y_reg = Y_target[max(p,r)+1:(end-h)]
X_reg = hcat(ones(size(Y_reg, 1)), Y_lagged[max(p,r)+1:(end-h),:], X_lagged[max(p,r)+1:(end-h), :])

# OLS estimator using the Normal Equation
beta_ols = X_reg \ Y_reg

# Preparing the last row for forecast (ensure correct indexing for Julia)

# Produce the One-step ahead forecast and convert it to percentage
forecast = (X_T' * beta_ols) * 100

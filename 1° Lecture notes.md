FRED data is the most influential source of macroeconomic data. Prices are computed monthly. Seasonally adjusted means that,  
for example, we want to remove the deviation of Christmas shopping (inflation) or August less shopping (deflation).

On FRED data we can modify data, for example: modify the frequency (we could see the monthly inflation rate, 
so compared to the previous month).

FRED-MD is a monthly database (https://research.stlouisfed.org/wp/more/2015-012). In this paper, that we are supposed to be  
able to replicate (https://s3.amazonaws.com/real.stlouisfed.org/wp/2015/2015-012.pdf), at page 28 we can see in the  
table the FRED mnemonic column and also the universal GSI mnemonic.

The flash estimate of inflation is made every month (usually the 10th day in EURO area) and then it's revised with more precision.

Forecasting is: given the information available today, I want to create a model to predict the future values.

ALFRED is an archive of the "vintage" versions of data that were available in certaind dates. This is useful because  
data are always revised and updated with more precision, so without ALFRED it might be impossible to retrieve the actual data  
produced in the past.

ASSIGNMENT: we have to download the dataset from the link in the pdf. The data with a number -00 are the vintage versions 
(so with small variations). The file is a database with dates on rows and variables on columns. Industrial production is a  
measure the GDP; the GDP is quarterly and takes time to be computed (due to all the aggregate data from the whole country), 
so we can approximate GDP with the more immediate industrial production. In the second row there's "transform": usually time 
series are not stationary, but we want them stationary, so we transform them; the meaning of code 5 can be seen at page 28 of  
the previous paper (there are 7 different transformations), and it's the log-difference. 

ASSIGNMENT (continued): we should download the dataset and upload it into our depository. Then we should import it into our 
code. In Python, firstly, we have to install the library "Pandas", which can be shortened as "pd".  
Now it's time to clean up: we can remove the second row with the method "drop" (remember that Python starts at index 0),  
and then we have to reset the index to 0. 
Then we create a function with all the 7 possible transformations, but first we have to import the library "numpy" as "np".
Then we can apply this function to all al the rows (clearly the first observation will be NaN because it can have a difference  
with the previous observations). 

ASSIGNMENT (continued): The lead (Y,1) means that Y takes the value of the next observation, differently from the lag t-1  
which takes the value of the previous observation. The capital T is the perid with the last observation, last data available. 
Firstly, we should change the model (i.e. choose other better variables), then use it to forecast the 3 indicated variables. 
Then we should run a "back-test"










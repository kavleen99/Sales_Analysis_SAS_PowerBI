/* Import the data from Excel */
PROC IMPORT DATAFILE="/home/u64163028/sales_data.xlsx"
    OUT=WORK.sales_data
    DBMS=XLSX
    REPLACE;
    GETNAMES=YES;
RUN;

/* Check dataset structure */
PROC PRINT DATA=WORK.sales_data (OBS=10);
RUN;

/* Data Cleaning: Handle missing values and fix Sale_Date */
DATA WORK.clean_sales;
    SET WORK.sales_data;

    /* Convert Sale_Date to proper SAS date format */
    Sale_Date_Num = INPUT(PUT(Sale_Date, $10.), DDMMYY10.);
    FORMAT Sale_Date_Num DDMMYY10.; 

    /* Extract Month & Year */
    Sale_Month = MONTH(Sale_Date_Num);
    Sale_Year = YEAR(Sale_Date_Num);

    /* Ensure Revenue is not missing */
    IF Revenue = . THEN Revenue = 0;

    /* Rename Sale_Date for consistency */
    DROP Sale_Date;
    RENAME Sale_Date_Num = Sale_Date;
RUN;

/* Verify Cleaned Data */
PROC PRINT DATA=WORK.clean_sales (OBS=10);
RUN;

/* Aggregate Revenue by Customer */
PROC SQL;
    CREATE TABLE WORK.customer_sales AS
    SELECT Customer_ID, SUM(Revenue) AS Total_Revenue
    FROM WORK.clean_sales
    GROUP BY Customer_ID;
QUIT;

/* Verify Aggregated Data */
PROC PRINT DATA=WORK.customer_sales (OBS=10);
RUN;

/* Export the cleaned data */
PROC EXPORT DATA=WORK.customer_sales
    OUTFILE="/home/u64163028/final_sales_answer.xlsx"
    DBMS=XLSX
    REPLACE;
RUN;

/* Revenue Statistics */
PROC MEANS DATA=WORK.customer_sales SUM MIN MAX;
    VAR Total_Revenue;
RUN;


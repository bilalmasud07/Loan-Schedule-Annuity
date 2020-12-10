-- FUNCTION: public.f(double precision, integer, double precision)

-- DROP FUNCTION public.f(double precision, integer, double precision);

CREATE OR REPLACE FUNCTION public.f(
	loan_amount double precision,
	periods_in_months integer,
	year_interest_rate double precision)
    RETURNS TABLE(datesss text, a double precision, b double precision, c double precision, d double precision, e double precision) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
	passedValue int:=periods_in_months; -- declaring variables for calculations
	Num bigint:= 0;
	monthly_interest_rate DOUBLE PRECISION := 0;
	interest DOUBLE PRECISION := 0; monthly_interest_value DOUBLE PRECISION := 0;
	total_payment DOUBLE PRECISION := 0; monthly_payment DOUBLE PRECISION := 0; total_amount_with_interest DOUBLE PRECISION := 0;
	load_balance DOUBLE PRECISION := 0; prin_payment DOUBLE PRECISION := 0; pow DOUBLE PRECISION := 0;
BEGIN
	Drop table If exists temp_table; -- it the drop the table if that exits
	-- Create a temp table to store results of calculations
	CREATE TEMPORARY TABLE temp_table(
   		nrr integer,
		l_amount Double Precision,
		inter Double Precision,
		prin_pay Double Precision,
		monthly_pay Double Precision,
		princ_remain Double Precision);
	-- This will check if the total months are less than 1 than this return with specific output.
	IF periods_in_months < 1 THEN
		raise notice'Add months period greater than 0' ;
		RETURN QUERY SELECT 'Together',CAST(0 as double precision), CAST(0 as double precision),
					CAST(loan_amount as double precision), CAST(loan_amount as double precision), CAST(0 as double precision);
				return;
	END IF;
	-- This will check if interest value is equal to 0 than this return with specific output.
	IF year_interest_rate = 0 THEN
		raise notice'Add Interest value greater than 0';
		RETURN QUERY SELECT 'Together',CAST(0 as double precision), CAST(0 as double precision),
					CAST(loan_amount as double precision), CAST(0 as double precision), CAST(0 as double precision);
				return;
	END IF;
	monthly_interest_rate := ((year_interest_rate*0.01)/12); -- calculating monthly interest rate
	monthly_interest_value:= loan_amount * monthly_interest_rate; -- calculating monthly interest value
	pow:= power((1 +monthly_interest_rate),-periods_in_months); -- calculating monthly payment
	monthly_payment:= (monthly_interest_rate * loan_amount)/( 1- pow); -- calculating monthly payment
	total_amount_with_interest:= loan_amount + monthly_interest_value; -- calculating amount with interest
	load_balance:= total_amount_with_interest - monthly_payment; -- calculating load balance
	prin_payment:= loan_amount - load_balance; -- calculating principle payment
	
	Drop table If exists datee;
	-- it will create a tem table and
	-- create and store Date dimention according to the period of months.
	-- two coulums are index and Date
	CREATE TEMP TABLE datee AS SELECT row_number() over () as ind , concat_ws(' ', TO_CHAR(date_trunc('Mon', mm):: date, 'Month'),
				    extract(year from date_trunc('Mon', mm))) AS Month_year
					FROM generate_series( (current_timestamp + '1 month')::timestamp , (current_timestamp + interval '1 month' * passedValue)::timestamp, '1 month'::interval) mm
					order by ind ASC;
	FOR i IN 1..passedValue  -- run the loop to total number of months(period of months)
	LOOP
		IF i=1 THEN
			monthly_interest_rate := ((year_interest_rate*0.01)/12); -- monthly interest rate
			monthly_interest_value:= loan_amount * monthly_interest_rate; -- monthly interest value
			pow:= power((1 +monthly_interest_rate),-periods_in_months); -- calculating monthly payment
			monthly_payment:= (monthly_interest_rate * loan_amount)/( 1- pow); -- calculating monthly payment
			total_amount_with_interest:= loan_amount + monthly_interest_value; -- amount with interest
			load_balance:= total_amount_with_interest - monthly_payment; -- load balance
			prin_payment:= loan_amount - load_balance;
		ELSE
			monthly_interest_rate := ((year_interest_rate*0.01)/12); -- monthly interest rate
			monthly_interest_value:= loan_amount * monthly_interest_rate; -- monthly interest value
			total_amount_with_interest:= loan_amount + monthly_interest_value; -- amount with interest
			load_balance:= total_amount_with_interest - monthly_payment; -- load balance
			prin_payment:= loan_amount - load_balance;
		END IF;
		-- inserting values in temp_table including index(nrr)
		INSERT INTO temp_table (nrr, l_amount, inter, prin_pay, monthly_pay, princ_remain)
		VALUES(i, loan_amount, monthly_interest_value, prin_payment, monthly_payment, load_balance );
		loan_amount := load_balance; -- updating the loan amount value to load_balance value.
		
	END LOOP;
	-- returning a query: getting a left join on (temp_table.nrr and datee.ind) of above created temp table and return the result
	-- values were very large so Round function is used to round up those values to 2 digits.
	RETURN QUERY SELECT d.Month_year,
					Cast(ROUND(CAST(tt.l_amount as numeric),2) as double precision), Cast(ROUND(CAST(tt.inter as numeric),2) as double precision),
					Cast(ROUND(CAST(tt.prin_pay as numeric),2) as double precision), Cast(ROUND(CAST(tt.monthly_pay as numeric),2) as double precision),
					Cast(ROUND(CAST(tt.princ_remain as numeric),2) as double precision)
					FROM temp_table tt
					LEFT JOIN  datee d
   					ON tt.nrr = d.ind;
END;
$BODY$;

ALTER FUNCTION public.f(double precision, integer, double precision)
    OWNER TO postgres;

# Loan-Schedule-Annuity
Loan Schedule - Annuity Calculator
The aim is to build a function. Which will take three parameters
  𝑓(𝑙𝑜𝑎𝑛 𝑎𝑚𝑜𝑢𝑛𝑡 [𝑛𝑢𝑚𝑒𝑟𝑖𝑐], 𝑝𝑒𝑟𝑖𝑜𝑑 𝑖𝑛 𝑚𝑜𝑛𝑡ℎ𝑠 [𝑖𝑛𝑡𝑒𝑔𝑒𝑟], 𝑦𝑒𝑎𝑟 𝑖𝑛𝑡𝑒𝑟𝑒𝑠𝑡 𝑟𝑎𝑡𝑒[𝑛𝑢𝑚𝑒𝑟𝑖𝑐])
  e.g 𝑓(6000,48,6)
  and then produces and returns table.
As the annuity schedule has equal monthly payments the key point is to calculate the monthly payment. Formula for doing it is:
 P – monthly payment, PV- loan amount, r – interest rate, n – number of periods,
 P = r * (PV)/ [ 1 - ( 1 +r ) ^-n]

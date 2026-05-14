# Emmanuel-SQL-ETL-Healthcare-Data-Pipeline
To architect a comprehensive data view that joins patient demographics, clinical records, and financial data into a single, quarriable executive summary.
CTEs (Common Table Expressions): Modularized the data into Patient_base, Hospital_record, and Hospital_finances for better performance and readability.

Data Normalization: Synthesized a unique Patient_id using string manipulation (UPPER, TRIM) and window functions to ensure data integrity.

Advanced Analytics: Implemented OVER() clauses for global averages and DATEDIFF for operational efficiency metrics (Length of Stay).

View Creation: Encapsulated the logic into a permanent VIEW to support recurring executive reporting.

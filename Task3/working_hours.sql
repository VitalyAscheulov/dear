CREATE TABLE #users 
  ( 
     [empid] INT, 
     [name]  NVARCHAR(255) 
  ); 

DECLARE @StartDate DATETIME = '2020-01-01 09:00:00'; 
DECLARE @EndDate DATETIME = '2020-01-01 12:00:00'; 
DECLARE @EmpID NVARCHAR(6) = 1; 

CREATE TABLE #working_logs 
  ( 
     [empid]  INT, 
     [time]   DATETIME, 
     [in_out] VARCHAR(3) 
  ); 

INSERT #users 
VALUES (1, 
        'test user') 

INSERT #working_logs 
VALUES (1, 
        '2020-01-01 09:00:00', 
        'In'), 
       (1, 
        '2020-01-01 12:30:00', 
        'Out'), 
       (1, 
        '2020-01-01 13:00:00', 
        'In'), 
       (1, 
        '2020-01-01 17:00:00', 
        'Out'), 
       (1, 
        '2020-01-02 23:00:00', 
        'In'), 
       (1, 
        '2020-01-03 07:00:00', 
        'Out'); 

CREATE CLUSTERED INDEX idx 
  ON #working_logs (empid, [time]); 

WITH cte_start 
     AS (SELECT empid, 
                Sum(Datediff(minute, att.[time], @StartDate) * CASE 
                    WHEN in_out = 'In' THEN +1 
                    ELSE -1 
                                                               END) AS SumStart 
         FROM   #working_logs AS att 
         WHERE  ( empid = @EmpID 
                   OR @EmpID IS NULL ) 
                AND att.[time] <= @StartDate 
         GROUP  BY empid), 
     cte_end 
     AS (SELECT empid, 
                Sum(Datediff(minute, att.[time], @StartDate) * CASE 
                    WHEN in_out = 'In' THEN +1 
                    ELSE -1 
                                                               END) AS SumEnd 
         FROM   #working_logs AS att 
         WHERE  ( empid = @EmpID 
                   OR @EmpID IS NULL ) 
                AND att.[time] <= @EndDate 
         GROUP  BY empid), 
     corr_end 
     AS (SELECT TOP 1 empid, 
                      Sum(Datediff(minute, [time], @StartDate) * 
                          CASE 
                            WHEN in_out = 'In' THEN +1 
                            ELSE -1 
                          END) [last], 
                      Sum(Datediff(minute, [time], @EndDate) * CASE 
                          WHEN in_out = 'In' THEN +1 
                          ELSE -1 
                                                               END)   AS [corr] 
         FROM   #working_logs AS att 
         WHERE  ( empid = @EmpID 
                   OR @EmpID IS NULL ) 
                AND att.[time] <= @EndDate 
         GROUP  BY empid, 
                   [time] 
         ORDER  BY time DESC), 
     corr_end1 
     AS (SELECT empid, 
                CASE 
                  WHEN [last] <= 0 THEN [last] * ( -1 ) + corr 
                  ELSE 0 
                END corr1 
         FROM   corr_end) 
SELECT #users.[name], 
       cte_end.empid, 
       ( sumend - Isnull(sumstart, 0) + corr1 ) / 60.0 SumHours 
FROM   cte_end 
       LEFT JOIN cte_start 
              ON cte_start.empid = cte_end.empid 
       INNER JOIN #users 
               ON cte_end.empid = #users.empid 
       INNER JOIN corr_end1 
               ON cte_end.empid = corr_end1.empid 

DROP TABLE #working_logs 
DROP TABLE #users 
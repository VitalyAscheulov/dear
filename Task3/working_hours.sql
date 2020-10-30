CREATE TABLE #users
(
    [empid] int,
    [name] NVARCHAR(255)
);

DECLARE @StartDate datetime = '2020-01-01 00:00:00';
DECLARE @EndDate datetime = '2020-01-04 00:00:00';
DECLARE @EmpID nvarchar(6) = 1;


CREATE TABLE #working_logs
(
    [empid] int,
    [Time] DATETIME,
    [In_Out] VARCHAR(3)
);

INSERT #users
VALUES
(1, 'test user')


INSERT #working_logs
VALUES
(1, '2020-01-01 09:00:00', 'In'),
(1, '2020-01-01 12:30:00', 'Out'),
(1, '2020-01-01 13:00:00', 'In'),
(1, '2020-01-01 17:00:00', 'Out'),
(1, '2020-01-02 23:00:00', 'In'),
(1, '2020-01-03 07:00:00', 'Out');


CREATE CLUSTERED INDEX idx ON #working_logs (empid, [time]);

WITH
CTE_Start
AS
(
    SELECT
        EmpID
        ,SUM(DATEDIFF(minute, (CAST(att.[Time] AS datetime)), @StartDate)
            * CASE WHEN In_Out = 'In' THEN +1 ELSE -1 END) AS SumStart
    FROM
        #working_logs AS att
    WHERE
        (EmpID = @EmpID OR @EmpID IS NULL)
        AND att.[Time] < @StartDate
    GROUP BY EmpID
)
,CTE_End
AS
(
    SELECT
        EmpID
        ,SUM(DATEDIFF(minute, (CAST(att.[Time] AS datetime)), @StartDate)
            * CASE WHEN In_Out = 'In' THEN +1 ELSE -1 END) AS SumEnd
    FROM
        #working_logs AS att
    WHERE
        (EmpID = @EmpID OR @EmpID IS NULL)
        AND att.[Time] < @EndDate
    GROUP BY EmpID
)

SELECT
    #users.[name],
    CTE_End.EmpID
    ,(SumEnd - ISNULL(SumStart, 0)) / 60.0 AS SumHours
FROM
    CTE_End
    LEFT JOIN CTE_Start ON CTE_Start.EmpID = CTE_End.EmpID
	inner join #users on CTE_End.empid = #users.empid


DROP TABLE #working_logs
DROP TABLE #users
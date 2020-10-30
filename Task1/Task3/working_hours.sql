CREATE TABLE #working_logs
(
    [userid] int,
    [Time] DATETIME,
    [In_Out] VARCHAR(3)
);
INSERT #working_logs
VALUES
(1, '2020-01-01 09:00:00', 'In'),
(1, '2020-01-01 12:35:00', 'Out'),
(1, '2020-01-01 13:00:00', 'In'),
(1, '2020-01-01 17:00:00', 'Out'),
(1, '2020-01-02 23:00:00', 'In'),
(1, '2020-01-03 07:00:00', 'Out');

CREATE CLUSTERED INDEX in_out ON #working_logs (In_Out);

WITH t
AS
(
    SELECT COALESCE(i.[userid], o.[userid]) AS [userid]
         , COALESCE(i.[Date], o.[Date]) AS [Date]
         , COALESCE(i.[Time], CAST(o.[Time] AS DATE)) AS [in]
         , COALESCE(o.[Time], DATEADD(DAY, 1, CAST(i.[Time] AS DATE))) AS [out]
         , RANK() OVER (PARTITION BY i.[Time] ORDER BY o.[Time]) AS r
      FROM (SELECT [userid], CAST([Time] AS DATE) AS [Date], [Time] 
             FROM #working_logs 
            WHERE [In_Out] = 'In') AS i
 FULL JOIN (SELECT [userid], CAST([Time] AS DATE) AS [Date], [Time] 
             FROM #working_logs 
            WHERE [In_Out] = 'Out') AS o
        ON i.[userid] = o.[userid]
       AND i.[Date] = o.[Date]
       AND i.[Time] < o.[Time]
)
SELECT [userid], [Date], 
	SUM(DATEDIFF(MINUTE, [in], [out])) AS [Mins]
  FROM t
WHERE 
r = 1
GROUP BY [userid], [Date]
ORDER BY [userid], [Date]

DROP TABLE #working_logs;

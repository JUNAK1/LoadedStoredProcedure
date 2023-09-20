USE [Ejemplo]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Exec [dbo].[spConsolidadosRecord] 
*/
ALTER PROCEDURE [dbo].[spRecordCardif]
AS

SET NOCOUNT ON;

    BEGIN
        BEGIN TRY
        /*===============Bloque declaracion de variables==========*/
        
        DECLARE @ERROR INT =0;
        
        /*======================================== Creación y carga temporal #TMPHagent ======================================*/

        IF OBJECT_ID('tempdb..#TMPHagent') IS NOT NULL DROP TABLE #TMPHagent;
        CREATE TABLE #TMPHagent
        (   
             [div]                         INT
            ,[xxx]                          VARCHAR(50)
            ,[row_date]                     DATE
            ,[Vail]                        INT
            ,[Prod]                      INT
            ,[NoProd]                    INT
            ,[TalkTime]                     INT
            ,[HoldTime]                     INT
            ,[ABCTime]                      INT
            ,[DingdingTime]                     INT
        );

        INSERT INTO #TMPHagent
        SELECT
            B.[div]
            ,B.[xxx]
            ,B.row_date
            ,sum(B.[ti_availtime])  AS [Vail]
            , 0 AS [Prod]
            ,(sum(ISNULL(B.[ti_auxtime],0)) - sum(ISNULL(B.[ti_auxtime6],0)) ) AS [NoProd]
            ,sum(B.[i_acdtime]) AS [TalkTime]
            ,sum(B.[holdacdtime]) AS [HoldTime]
            ,sum(B.[i_acwtime]) AS [ABCTime]
            ,sum(B.[DingdingTime]) AS [DingdingTime]
        FROM 
        [10.151.230.21\SCOFFS].[WFM CMS].[dbo].[hagent] AS B WITH(NOLOCK)
        GROUP BY B.[div],B.[xxx],B.[row_date]


/*======================================== Creación y carga temporal #TMPHsplit ======================================*/    
        IF OBJECT_ID('tempdb..#TMPHsplit') IS NOT NULL DROP TABLE #TMPHsplit;
        
        CREATE TABLE #TMPHsplit
            (
                [div]                         INT
                ,[xxx]                          VARCHAR(50)
                ,[row_date]                     DATE
                ,[RealInteractAnsw]     INT
                ,[RealInteracOffd]      INT
                ,[KPI]                     FLOAT
                ,[Weight]                       INT
                ,[Productive]          INT
            );


            INSERT INTO #TMPHsplit --#TMP_HCMercadoLibre where [GeneralId] = 'ext_adrangel'
            SELECT
                C.[div]
                ,C.[xxx]
                ,C.[row_date]
                ,sum(C.[acdcalls]) AS [RealInteractAnsw]
                ,sum(C.[callsoffered]) AS [RealInteracOffd]
                ,   CASE
                    WHEN    sum(C.[callsoffered]) = 0 OR sum(C.[callsoffered]) IS NULL
                        THEN 0
                    ELSE  sum(ISNULL(C.[acceptable],0)) /  sum(C.[callsoffered])
                    END AS [KPI]
                ,sum(C.[callsoffered]) AS [Weight]
                , 0 AS [Productive]
            FROM [10.151.230.21\SCOFFS].[WFM CMS].[dbo].[hsplit] AS C WITH(NOLOCK)
            GROUP BY C.[div],C.[xxx],C.[row_date]

        /*======================================== Creación y carga temporal #TMPLobSkill ======================================*/                  

    IF OBJECT_ID('tempdb..#TMPLobSkill') IS NOT NULL DROP TABLE #TMPLobSkill;
                
        CREATE TABLE #TMPLobSkill
            (
                skill   INT
                ,Lucent NVARCHAR(50)
            );
        
        INSERT INTO #TMPLobSkill
        SELECT 
            [skill]
            ,[Lucent]
        FROM [TPCCP-DB10].[Cardif].[dbo].[tbLobSkillProductivos] WITH(NOLOCK)
        group by [skill],[Lucent]

        /*======================================== Creación y carga temporal #TMPOverAndUnder ======================================*/                  

    IF OBJECT_ID('tempdb..#TMPOverAndUnder') IS NOT NULL DROP TABLE #TMPOverAndUnder;
                
        CREATE TABLE #TMPOverAndUnder
            (
                 [Fecha]                        DATE
                ,[FCSTInteractAnsw]     DECIMAL
                ,[KPI]                FLOAT
                ,[SHK]                DECIMAL
                ,[ABS]                DECIMAL
                ,[AHT]                FLOAT
                ,[KPIW]                    DECIMAL
                ,[ReqHours]                     DECIMAL
                ,[FCSTStaffT]                DECIMAL
            );
        
        INSERT INTO #TMPOverAndUnder
        SELECT 
            [Fecha]                             AS [Fecha]
            ,SUM(ISNULL([NetCapacity],0))                   AS [FCSTInteractAnsw]
            ,SUM(ISNULL(CAST([SL] AS FLOAT),0))                         AS [KPI]
            ,CASE
                 WHEN SUM([NetStaff]) = 0 OR SUM([NetStaff]) IS NULL
                       THEN 0
                 ELSE  1-(SUM(ISNULL([ProductiveStaff],0)) /  SUM([NetStaff]))

                 END                            AS [SHK]
            ,CASE
                WHEN  SUM([ScheduledStaff]) = 0 OR  SUM([ScheduledStaff]) IS NULL
                    THEN 0
                ELSE 1-(SUM(ISNULL([NetStaff],0)) / SUM([ScheduledStaff]))

                END                             AS [ABS]
            ,SUM(ISNULL([AHT],0))*60                 AS [AHT]
            ,SUM(ISNULL([NetCapacity],0))                      AS [KPIW]
            ,(SUM(ISNULL([Req],0))*1800)/3600        AS [ReqHours]
            ,(SUM(ISNULL([netStaff],0))*1800)/3600   AS [FCSTStaffT]
        FROM [TPCCP-DB10].[Cardif].[dbo].[tboau]  WITH(NOLOCK)
        GROUP BY [Fecha]

    /*======================================== Creación y carga temporal #TMPConsolidadosRecordQA ======================================*/  
    IF OBJECT_ID('tempdb..#TMPConsolidadosRecordQA') IS NOT NULL DROP TABLE #TMPConsolidadosRecordQA;
                
        CREATE TABLE #TMPConsolidadosRecordQA
            (
                 [Id]                           INT NOT NULL
                ,[IdClient]                     INT NOT NULL
                ,[Date]                         DATE NOT NULL
                ,[Vail]                        INT
                ,[Prod]                      INT
                ,[NoProd]                    INT
                ,[TalkTime]                     INT
                ,[HoldTime]                     INT
                ,[ABCTime]                      INT
                ,[DingdingTime]                     INT
                ,[RealInteractAnsw]     INT
                ,[RealInteracOffd]      INT
                ,[KPI]                     FLOAT
                ,[Weight]                       INT
                ,[Productive]          INT
                ,[FCSTInteractAnsw]     DECIMAL
                ,[KPI]                FLOAT
                ,[SHK]                DECIMAL
                ,[ABS]                DECIMAL
                ,[AHT]                FLOAT
                ,[KPIW]                    DECIMAL
                ,[ReqHours]                     DECIMAL
                ,[FCSTStaffT]                DECIMAL
                ,[TimeStamp]                    DATETIME 
 
  
            );

     INSERT INTO #TMPConsolidadosRecordQA
        SELECT 
             1421 AS [Id]
            ,0 AS [IdClient]
            ,HA.[row_date] AS [Date]
            ,HA.[Vail]                       
            ,HA.[Prod]                     
            ,HA.[NoProd]                   
            ,HA.[TalkTime]                    
            ,HA.[HoldTime]                    
            ,HA.[ABCTime]                     
            ,HA.[DingdingTime]                    
            ,HS.[RealInteractAnsw]    
            ,HS.[RealInteracOffd]     
            ,HS.[KPI]                     
            ,HS.[Weight]                      
            ,HS.[Productive]         
            ,TB.[FCSTInteractAnsw]     
            ,TB.[KPI]                
            ,TB.[SHK]                
            ,TB.[ABS]                
            ,TB.[AHT]               
            ,TB.[KPIW]                    
            ,TB.[ReqHours]                     
            ,TB.[FCSTStaffT]   
            ,GETDATE()
            FROM #TMPLobSkill AS LS 
                INNER JOIN #TMPHagent HA 
                ON LS.[skill] = HA.[div] AND LS.[Lucent] = HA.[xxx]
                INNER JOIN #TMPHsplit AS HS 
                ON LS.skill = HS.split AND LS.Lucent = HS.cms AND HS.[row_date] = HA.[row_date]
                INNER JOIN #TMPOverAndUnder TB
                ON TB.[Fecha] = HA.[row_date]
        
        

        /*************************Merge tabla fisica********************/
MERGE [TPCCP-DB10].[Cardif].[tbRecordCardif] AS [tgt]
        USING
        (
              SELECT
                 [id]
                ,[IdClient]
                ,[Date]
                ,[Vail]
                ,[Prod]
                ,[NoProd]
                ,[TalkTime]
                ,[HoldTime]
                ,[ABCTime]
                ,[DingdingTime]
                ,[RealInteractAnsw]
                ,[RealInteracOffd]
                ,[KPI]
                ,[Weight]
                ,[Productive]
                ,[FCSTInteractAnsw]
                ,[KPI]
                ,[SHK]
                ,[ABS]
                ,[AHT]
                ,[KPIW]
                ,[ReqHours]
                ,[FCSTStaffT]
                ,[TimeStamp]
            FROM #TMPConsolidadosRecordQA 




        ) AS [src]
        ON
        (
           
            [src].[Vail] = [tgt].[Vail] AND [src].[Prod] = [tgt].[Prod] AND [src].[NoProd] = [tgt].[NoProd]
        )
        -- For updates
        WHEN MATCHED THEN--CONSULTAR PERO LO MAS PROBALBLE ES QUE NO NECESTEMOS
          UPDATE 
              SET
                 

                 --                              =[src].
                 [tgt].[Id]                          =[src].[Id]
                ,[tgt].[IdClient]                    =[src].[IdClient]
                ,[tgt].[Date]                        =[src].[Date]
                ,[tgt].[Vail]                       =[src].[Vail]
                ,[tgt].[Prod]                     =[src].[Prod]
                ,[tgt].[NoProd]                   =[src].[NoProd]
                ,[tgt].[TalkTime]                    =[src].[TalkTime]
                ,[tgt].[HoldTime]                    =[src].[HoldTime]
                ,[tgt].[ABCTime]                     =[src].[ABCTime]
                ,[tgt].[DingdingTime]                    =[src].[DingdingTime]
                ,[tgt].[RealInteractAnsw]    =[src].[RealInteractAnsw]
                ,[tgt].[RealInteracOffd]     =[src].[RealInteracOffd]
                ,[tgt].[KPI]                    =[src].[KPI]
                ,[tgt].[Weight]                      =[src].[Weight]
                ,[tgt].[Productive]         =[src].[Productive]
                ,[tgt].[FCSTInteractAnsw]    =[src].[FCSTInteractAnsw]
                ,[tgt].[KPI]               =[src].[KPI]
                ,[tgt].[SHK]               =[src].[SHK]
                ,[tgt].[ABS]               =[src].[ABS]
                ,[tgt].[AHT]               =[src].[AHT]
                ,[tgt].[KPIW]                   =[src].[KPIW]
                ,[tgt].[ReqHours]                    =[src].[ReqHours]
                ,[tgt].[FCSTStaffT]               =[src].[FCSTStaffT]
                ,[tgt].[TimeStamp]                   =[src].[TimeStamp]






         --For Inserts
        WHEN NOT MATCHED THEN
            INSERT
            (
                
                 [Id]
                ,[IdClient]
                ,[Date]
                ,[Vail]
                ,[Prod]
                ,[NoProd]
                ,[TalkTime]
                ,[HoldTime]
                ,[ABCTime]
                ,[DingdingTime]
                ,[RealInteractAnsw]
                ,[RealInteracOffd]
                ,[KPI]
                ,[Weight]
                ,[Productive]
                ,[FCSTInteractAnsw]
                ,[KPI]
                ,[SHK]
                ,[ABS]
                ,[AHT]
                ,[KPIW]
                ,[ReqHours]
                ,[FCSTStaffT]
                ,[TimeStamp]
            )
            VALUES
            (
                
                 [src].[Id]
                ,[src].[IdClient]
                ,[src].[Date]
                ,[src].[Vail]
                ,[src].[Prod]
                ,[src].[NoProd]
                ,[src].[TalkTime]
                ,[src].[HoldTime]
                ,[src].[ABCTime]
                ,[src].[DingdingTime]
                ,[src].[RealInteractAnsw]
                ,[src].[RealInteracOffd]
                ,[src].[KPI]
                ,[src].[Weight]
                ,[src].[Productive]
                ,[src].[FCSTInteractAnsw]
                ,[src].[KPI]
                ,[src].[SHK]
                ,[src].[ABS]
                ,[src].[AHT]
                ,[src].[KPIW]
                ,[src].[ReqHours]
                ,[src].[FCSTStaffT]
                ,[src].[TimeStamp]
            );


        END TRY
        
        BEGIN CATCH
            SET @Error = 1;
            PRINT ERROR_MESSAGE();
        END CATCH
        /*=======================Eliminaci�n de temporales=========================*/

        IF OBJECT_ID('tempdb..#TMPHagent') IS NOT NULL DROP TABLE #TMPHagent;
        IF OBJECT_ID('tempdb..#TMPHsplit') IS NOT NULL DROP TABLE #TMPHsplit;
        IF OBJECT_ID('tempdb..#TMPLobSkill') IS NOT NULL DROP TABLE #TMPLobSkill;
        IF OBJECT_ID('tempdb..#TMPOverAndUnder') IS NOT NULL DROP TABLE #TMPOverAndUnder;
        IF OBJECT_ID('tempdb..#TMPConsolidadosRecordQA') IS NOT NULL DROP TABLE #TMPConsolidadosRecordQA;
     
    END
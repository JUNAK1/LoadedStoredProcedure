USE [Ejemplo]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbRecordCardif]( 

         [Id]                           INT
        ,[IdClient]                     INT
		,[Date]							DATE
        ,[vail]                        INT
        ,[Prod]                      INT
        ,[NoProd]                    INT
        ,[SpeakTime]                     INT
        ,[HdTime]                     INT
        ,[ACW]                      INT
        ,[DingdingTime]                     INT
        ,[RealInteracAnsw]     INT
        ,[RealInteractionsOffered]      INT
        ,[KPI]                     FLOAT
        ,[Weight]                       INT
        ,[AvailProduct]          INT
        ,[FCST]     DECIMAL
        ,[KPI]                FLOAT
        ,[SHK]                DECIMAL
        ,[ABS]                DECIMAL
        ,[AHT]                FLOAT
        ,[KPIw]                    DECIMAL
        ,[ReqHours]                     DECIMAL
        ,[FCST]                DECIMAL
        ,[TimeStamp]                    DATETIME
 
 
 CONSTRAINT [pkConsolidadosRecord] PRIMARY KEY CLUSTERED 
(   
      [Id]                      
     ,[IdClient]                        
   
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] 
GO
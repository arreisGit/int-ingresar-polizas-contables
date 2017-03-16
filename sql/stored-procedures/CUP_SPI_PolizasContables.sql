SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPI_PolizasContables') 
  DROP PROCEDURE  CUP_SPI_PolizasContables
GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-09

  Description: Procedimiento almacenado 
  encargado de insertar Polizas contables a 
  Intelisis

============================================= */

CREATE PROCEDURE [dbo].CUP_SPI_PolizasContables
(
 @Poliza XML(JournalEntrySchema)
)                
AS BEGIN   
  DECLARE @Messages TABLE
  (
    Num INT NOT NULL,
    [Description] VARCHAR(255) NOT NULL,
    ID INT NULL,
    Mov VARCHAR(20) NULL,
    MovID VARCHAR(20) NULL
  )

  INSERT INTO @Messages 
  (
    Num,
  [Description]
  )
  VALUES
  ( 
    0,
    'Oh Yeah'
  )

  SELECT
    Num
    ,[Description] = ISNULL([Description],'')
    ,ID = ISNULL(CAST(ID AS VARCHAR(30)),'')
    ,Mov = ISNULL(Mov,'')
    ,MovID = ISNULL(MovID,'')
  FROM
    @Messages
END
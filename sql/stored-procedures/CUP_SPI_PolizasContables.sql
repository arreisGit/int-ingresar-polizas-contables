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

  CREATE TABLE #tmp_CUP_ContHeader
  (
    Orden               INT NOT NULL,
    Concepto            VARCHAR(50) NOT NULL,
    ImporteDlls         DECIMAL(18,4) NOT NULL,
    ImporteConversionMN DECIMAL(18,4) NOT NULL,
    ImporteMN           DECIMAL(18,4) NOT NULL,
    TotalMN             DECIMAL(18,4) NOT NULL,
    Contabilidad        DECIMAL(18,4) NOT NULL,
    Variacion           DECIMAL(18,4) NULL,
    PRIMARY KEY ( 
                  Orden,
                  Concepto
                )


DECLARE @input XML = '<dataset> 
  <metadata>
  <item name="NAME_LAST" type="xs:string" length="62" /> 
  <item name="NAME_FIRST" type="xs:string" length="62" /> 
  <item name="NAME_MIDDLE" type="xs:string" length="32" />
  </metadata>
<data>
<row>
  <value>SMITH</value> 
  <value>MARY</value> 
  <value>N</value> 
</row>
<row>
  <value>SMITH2</value> 
  <value>MARY2</value> 
  <value>N2</value> 
</row>
</data>
</dataset>'

INSERT INTO dbo.YourTable(ColName, ColFirstName, ColOther)
   SELECT
      Name = XCol.value('(value)[1]','varchar(25)'),
      FirstName = XCol.value('(value)[2]','varchar(25)'),
      OtherValue = XCol.value('(value)[3]','varchar(25)')
   FROM 
      @input.nodes('/dataset/data/row') AS XTbl(XCol)

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
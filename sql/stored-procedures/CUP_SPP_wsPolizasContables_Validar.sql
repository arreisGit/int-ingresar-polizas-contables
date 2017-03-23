SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Validar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Validar
GO

/* =============================================
  
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-16

  Description: Procedimiento encargado de validar
  la informacion que conforma las polizas contables
  que se ingresaran a Intelisis de parte de otros
  sistemas mediante el llamado de un web service.

============================================= */

CREATE PROCEDURE [dbo].CUP_SPP_wsPolizasContables_Validar              
AS BEGIN TRY
  PRINT('.Validando.')

  DECLARE 
    @Sistema INT,
    @Tipo CHAR(20),
    @FechaContable DATE,
    @SucursalContable INT,
    @CfgCentrosCostos BIT = 0

  SELECT 
    @Sistema = Sistema,
    @Tipo  = Tipo,
    @FechaContable = FechaContable,
    @SucursalContable = SucursalContable
  FROM 
    #tmp_wsPolizasIntelisis_Header

  SELECT
    @CfgCentrosCostos = ContCentrosCostos
  FROM
    EmpresaCfg
  WHERE
    Empresa = 'CML'

  -- Validacion del sistema
  INSERT INTO #tmp_wsPolizasIntelisis_Messages
  ( 
    NUM, 
    [Description] 
  )
  SELECT 
    Num =  3,
    [Description] = 'El sistema "' + CAST(header.Sistema AS VARCHAR) + '" no es valido'
  FROM 
    #tmp_wsPolizasIntelisis_Header header
  LEFT JOIN Cup_SistemasCuprum sistema ON sistema.ID = header.Sistema
  WHERE 
    sistema.ID IS NULL

  -- Valida el tipo de la póliza.
  ;WITH MovValidos AS
  (
    SELECT DISTINCT 
      Movimiento = Mov
    FROM 
      Cont 
    WHERE 
      Estatus = 'CONCLUIDO'
  )
  INSERT INTO #tmp_wsPolizasIntelisis_Messages
  ( 
    NUM, 
    [Description] 
  )
  SELECT 
    Num =  3,
    [Description] = 'El tipo de póliza "' + header.Tipo + '" no es valido'
  FROM 
    #tmp_wsPolizasIntelisis_Header header
  LEFT JOIN MovValidos mov ON mov.Movimiento = header.Tipo
  WHERE 
    mov.Movimiento IS NULL

  -- Valida la sucursal contable.
  INSERT INTO #tmp_wsPolizasIntelisis_Messages
  ( 
    NUM, 
    [Description] 
  )
  SELECT 
    Num =  3,
    [Description] = 'El tipo de póliza "' + header.Tipo + '" no es valido'
  FROM 
    #tmp_wsPolizasIntelisis_Header header
  LEFT JOIN MovValidos mov ON mov.Movimiento = header.Tipo
  WHERE 
    mov.Movimiento IS NULL

  -- Valida las cuentas contables
  INSERT INTO #tmp_wsPolizasIntelisis_Messages
  ( 
    NUM, 
    [Description] 
  )
  SELECT 
    Num =  3,
    [Description] = 'La cuenta contable "'
                   + LTRIM(RTRIM(record.Cuenta)) 
                   + '" no es valida.'
  FROM 
     #tmp_wsPolizasIntelisis_Records record
  LEFT JOIN Cta ON Cta.Cuenta = record.Cuenta
  WHERE 
    Cta.Cuenta IS NULL

  -- Valida que los centros de costos.
  IF ISNULL(@CfgCentrosCostos,0) = 0
  BEGIN

    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  3,
      [Description] = 'La configuración de la empresa no permite el uso de centros de costo para la cuenta "'   
                     + LTRIM(RTRIM(record.Cuenta))
                     + '".'
    FROM 
       #tmp_wsPolizasIntelisis_Records record
    WHERE 
      ISNULL(record.SubCuenta,'') <> ''

  END
  ELSE 
  BEGIN

    -- Valida que los centros de costo existan.
    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  3,
      [Description] = 'El centro de costos "' 
                    + LTRIM(RTRIM(record.SubCuenta)) 
                    + '" no existe.'
    FROM 
       #tmp_wsPolizasIntelisis_Records record
    LEFT JOIN CentroCostos ON CentroCostos.CentroCostos = record.SubCuenta
                          AND ISNULL(CentroCostos.EsAcumulativo,0) = 0
    WHERE 
      CentroCostos.CentroCostos IS NULL

    -- Valida que no se esten usando centros de costos para cuentas contables
    -- que no han sido configuradas para usarlos.
    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  3,
      [Description] = 'La cuenta contable "'
                    + LTRIM(RTRIM(record.Cuenta))
                    + '" no ha sido configurada para utilizar centros de costos.'  
    FROM 
       #tmp_wsPolizasIntelisis_Records record
    JOIN Cta ON Cta.Cuenta = record.Cuenta
    WHERE
      ISNULL(Cta.CentrosCostos,0) = 0 
    AND ISNULL(record.SubCuenta,'') <> ''

   -- Valida que no existan cuentas que requieren un centro de costos
   -- pero no se les haya especificado uno.
   INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  3,
      [Description] = 'Hace falta indicar el centro de costos para la cuenta contable "'
                    + LTRIM(RTRIM(record.Cuenta))
                    + '".'  
    FROM 
       #tmp_wsPolizasIntelisis_Records record
    JOIN Cta ON Cta.Cuenta = record.Cuenta
    WHERE
      ISNULL(Cta.CentrosCostos,0) = 1
    AND ISNULL(Cta.CentroCostosRequerido,0) = 1 
    AND ISNULL(record.SubCuenta,'') = ''

    -- Valida que los centros de costos utilizados en las cuentas contables 
    -- sean correctos.
    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  3,
      [Description] = 'El centro de costos "'
                    + LTRIM(RTRIM(record.SubCuenta))
                    + '" no es valido para la cuenta contable "'
                    + LTRIM(RTRIM(record.Cuenta))
                    + '".'  
    FROM 
       #tmp_wsPolizasIntelisis_Records record
    JOIN Cta ON Cta.Cuenta = record.Cuenta
    JOIN CentroCostos ON CentroCostos.CentroCostos = record.SubCuenta
    LEFT JOIN CtaSub ON CtaSub.Cuenta = record.Cuenta
                   AND CtaSub.SubCuenta = record.SubCuenta
    WHERE
      ISNULL(Cta.CentroCostos,0) = 1
    AND CtaSub.CentroCostos IS NULL
  
  END
 
END TRY
BEGIN CATCH
 IF OBJECT_ID('tempdb..#tmp_wsPolizasIntelisis_Messages') IS NOT NULL
 BEGIN
    INSERT INTO #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM, 
      [Description] 
    )
    SELECT 
      Num =  ERROR_NUMBER()
     ,[Description] = ERROR_MESSAGE()
 END
 ELSE
 BEGIN
    SELECT
    Num = ERROR_NUMBER()
    ,[Description] = ERROR_MESSAGE()
    ,ID = ''
    ,Mov = ''
    ,MovID = ''
  END
  
END CATCH
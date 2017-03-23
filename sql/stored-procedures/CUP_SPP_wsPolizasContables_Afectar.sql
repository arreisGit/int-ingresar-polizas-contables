SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**************** DROP IF EXISTS ****************/
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'CUP_SPP_wsPolizasContables_Afectar') 
  DROP PROCEDURE  CUP_SPP_wsPolizasContables_Afectar
GO

/* =============================================
  
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-16

  Description: Procedimiento encargado de afectar y verificar
  las polizas contables que se ingresaran a Intelisis
  de parte de otros sistemas mediante el llamado de un
  web service.

============================================= */

CREATE PROCEDURE [dbo].CUP_SPP_wsPolizasContables_Afectar 
  @VerificarSinAfectar BIT = 0,
  @PolizaID INT,
  @Ok INT OUTPUT,
  @OkRef VARCHAR(255) OUTPUT 
AS BEGIN TRY

  PRINT('.Afectando.')

  --Asignamos el consecutivo    
  EXEC spAfectar
    @Modulo = 'CONT',
    @ID = @PolizaID,
    @Accion = 'CONSECUTIVO',
    @EnSilencio = 1 
 
  IF ISNULL(@VerificarSinAfectar,0) = 1 
  BEGIN
    EXEC spAfectar
      @Modulo = 'CONT',
      @ID = @PolizaID,
      @Accion = 'VERIFICAR',
      @Base = NULL,
      @GenerarMov = NULL,
      @Usuario = 'PRODAUT',
      @SincroFinal = 0,
      @EnSilencio = 1,
      @Ok = @OK OUTPUT,
      @OkRef = @OkRef OUTPUT
  END
  ELSE
  BEGIN
    EXEC spAfectar
        @Modulo = 'CONT', 
        @ID = @PolizaID ,
        @Accion = 'AFECTAR',
        @Base = 'Todo',
        @GenerarMov = NULL, 
        @Usuario = 'PRODAUT',
        @SincroFinal = 0, 
        @EnSilencio = 1,
        @OK = @OK OUTPUT,
        @OkRef = @OkRef OUTPUT
  END

  IF (
        @OK IS NULL 
     OR @Ok BETWEEN 80000 AND 81000 
     ) 
  AND NOT EXISTS (
                    SELECT
                      [Description]
                    FROM
                      #tmp_wsPolizasIntelisis_Messages
                    WHERE
                      ISNULL(Num,0) > 0
                  )
  BEGIN

    IF ISNULL(@VerificarSinAfectar,0) = 1
    BEGIN
      DECLARE
        @FechaRegistro DATETIME = GETDATE()
      
      EXEC spCambiarSituacion 
        @Modulo = 'CONT',
        @Id = @PolizaID,
        @Situacion = 'Por Autorizar',
        @SituacionFecha = @FechaRegistro,
        @Usuario = 'PRODAUT', 
        @SituacionUsuario = NULL, 
        @SituacionNota = NULL     

    END

    INSERT INTO
      #tmp_wsPolizasIntelisis_Messages
    ( 
      NUM,
      [Description],
      ID,
      Mov,
      MovID
    )
    SELECT 
      Num = 0,
      [Description] = 'Poliza Creada Exitosamente',
      ID = Cont.ID,
      Mov = Cont.Mov,
      MovID = Cont.MovID
    FROM
      Cont 
    WHERE 
      ID = @PolizaID
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
IF OBJECT_ID('dbo.CUP_SistemasCuprum', 'U') IS NOT NULL 
  DROP TABLE dbo.CUP_SistemasCuprum; 

GO

/* =============================================
  Created by:    Enrique Sierra Gtez
  Creation Date: 2017-03-09

  Description: Contiene el listado de sistemas
  que son utilizados en el corporativo y tienen
  algun tipo de interaccion con los sistemas de
  CML Planos.

============================================= */

CREATE TABLE dbo.CUP_SistemasCuprum
(
  ID INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  Descripcion VARCHAR(255) NOT NULL
              CONSTRAINT [AK_CUP_SistemasCuprum_Descripcion]
              UNIQUE,
  FechaRegistro DATETIME NOT NULL
                CONSTRAINT [DF_CUP_SistemasCuprum_FechaRegistro]
                DEFAULT GETDATE(),
  Activo BIT NOT NULL 
         CONSTRAINT [DF_CUP_SistemasCuprum_Activo]
         DEFAULT 1
)

CREATE NONCLUSTERED INDEX IX_CUP_SistemasCuprum_Descripcion
  ON CUP_SistemasCuprum ( Descripcion )
INCLUDE 
(
  ID,
  FechaRegistro,
  Activo
)

CREATE NONCLUSTERED INDEX IX_CUP_SistemasCuprum_FechaRegistro
  ON CUP_SistemasCuprum ( FechaRegistro )
INCLUDE 
(
  ID,
  Descripcion,
  Activo
)

CREATE NONCLUSTERED INDEX IX_CUP_SistemasCuprum_Activo
  ON CUP_SistemasCuprum ( Activo )
INCLUDE 
(
  ID,
  Descripcion,
  FechaRegistro
)
TRUNCATE TABLE CUP_SistemasCuprum

INSERT INTO CUP_SistemasCuprum
(
  Descripcion
)
VALUES
(
  'Microsoft Dynamics AX Software'
)

SELECT
  ID,
  Descripcion, 
  FechaRegistro,
  Activo
FROM
  CUP_SistemasCuprum
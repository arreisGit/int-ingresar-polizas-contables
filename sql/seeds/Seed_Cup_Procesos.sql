IF NOT EXISTS
(
  SELECT
    Descripcion
  FROM
    CUP_Procesos 
  WHERE 
    descripcion = 'Web Service p�lizas Intelisis'
)
BEGIN
  INSERT INTO  CUP_Procesos
  (
    Descripcion,
    FechaAlta,
    Usuario
  )
  VALUES
  (
    'Web Service p�lizas Intelisis',
    GETDATE(),
    63527
  )
END
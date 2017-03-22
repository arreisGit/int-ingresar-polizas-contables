IF NOT EXISTS
(
  SELECT
    Descripcion
  FROM
    CUP_Procesos 
  WHERE 
    descripcion = 'Web Service pólizas Intelisis'
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
    'Web Service pólizas Intelisis',
    GETDATE(),
    63527
  )
END
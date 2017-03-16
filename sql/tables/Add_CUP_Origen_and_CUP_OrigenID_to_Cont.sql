IF COLUMNPROPERTY(OBJECT_ID('dbo.Cont'), 'CUP_Origen', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE Cont 
    ADD CUP_Origen INT NULL
                   CONSTRAINT FK_Cont_to_CUP_Procesos
                   FOREIGN KEY
                   REFERENCES CUP_Procesos( Proceso )
END

IF COLUMNPROPERTY(OBJECT_ID('dbo.Cont'), 'CUP_OrigenID', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE Cont 
    ADD CUP_OrigenID INT NULL
END
USE master
GO
drop database Montevideo
GO

Create database Montevideo
on primary (
name=db_dat,
filename= 'C:\data\proyecto\db.mdf', 
size = 10mb),
  Filegroup fgDrama
  (
  name=fg1_dat,
filename= 'C:\data\proyecto\fg1.ndf', 
size = 10mb),
Filegroup fgComedia
  (
  name=fg2_dat,
filename= 'C:\data\proyecto\fg2.ndf', 
size = 10mb),
Filegroup fgAccion
  (
  name=fg3_dat,
filename= 'C:\data\proyecto\fg3.ndf', 
size = 10mb),
Filegroup fgCiencia_ficcion
  (
  name=fg4_dat,
filename= 'C:\data\proyecto\fg4.ndf', 
size = 10mb),
Filegroup fgSuspenso
  (
  name=fg5_dat,
filename= 'C:\data\proyecto\fg5.ndf', 
size = 10mb),
Filegroup fgRomance
  (
  name=fg6_dat,
filename= 'C:\data\proyecto\fg6.ndf', 
size = 10mb)
Log on 
(name=db_log,
filename= 'C:\data\proyecto\log.ndf', 
size = 20mb, filegrowth=10%
)
GO

USE Montevideo
GO

CREATE PARTITION FUNCTION ParticionPorGenero(VARCHAR(15))
AS RANGE RIGHT FOR VALUES ('Comedia', 'Accion', 'Ciencia_Ficcion', 'Suspenso', 'Romance')
GO

CREATE PARTITION SCHEME EsquemaDeParticionPorGenero
AS PARTITION ParticionPorGenero
TO (fgDrama, fgComedia, fgAccion, fgCiencia_ficcion, fgSuspenso, fgRomance);
GO

CREATE TABLE Pelicula (			--genero-pais-año-identificador
    IdPelicula VARCHAR(12),		--0-000-0000-0000
    Genero VARCHAR(15),
    TituloDistribucion VARCHAR(50),
    TituloOriginal VARCHAR(50),
    IdiomaOriginal VARCHAR(13),
    SubtitulosEspanol BIT,
    PaisesOrigen VARCHAR(26),
    FechaProduccion DATE,
    URL NVARCHAR(255),
    Duracion TIME,
    Clasificacion VARCHAR(5),
    FechaEstreno DATE,
    Sinopsis VARCHAR(255),
    PRIMARY KEY (IdPelicula, Genero)
) ON EsquemaDeParticionPorGenero(Genero)
GO

CREATE TABLE Cine (					---pais-cp-numero de sucursal
	IdCine VARCHAR(10) PRIMARY KEY,	---000-0000-000
	NombreCine VARCHAR(25),
	Direccion VARCHAR(50),
	Telefono VARCHAR(10),
	CantidadSalas TINYINT
)
GO
CREATE TABLE Sala (
    IdCine VARCHAR(10),
    NumeroSala TINYINT,
    CantidadButacas SMALLINT,
    PRIMARY KEY (IdCine, NumeroSala)
)
GO

CREATE TABLE Funcion (                      -- cine-sala-dd/mm/yy-hora
    IdFuncion VARCHAR(20) PRIMARY KEY,     -- 0000000000-00-000000-00
    FechaFuncion DATE,
    HoraDeInicio TIME,
    IdPelicula VARCHAR(12),
    NumeroSala TINYINT,
    IdCine VARCHAR(10),
    Genero VARCHAR(15)
)
GO

CREATE TABLE Promocion (					--tipo-funcion
	IdPromocion VARCHAR(23) PRIMARY KEY,	--000-00000000000000000000
	Descripcion VARCHAR(100),
	Descuento VARCHAR(4)
)
GO
CREATE TABLE Opinion (					--pelicula-identificador
	IdOpinion VARCHAR(15) PRIMARY KEY,	--000000000000-000
	FechaOpinion DATE,
	Calificacion DECIMAL(4,2),
	Comentario VARCHAR(255),
	IdPelicula VARCHAR(12),
	Genero VARCHAR(15)
)
GO
CREATE TABLE ActorDirector (
	RFC VARCHAR(12) PRIMARY KEY NONCLUSTERED,
	Nombre VARCHAR(25),
	ApellidoPaterno VARCHAR(25),
	ApellidoMaterno VARCHAR(25),
	Edad TINYINT,
	Nacionalidad VARCHAR(25),
	IdPelicula VARCHAR(12)
)
GO


/* NORMALIZACION */
/* PeliculaActor */
CREATE TABLE Trabaja (
	IdPelicula VARCHAR(12),
	RFC VARCHAR(12),
	Genero VARCHAR(15)
)
GO

/* FuncionPromocion */
CREATE TABLE Aplica (
	IdFuncion VARCHAR(20),
	IdPromocion VARCHAR(23)
)

CREATE TABLE Dirige (
	RFCActor VARCHAR(12),
	RFCDirector VARCHAR(12)
)
GO


/* LLAVES FORANEAS */
--FK DIRIGE
ALTER TABLE Dirige ADD CONSTRAINT
FK_Dirige_Director FOREIGN KEY(RFCActor)
REFERENCES ActorDirector(RFC)
GO

ALTER TABLE DIrige ADD CONSTRAINT 
FK_Dirige_Actor FOREIGN KEY(RFCDirector)
REFERENCES ActorDirector(RFC)

--FK TRABAJA
ALTER TABLE Trabaja ADD CONSTRAINT
FK_Trabaja_Pelicula FOREIGN KEY(IdPelicula,Genero)
REFERENCES Pelicula(IdPelicula, Genero)
GO

ALTER TABLE Trabaja ADD CONSTRAINT
FK_Pelicula_ActorDIrector FOREIGN KEY(RFC)
REFERENCES ActorDirector(RFC)
GO

--FK OPINION 
ALTER TABLE Opinion ADD CONSTRAINT
FK_Opinion_IdOpinion FOREIGN KEY(IdPelicula,Genero)
REFERENCES Pelicula(IdPelicula,Genero)
GO

--FK FUNCION
ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdPelicula FOREIGN KEY(IdPelicula, Genero)
REFERENCES Pelicula(IdPelicula, Genero)
GO

ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdSala FOREIGN KEY(IdCine, NumeroSala)
REFERENCES Sala(IdCine, NumeroSala)
GO

--FK APLICA
ALTER TABLE Aplica ADD CONSTRAINT
FK_Aplica_Funcion2 FOREIGN KEY(IdFuncion)
REFERENCES Funcion(IdFuncion)

ALTER TABLE Aplica ADD CONSTRAINT
FK_Aplica_Promocion2 FOREIGN KEY(IdPromocion)
REFERENCES Promocion(IdPromocion)
GO

--FK SALA
ALTER TABLE Sala ADD CONSTRAINT
FK_Sala_IdCine2 FOREIGN KEY(IdCine)
REFERENCES Cine(IdCine)
GO

---INSERCIONES
INSERT INTO Pelicula VALUES
(100020236882, 'Drama', 'El Gran Camino', 'The Great Path', 'ingles', 1, 'Estados unidos', '2023-01-15', 'http://amazonprime.com/thegreatpath', '01:45:00', 'A', '2023-03-01', 'Un viaje emocional de auto descubrimiento.'),
(200020226779, 'Comedia', 'Sonrisas por Siempre', 'Smiles Forever', 'English', 0, 'Estados unidos', '2022-06-20', 'http://max.com/smilesforever', '01:30:00', 'A', '2022-08-15', 'Una comedia que te hará reír hasta llorar.'),
(396820236567, 'Accion', 'Rápidos Extremos', 'Fast Extreme', 'Español', 1, 'Mexico', '2023-02-10', 'http://paramount.com/fastextreme', '02:00:00', 'B15', '2023-04-12', 'Carreras clandestinas en un entorno despiadado.'),
(400120216770, 'Ciencia_ficcion', 'Galaxias Lejanas', 'Far Galaxies', 'Ingles', 1, 'Reino Unido', '2021-05-07', 'http://netflix.com/fargalaxies', '02:10:00', 'B', '2021-07-22', 'Un nuevo universo está a punto de ser descubierto.'),
(500220228385, 'Suspenso', 'Noche Sin Fin', 'Endless Night', 'Frances', 0, 'Francia', '2022-11-11', 'http://amazonprime.com/endlessnight', '01:50:00', 'B15', '2023-01-10', 'Una noche de misterios y revelaciones inesperadas.'),
(600020218279, 'Romance', 'Amor Verdadero', 'True Love', 'English', 1, 'Estados Unidos', '2021-09-15', 'http://max.com/truelove', '01:35:00', 'A', '2021-11-20', 'Historia de un amor que desafía las adversidades.')
GO

INSERT INTO Cine VALUES
(0010010001, 'Montevideo Central', '123 Main St, New York', '2125550123', 12),
(0010020002, 'Montevideo Empire', '234 Elm St, New York', '2125550145', 15),
(9681500101, 'Montevideo Reforma', 'Calle Reforma 255, CDMX', '5551051521', 10),
(9681580102, 'Montevideo Insurgentes', 'Calle Insurgentes 589, CDMX', '5551051522', 8),
(0012003301, 'Montevideo London', 'Leicester Square, London', '2075550189', 9),
(0027500201, 'Montevideo Lyon', '85 Rue de Lyon, Paris', '1405550258', 14)
GO

INSERT INTO Sala VALUES
(0010010001, 1, 150),
(0010020002, 2, 200),
(9681500101, 3, 120),
(9681580102, 4, 300),
(0012003301, 5, 180),
(0027500201, 1, 220)
GO


INSERT INTO Funcion VALUES										
(00100100010123042413, '2024-04-23', '13:00', 100020236882, 1, 0010010001, 'Drama'),
(00100200020220052415, '2024-05-20', '15:00', 200020226779, 2, 0010020002, 'Comedia'),
(96815001010307052417, '2024-05-07', '17:00', 396820236567, 3, 9681500101, 'Accion'),
(96815801020413062419, '2024-06-13', '19:00', 400120216770, 4, 9681580102, 'Ciencia_ficcion'),
(00120033010512072421, '2024-07-12', '21:00', 600020218279, 5, 0012003301, 'Romance'),
(00275002010101082413, '2024-08-01', '13:00', 200020226779, 1, 0027500201, 'Comedia')
GO

INSERT INTO Promocion VALUES
(10100100100010123042413, 'Compra dos entradas y obtén una gratis.', '2x1'),
(20200100200020220052415, 'Compra tres entradas y paga solo dos.', '3x2'),
(30396815001010307052417, '50% de descuento en tu entrada.', '50%'),
(40496815801020413062419, '25% de descuento en tu entrada.', '25%'),
(50500120033010512072421, '30% de descuento en todas las compras.', '30%'),
(60600275002010101082413, '10% de descuento en tu entrada.', '10%')
GO

INSERT INTO Opinion VALUES
(100020236882101, '2024-05-01', 8.5, 'Excelente película con una trama envolvente.', 100020236882, 'Drama'),
(200020226779202, '2024-04-15', 7.0, 'Buena película, pero un poco larga para mi gusto.', 200020226779, 'Comedia'),
(396820236567303, '2024-04-20', 9.0, 'Impresionante secuencia de acción y efectos especiales.', 396820236567, 'Accion'),
(400120216770404, '2024-05-02', 5.5, 'No cumplió con mis expectativas, falta desarrollo de personajes.', 400120216770, 'Ciencia_ficcion'),
(500220228385605, '2024-04-18', 8.0, 'Historia de amor muy bien contada, recomendada.', 600020218279, 'Romance'),
(200020226779206, '2024-04-25', 6.5, 'Divertida, pero predecible.', 200020226779, 'Comedia'),
(1001, '2024-05-10', 9.0, 'Una película realmente inspiradora. La cinematografía es impresionante.', 100020236882, 'Drama'),
(1002, '2024-05-12', 8.0, 'Me encantó la trama y los personajes. Altamente recomendada.', 100020236882, 'Drama'),
(1003, '2024-05-14', 7.5, 'Buena película, aunque algunas partes fueron predecibles.', 100020236882, 'Drama'),
(1004, '2024-05-16', 8.8, 'Excelente actuación y dirección. Un viaje emocional.', 100020236882, 'Drama'),
(1005, '2024-05-18', 7.0, 'La historia es buena, pero se siente un poco larga en algunos momentos.', 100020236882, 'Drama'),
(1006, '2024-05-20', 9.2, 'Una obra maestra moderna. Tocó profundamente mis emociones.', 100020236882, 'Drama'),
(1007, '2024-05-22', 6.5, 'Esperaba más del final, pero en general es una buena película.', 100020236882, 'Drama'),
(1008, '2024-05-24', 8.3, 'Buena película con un mensaje poderoso. Recomendable.', 100020236882, 'Drama'),
(1009, '2024-05-26', 8.7, 'Visualmente impresionante y emocionalmente impactante.', 100020236882, 'Drama'),
(1010, '2024-05-28', 9.5, 'Una experiencia cinematográfica única. Muy bien hecha.', 100020236882, 'Drama')
GO

INSERT INTO ActorDirector VALUES
('RDJ5704219KA', 'Robert', 'Downey', 'N/A', 57, 'Estadounidense', 100020236882),  -- Actor
('CEV4106125HA', 'Chris', 'Evans', 'N/A', 41, 'Estadounidense', 100020236882),  -- Actor
('SSP4804163MA', 'Steven', 'Spielberg', 'N/A', 75, 'Estadounidense', 400120216770),  -- Director
('CNL5403127XA', 'Christopher', 'Nolan', 'N/A', 52, 'Británico', 100020236882),  -- Director
('CHE3908246HB', 'Chris', 'Hemsworth', 'N/A', 39, 'Australiano', 400120216770),  -- Actor
('THO2605098JB', 'Tom', 'Holland', 'N/A', 26, 'Británico', 400120216770)  -- Actor
GO

INSERT INTO Trabaja VALUES
(100020236882, 'RDJ5704219KA', 'Drama'),  
(100020236882, 'CEV4106125HA', 'Drama'), 
(400120216770, 'SSP4804163MA', 'Ciencia_ficcion'),  
(100020236882, 'CNL5403127XA', 'Drama'), 
(400120216770, 'CHE3908246HB', 'Ciencia_ficcion'),  
(400120216770, 'THO2605098JB', 'Ciencia_ficcion')
GO

INSERT INTO Aplica VALUES
(00100100010123042413, 10100100100010123042413), 
(00100200020220052415, 20200100200020220052415), 
(96815001010307052417, 30396815001010307052417), 
(96815801020413062419, 40496815801020413062419),
(00120033010512072421, 50500120033010512072421),
(00275002010101082413, 60600275002010101082413)
GO

INSERT INTO Dirige VALUES
('RDJ5704219KA', 'CNL5403127XA'),
('CEV4106125HA', 'CNL5403127XA'), 
('CHE3908246HB', 'SSP4804163MA'), 
('THO2605098JB', 'SSP4804163MA')
GO

-- CHAT GPT
-- Inserciones en la tabla Pelicula
DECLARE @i INT = 1
WHILE @i <= 1000
BEGIN
    INSERT INTO Pelicula 
    VALUES 
    (
        CONCAT('P', FORMAT(@i, '0000000000')),
        CASE WHEN @i % 6 = 0 THEN 'Drama'
             WHEN @i % 6 = 1 THEN 'Comedia'
             WHEN @i % 6 = 2 THEN 'Accion'
             WHEN @i % 6 = 3 THEN 'Ciencia_ficcion'
             WHEN @i % 6 = 4 THEN 'Suspenso'
             ELSE 'Romance'
        END,
        CONCAT('Titulo_', FORMAT(@i, '0000')),
        CONCAT('Titulo_Original_', FORMAT(@i, '0000')),
        'Idioma',
        @i % 2,
        CONCAT('Pais_', FORMAT(@i, '0000')),
        DATEADD(DAY, @i, '2020-01-01'), -- FechaProduccion
        CONCAT('http://example.com/', FORMAT(@i, '0000')),
        CONCAT(FORMAT(@i % 3 + 1, '00'), ':', FORMAT(@i % 60, '00'), ':00'),
        'A',
        DATEADD(DAY, @i, '2020-01-01'), -- FechaEstreno
        CONCAT('Sinopsis_', FORMAT(@i, '0000'))
    )
    SET @i = @i + 1
END
GO

-- Inserciones en la tabla Cine
DECLARE @j INT = 1
WHILE @j <= 1000
BEGIN
    INSERT INTO Cine 
    VALUES 
    (
        CONCAT('C', FORMAT(@j, '000000')),
        'Nombre_' + FORMAT(@j, '0000'),
        'Direccion_' + FORMAT(@j, '0000'),
        '1234567890',
        @j % 20 + 5
    )
    SET @j = @j + 1
END
GO

-- Inserciones en la tabla Sala
DECLARE @k INT = 1
WHILE @k <= 1000
BEGIN
    INSERT INTO Sala 
    VALUES 
    (
        CONCAT('C', FORMAT(@k, '000000')),
        @k % 10 + 1,
        @k % 150 + 100
    )
    SET @k = @k + 1
END
GO

-- Inserciones en la tabla Funcion
DECLARE @l INT = 1
WHILE @l <= 1000
BEGIN
    INSERT INTO Funcion 
    VALUES 
    (
        CONCAT('F', FORMAT(@l, '0000000000')),
        DATEADD(DAY, @l, '2024-01-01'), -- FechaFuncion
        CONCAT(FORMAT(@l % 24, '00'), ':', FORMAT(@l % 60, '00'), ':00'), -- HoraDeInicio
        CONCAT('P', FORMAT(@l, '0000000000')), -- IdPelicula
        @l % 5 + 1, -- NumeroSala
        CONCAT('C', FORMAT(@l % 1000, '000000')), -- IdCine
        CASE WHEN @l % 6 = 0 THEN 'Drama'
             WHEN @l % 6 = 1 THEN 'Comedia'
             WHEN @l % 6 = 2 THEN 'Accion'
             WHEN @l % 6 = 3 THEN 'Ciencia_ficcion'
             WHEN @l % 6 = 4 THEN 'Suspenso'
             ELSE 'Romance'
        END
    )
    SET @l = @l + 1
END
GO

-- Inserciones en la tabla Promocion
DECLARE @m INT = 1
WHILE @m <= 1000
BEGIN
    INSERT INTO Promocion 
    VALUES 
    (
        CONCAT('Pr', FORMAT(@m, '0000000000')),
        'Descripcion_' + FORMAT(@m, '0000'),
        FORMAT(RAND()*100, '##.#')
    )
    SET @m = @m + 1
END
GO

-- Inserciones en la tabla Opinion
DECLARE @n INT = 1
WHILE @n <= 1000
BEGIN
    INSERT INTO Opinion 
    VALUES 
    (
        CONCAT('O', FORMAT(@n, '0000000000')),
        DATEADD(DAY, @n, '2024-01-01'), -- FechaOpinion
        RAND() * 10, -- Calificacion
        CONCAT('Comentario_', FORMAT(@n, '0000')),
        CONCAT('P', FORMAT(@n, '0000000000')), -- IdPelicula
        CASE WHEN @n % 6 = 0 THEN 'Drama'
             WHEN @n % 6 = 1 THEN 'Comedia'
             WHEN @n % 6 = 2 THEN 'Accion'
             WHEN @n % 6 = 3 THEN 'Ciencia_ficcion'
             WHEN @n % 6 = 4 THEN 'Suspenso'
             ELSE 'Romance'
        END
    )
    SET @n = @n + 1
END
GO

-- Inserciones en la tabla ActorDirector
DECLARE @o INT = 1
WHILE @o <= 1000
BEGIN
    INSERT INTO ActorDirector 
    VALUES 
    (
        CONCAT('RDJ', FORMAT(@o, '00000000')),
        CONCAT('Nombre_', FORMAT(@o, '0000')),
        CONCAT('Apellido_', FORMAT(@o, '0000')),
        'N/A',
        @o % 80 + 20,
        CONCAT('Nacionalidad_', FORMAT(@o, '0000')),
        CONCAT('P', FORMAT(@o, '0000000000'))
    )
    SET @o = @o + 1
END
GO

-- Inserciones en la tabla Trabaja
DECLARE @p INT = 1
WHILE @p <= 1000
BEGIN
    INSERT INTO Trabaja 
    VALUES 
    (
        CONCAT('P', FORMAT(@p, '0000000000')),
        CONCAT('RDJ', FORMAT(@p, '00000000')),
        CASE WHEN @p % 6 = 0 THEN 'Drama'
             WHEN @p % 6 = 1 THEN 'Comedia'
             WHEN @p % 6 = 2 THEN 'Accion'
             WHEN @p % 6 = 3 THEN 'Ciencia_ficcion'
             WHEN @p % 6 = 4 THEN 'Suspenso'
             ELSE 'Romance'
        END
    )
    SET @p = @p + 1
END
GO

-- Inserciones en la tabla Aplica
DECLARE @q INT = 1
WHILE @q <= 1000
BEGIN
    INSERT INTO Aplica 
    VALUES 
    (
        CONCAT('F', FORMAT(@q, '0000000000')),
        CONCAT('Pr', FORMAT(@q, '0000000000'))
    )
    SET @q = @q + 1
END
GO

-- Inserciones en la tabla Dirige
DECLARE @r INT = 1
WHILE @r <= 1000
BEGIN
    INSERT INTO Dirige 
    VALUES 
    (
        CONCAT('RDJ', FORMAT(@r, '00000000')),
        CONCAT('P', FORMAT(@r, '0000000000'))
    )
    SET @r = @r + 1
END
GO

DECLARE @r INT = 1
DECLARE @maxR INT = 1000 -- Esto puede ser ajustado según la cantidad de registros en ActorDirector

WHILE @r <= @maxR
BEGIN
    DECLARE @RFCActor VARCHAR(12)
    DECLARE @RFCDirector VARCHAR(12)
    SET @RFCActor = CONCAT('RDJ', FORMAT(@r, '00000000'))
    SET @RFCDirector = CONCAT('RDJ', FORMAT(@r, '00000000'))

    -- Verificar si los RFCs existen en ActorDirector antes de insertar en Dirige
    IF EXISTS (SELECT 1 FROM ActorDirector WHERE RFC = @RFCActor)
    BEGIN
        INSERT INTO Dirige VALUES (@RFCActor, @RFCDirector)
    END

    SET @r = @r + 1
END
GO

-- CONSULTAS
SELECT * FROM Sala WHERE CantidadButacas>=200
GO
 
SELECT * FROM Promocion WHERE Descuento='2x1'
GO
 
SELECT * FROM Pelicula WHERE PaisesOrigen = 'Estados Unidos'
GO
 
SELECT * FROM Pelicula WHERE Genero = 'Comedia' OR Genero = 'Romance'
GO
 
SELECT * FROM Trabaja WHERE Genero = 'Drama'
GO
 
SELECT * FROM Opinion WHERE Calificacion >= 7.5 AND Genero = 'Drama'
GO
 
SELECT * FROM Dirige WHERE RFCDirector = 'CNL5403127XA'
GO
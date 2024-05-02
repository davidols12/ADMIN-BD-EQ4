USE master
GO
DROP DATABASE Montevideo
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

CREATE PARTITION FUNCTION ParticionPorGenero(VARCHAR(25))
AS RANGE RIGHT FOR VALUES ('Comedia', 'Accion', 'Ciencia_Ficcion', 'Suspenso', 'Romance');
CREATE PARTITION SCHEME EsquemaDeParticionPorGenero
AS PARTITION ParticionPorGenero
TO (fgDrama, fgComedia, fgAccion, fgCiencia_ficcion, fgSuspenso, fgRomance);
GO

CREATE TABLE Pelicula (
    IdPelicula INT,
    Genero VARCHAR(25),
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

CREATE TABLE Cine (
	IdCine INT PRIMARY KEY,
	NombreCine VARCHAR(25),
	Direccion VARCHAR(50),
	Telefono VARCHAR(10),
	CantidadSalas TINYINT
)
GO
CREATE TABLE Sala (
	NumeroSala TINYINT PRIMARY KEY,
	CantidadButacas SMALLINT,
	IdCine INT
)
GO
CREATE TABLE Funcion (
	IdFuncion INT PRIMARY KEY,
	FechaFuncion DATE,
	HoraDeInicio TIME,
	IdPelicula INT,
	NumeroSala TINYINT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE Promocion (
	IdPromocion INT PRIMARY KEY,
	Descripcion VARCHAR(100),
	Descuento VARCHAR(4)
)
GO
CREATE TABLE Opinion (
	IdOpinion INT PRIMARY KEY,
	FechaOpinion DATE,
	Calificacion DECIMAL(4,2),
	Comentario VARCHAR(255),
	IdPelicula INT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE Actor (
	RFC INT PRIMARY KEY,
	Nombre VARCHAR(25),
	ApellidoPaterno VARCHAR(25),
	ApellidoMaterno VARCHAR(25),
	Edad TINYINT,
	Nacionalidad VARCHAR(25),
	IdPelicula INT
)
GO
CREATE TABLE Director (
	RFC INT PRIMARY KEY,
	Nombre VARCHAR(25),
	ApellidoPaterno VARCHAR(25),
	ApellidoMaterno VARCHAR(25),
	Edad TINYINT,
	Nacionalidad VARCHAR(25),
	IdPelicula INT
)
GO
/* NORMALIZACION */
/* PeliculaActor */
CREATE TABLE Trabaja (
	IdPelicula INT,
	RFCActor INT,
	Genero VARCHAR(25)
)
GO

/* FuncionPromocion */
CREATE TABLE Aplica (
	IdFuncion INT,
	IdPromocion INT
)

CREATE TABLE Dirige (
	RFCActor INT,
	RFCDirector INT
)
GO

ALTER TABLE Dirige ADD CONSTRAINT
FK_Dirige_Actor FOREIGN KEY(IdActor)
REFERENCES Actor(IdActor)
GO

ALTER TABLE Dirige ADD CONSTRAINT
FK_Dirige_Director FOREIGN KEY(IdDirector)
REFERENCES Actor(IdDirector)
GO

/* LLAVES FORANEAS */
--FK DIRIGE
ALTER TABLE Dirige ADD CONSTRAINT
FK_Dirige_Director FOREIGN KEY(IdDirector)
REFERENCES ActorDirector(RFC)
GO

ALTER TABLE DIrige ADD CONSTRAINT 
FK_Dirige_Actor FOREIGN KEY(IdActor)
REFERENCES ActorDirector(RFC)

--FK TRABAJA
ALTER TABLE Trabaja ADD CONSTRAINT
FK_Trabaja_Pelicula FOREIGN KEY(IdPelicula,Genero)
REFERENCES Pelicula(RFC, Genero)
GO

ALTER TABLE PeliculaActor ADD CONSTRAINT
FK_Pelicula_ActorDIrector FOREIGN KEY(IdActor)
REFERENCES ActorDirector(RFC)
GO

--FK OPINION 
ALTER TABLE Opinion ADD CONSTRAINT
FK_Opinion_IdOpinion FOREIGN KEY(IdPelicula)
REFERENCES Pelicula(IdPelicula)
GO

--FK FUNCION
ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdPelicula FOREIGN KEY(IdPelicula)
REFERENCES Pelicula(IdPelicula)
GO

ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdSala FOREIGN KEY(IdSala)
REFERENCES Sala(IdSala)
GO

--FK APLICA
ALTER TABLE Aplica ADD CONSTRAINT
FK_Aplica_Funcion FOREIGN KEY(IdFuncion)
REFERENCES Funcion(IdFuncion)

ALTER TABLE Aplica ADD CONSTRAINT
FK_Aplica_Promocion FOREIGN KEY(IdPromocion)
REFERENCES Promocion(IdPromocion)
GO

--FK SALA
ALTER TABLE Sala ADD CONSTRAINT
FK_Sala_IdCine FOREIGN KEY(IdCine)
REFERENCES Cine(IdCine)
GO
USE master
GO
DROP DATABASE Montevideo
GO

Create database Montevideo
on primary (
name=db_dat,
filename= 'C:\data\proyecto\db.mdf', 
size = 2mb),
  Filegroup fgDrama
  (
  name=fg1_dat,
filename= 'C:\data\proyecto\fg1.ndf', 
size = 2mb),
Filegroup fgComedia
  (
  name=fg2_dat,
filename= 'C:\data\proyecto\fg2.ndf', 
size = 2mb),
Filegroup fgAccion
  (
  name=fg3_dat,
filename= 'C:\data\proyecto\fg3.ndf', 
size = 2mb),
Filegroup fgCiencia_ficcion
  (
  name=fg4_dat,
filename= 'C:\data\proyecto\fg4.ndf', 
size = 2mb),
Filegroup fgSuspenso
  (
  name=fg5_dat,
filename= 'C:\data\proyecto\fg5.ndf', 
size = 2mb),
Filegroup fgRomance
  (
  name=fg6_dat,
filename= 'C:\data\proyecto\fg6.ndf', 
size = 2mb)
Log on 
(name=db_log,
filename= 'C:\data\proyecto\log.ndf', 
size = 5mb, filegrowth=10%
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
    TituloDistribucion VARCHAR(25),
    TituloOriginal VARCHAR(50),
    IdiomaOriginal VARCHAR(10),
    SubtitulosEspanol BIT,
    PaisesOrigen VARCHAR(25),
    FechaProduccion DATE,
    URL NVARCHAR(255),
    Duracion TIME,
    Clasificacion VARCHAR(10),
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
	CantidadSalas INT
)
GO
CREATE TABLE Sala (
	IdSala INT PRIMARY KEY,
	NombreSala VARCHAR(25),
	NumeroSala INT,
	CantidadButacas INT,
	IdCine INT
)
GO
CREATE TABLE Funcion (
	IdFuncion INT PRIMARY KEY,
	FechaFuncion DATE,
	HoraDeInicio TIME,
	IdPelicula INT,
	IdSala INT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE Promocion (
	IdPromocion INT PRIMARY KEY,
	Descripcion VARCHAR(100),
	Descuento INT
)
GO
CREATE TABLE Opinion (
	IdOpinion INT PRIMARY KEY,
	FechaOpinion DATE,
	Calificacion DECIMAL,
	Comentario VARCHAR(255),
	IdPelicula INT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE ActorDirector (
	IdPersona INT PRIMARY KEY,
	Nombre VARCHAR(25),
	ApellidoPaterno VARCHAR(25),
	ApellidoMaterno VARCHAR(25),
	Edad INT,
	Nacionalidad VARCHAR(25),
	IdDirector INT,
	IdPelicula INT
)
GO
/* NORMALIZACION */
CREATE TABLE PeliculaActor (
	IdPelicula INT,
	IdActor INT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE FuncionPromocion (
	IdFuncion INT,
	IdPromocion INT
)
GO
/* LLAVES FORANEAS */
ALTER TABLE ActorDirector ADD CONSTRAINT
FK_ActorDirector_Director FOREIGN KEY(IdDirector)
REFERENCES ActorDirector(IdPersona)
GO

ALTER TABLE PeliculaActor
ADD CONSTRAINT FK_PeliculaActor_Pelicula 
FOREIGN KEY (IdPelicula, Genero) 
REFERENCES Pelicula(IdPelicula, Genero);
GO

ALTER TABLE PeliculaActor ADD CONSTRAINT
FK_PeliculaActor_IdPersona FOREIGN KEY(IdActor)
REFERENCES ActorDirector(IdPersona)
GO

/ALTER TABLE Opinion ADD CONSTRAINT
FK_Opinion_IdOpinion FOREIGN KEY(IdPelicula, Genero)
REFERENCES Pelicula(IdPelicula, Genero)
GO

ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdPelicula FOREIGN KEY(IdPelicula, Genero)
REFERENCES Pelicula(IdPelicula, Genero)
GO

ALTER TABLE FuncionPromocion ADD CONSTRAINT
FK_FuncionPromocion_IdFuncion FOREIGN KEY(IdFuncion)
REFERENCES Funcion(IdFuncion)
GO

ALTER TABLE FuncionPromocion ADD CONSTRAINT
FK_FuncionPromocion_IdPromocion FOREIGN KEY(IdPromocion)
REFERENCES Promocion(IdPromocion)
GO

ALTER TABLE Funcion ADD CONSTRAINT
FK_Funcion_IdSala FOREIGN KEY(IdSala)
REFERENCES Sala(IdSala)
GO

ALTER TABLE Sala ADD CONSTRAINT
FK_Sala_IdCine FOREIGN KEY(IdCine)
REFERENCES Cine(IdCine)
GO
---drop database Montevideo
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
AS RANGE RIGHT FOR VALUES ('Comedia', 'Accion', 'Ciencia_Ficcion', 'Suspenso', 'Romance')
GO

CREATE PARTITION SCHEME EsquemaDeParticionPorGenero
AS PARTITION ParticionPorGenero
TO (fgDrama, fgComedia, fgAccion, fgCiencia_ficcion, fgSuspenso, fgRomance);
GO
							--2 primeras letras o iniciales del titulo
CREATE TABLE Pelicula ( --identificador-pais-año-genero
    IdPelicula BIGINT,		---0000-000-0000-0
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

CREATE TABLE Cine (			---pais-cp-numero de sucursal
	IdCine BIGINT PRIMARY KEY,	---000-0000-000
	NombreCine VARCHAR(25),
	Direccion VARCHAR(50),
	Telefono VARCHAR(10),
	CantidadSalas TINYINT
)
GO
CREATE TABLE Sala (
    NumeroSala TINYINT,
    CantidadButacas SMALLINT,
    IdCine BIGINT,
    PRIMARY KEY (NumeroSala, IdCine)
)
GO
CREATE TABLE Funcion (			--Sala-identificador-dd/mm/yy-hora
	IdFuncion BIGINT PRIMARY KEY,	 --00-000-000000-0000
	FechaFuncion DATE,
	HoraDeInicio TIME,
	IdPelicula BIGINT,
	NumeroSala TINYINT,
	IdCine BIGINT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE Promocion (		 --tipo-funcion
	IdPromocion BIGINT PRIMARY KEY, --000-000000000000000
	Descripcion VARCHAR(100),
	Descuento VARCHAR(4)
)
GO
CREATE TABLE Opinion (			--pelicula-identificador
	IdOpinion BIGINT PRIMARY KEY,--000000000000-0
	FechaOpinion DATE,
	Calificacion DECIMAL(4,2),
	Comentario VARCHAR(255),
	IdPelicula BIGINT,
	Genero VARCHAR(25)
)
GO
CREATE TABLE ActorDirector (
	RFC VARCHAR(12) PRIMARY KEY,
	Nombre VARCHAR(25),
	ApellidoPaterno VARCHAR(25),
	ApellidoMaterno VARCHAR(25),
	Edad TINYINT,
	Nacionalidad VARCHAR(25),
	IdPelicula BIGINT
)
GO


/* NORMALIZACION */
/* PeliculaActor */
CREATE TABLE Trabaja (
	IdPelicula BIGINT,
	RFC VARCHAR(12),
	Genero VARCHAR(25)
)
GO

/* FuncionPromocion */
CREATE TABLE Aplica (
	IdFuncion BIGINT,
	IdPromocion BIGINT
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
FK_Funcion_IdSala FOREIGN KEY(NumeroSala, IdCine)
REFERENCES Sala(NumeroSala, IdCine)
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
(53454900020231, 'Drama', 'El Gran Camino', 'The Great Path', 'English', 1, 'USA', '2023-01-15', 'http://amazonprime.com/thegreatpath', '01:45:00', 'A', '2023-03-01', 'Un viaje emocional de auto descubrimiento.'),
(66526900020222, 'Comedia', 'Sonrisas por Siempre', 'Smiles Forever', 'English', 0, 'USA', '2022-06-20', 'http://max.com/smilesforever', '01:30:00', 'A', '2022-08-15', 'Una comedia que te hará reír hasta llorar.'),
(79506996820233, 'Accion', 'Rápidos Extremos', 'Fast Extreme', 'Spanish', 1, 'Mexico', '2023-02-10', 'http://paramount.com/fastextreme', '02:00:00', 'B15', '2023-04-12', 'Carreras clandestinas en un entorno despiadado.'),
(67527300120214, 'Ciencia_ficcion', 'Galaxias Lejanas', 'Far Galaxies', 'English', 1, 'UK', '2021-05-07', 'http://netflix.com/fargalaxies', '02:10:00', 'B', '2021-07-22', 'Un nuevo universo está a punto de ser descubierto.'),
(83726900220225, 'Suspenso', 'Noche Sin Fin', 'Endless Night', 'French', 0, 'France', '2022-11-11', 'http://amazonprime.com/endlessnight', '01:50:00', 'B15', '2023-01-10', 'Una noche de misterios y revelaciones inesperadas.'),
(85726500020216, 'Romance', 'Amor Verdadero', 'True Love', 'English', 1, 'USA', '2021-09-15', 'http://max.com/truelove', '01:35:00', 'A', '2021-11-20', 'Historia de un amor que desafía las adversidades.'),
(69726908120231, 'Drama', 'Esperanzas Rurales', 'Rural Hopes', 'Hindi', 1, 'India', '2023-01-01', 'http://netflix.com/ruralhopes', '02:20:00', 'A', '2023-02-25', 'Una lucha inspiradora en las aldeas de la India.'),
(65506700720212, 'Comedia', 'Risas en Shanghai', 'Laughs in Shanghai', 'Mandarin', 0, 'China', '2021-04-04', 'http://max.com/laughsinshanghai', '01:45:00', 'A', '2021-06-10', 'Comedia urbana con un toque chino.'),
(76506900020223, 'Accion', 'Agentes Secretos', 'Secret Agents', 'English', 1, 'USA', '2022-07-15', 'http://amazonprime.com/secretagents', '01:55:00', 'B15', '2022-09-30', 'Espionaje y acción al límite.'),
(83657808820234, 'Ciencia_ficcion', 'Robots del Futuro', 'Future Robots', 'Italian', 0, 'Italy', '2023-03-25', 'http://amazonprime.com/futurerobots', '02:00:00', 'B', '2023-05-20', 'La robótica que cambiará el mundo.'),
(73726500520215, 'Suspenso', 'Siberian Mystery', 'Misterio Siberiano', 'Russian', 1, 'Russia', '2021-10-10', 'http://netflix.com/siberianmystery', '02:15:00', 'B15', '2021-12-05', 'Un thriller helado con giros inesperados.'),
(73756108420226, 'Romance', 'Pasiones Españolas', 'Spanish Passions', 'Spanish', 1, 'Spain', '2022-05-05', 'http://max.com/spanishpassions', '01:40:00', 'A', '2022-07-25', 'Amor y deseo en el corazón de España.'),
(52696908920231, 'Drama', 'Memorias de Seúl', 'Seoul Memories', 'Korean', 0, 'South Korea', '2023-02-14', 'http://netflix.com/seoulmemories', '02:05:00', 'A', '2023-04-01', 'Un drama conmovedor que explora las relaciones familiares.'),
(66527000420222, 'Comedia', 'Tokio Loco', 'Tokyo Crazy', 'Japanese', 1, 'Japan', '2022-08-08', 'http://max.com/tokyocrazy', '01:50:00', 'A', '2022-10-15', 'Diversión y locuras en el corazón de Japón.'),
(84657800320214, 'Ciencia_ficcion', 'Neo Berlin', 'Neo Berlin', 'German', 0, 'Germany', '2021-12-12', 'http://max.com/neoberlin', '02:25:00', 'C', '2022-02-20', 'Un futuro distópico cargado de acción y tecnología.')
GO

INSERT INTO Cine VALUES
(0001001001, 'Montevideo Central', '123 Main St, New York', '2125550123', 12),
(0001002002, 'Montevideo Empire', '234 Elm St, New York', '2125550145', 15),
(9681500101, 'Montevideo Reforma', 'Calle Reforma 255, CDMX', '5551051521', 10),
(9681500102, 'Montevideo Insurgentes', 'Calle Insurgentes 589, CDMX', '5551051522', 8),
(0012003301, 'Montevideo London', 'Leicester Square, London', '2075550189', 9),
(0027500201, 'Montevideo Lyon', '85 Rue de Lyon, Paris', '1405550258', 14),
(0815601301, 'Montevideo Plaza', 'Mall Road, Mumbai', '2255550199', 20),
(0077500401, 'Montevideo Dongcheng', 'Dongcheng, Beijing', '1055550266', 18),
(0885602501, 'Montevideo Tuscolana', 'Via Tuscolana, Rome', '0655550356', 16),
(0051985601, 'Montevideo Nevsky', 'Nevsky Avenue, St Petersburg', '8125550498', 12),
(0842800301, 'Montevideo Barcelona', 'Gran Via de les Corts, Barcelona', '9355550589', 11),
(0896701201, 'Montevideo Yeongdeungpo', 'Yeongdeungpo-gu, Seoul', '2705550623', 13),
(0043900701, 'Montevideo Shinjuku', 'Shinjuku, Tokyo', '3505550665', 10),
(0031000101, 'Montevideo Potsdamer', 'Potsdamer Platz, Berlin', '3055550705', 15),
(0031000201, 'Montevideo Mönckeberg', 'Mönckebergstrasse, Hamburg', '4055550733', 14)
GO

INSERT INTO Sala VALUES
(1, 150, 0001001001),
(2, 200, 0001001001),
(3, 120, 0001001001),
(4, 300, 0001001001),
(5, 180, 0001001001),
(1, 220, 0001002002),
(2, 180, 0001002002),
(3, 150, 0001002002),
(1, 100, 9681500101),
(2, 150, 9681500101),
(1, 300, 0012003301),
(2, 250, 0012003301),
(1, 250, 0027500201),
(2, 220, 0027500201),
(3, 200, 0027500201)
GO
INSERT INTO Funcion VALUES
(101042320231300, '2023-04-23', '13:00', 53454900020231, 1, 0001001001, 'Drama'),
(102042320231500, '2023-04-23', '15:00', 66526900020222, 2, 0001001001, 'Comedia'),
(103042320231700, '2023-04-23', '17:00', 79506996820233, 3, 0001001001, 'Accion'),
(104042320231900, '2023-04-23', '19:00', 67527300120214, 4, 0001001001, 'Ciencia_ficcion'),
(105042320232100, '2023-04-23', '21:00', 85726500020216, 5, 0001001001, 'Romance'),
(201042421231300, '2023-04-21', '13:00', 66527000420222, 1, 0001002002, 'Comedia'),
(202042421231500, '2023-04-21', '15:00', 79506996820233, 2, 0001002002, 'Accion'),
(203042421231700, '2023-04-21', '17:00', 84657800320214, 3, 0001002002, 'Ciencia_ficcion'),
(301042520231300, '2023-04-25', '13:00', 69726908120231, 1, 9681500101, 'Drama'),
(302042520231500, '2023-04-25', '15:00', 66527000420222, 2, 9681500101, 'Comedia'),
(401042520231300, '2023-04-25', '13:00', 85726500020216, 1, 0012003301, 'Romance'),
(402042520231500, '2023-04-25', '15:00', 76506900020223, 2, 0012003301, 'Accion'),
(501042620231300, '2023-04-26', '13:00', 69726908120231, 1, 0027500201, 'Drama'),
(502042620231500, '2023-04-26', '15:00', 83726900220225, 2, 0027500201, 'Suspenso'),
(503042620231700, '2023-04-26', '17:00', 52696908920231, 3, 0027500201, 'Drama')
GO

INSERT INTO Promocion VALUES
(101105042320232100, 'Compra dos entradas y obtén una gratis.', '2x1'),
(202503042620231700, 'Compra tres entradas y paga solo dos.', '3x2'),
(303105042320232100, '50% de descuento en tu entrada.', '50%'),
(404503042620231700, '25% de descuento en tu entrada.', '25%'),
(505202042421231500, '30% de descuento en todas las compras.', '30%'),
(606301042520231300, '10% de descuento en tu entrada.', '10%'),
(707501042620231300, 'Obtén palomitas gratis con cada entrada comprada.', '100'),
(808104042320231900, 'Recibe una soda gratis con la compra de tu entrada.', '100'),
(909104042320231900, '20% de descuento en combos de snacks.', '20%'),
(010501042620231300, '15% de descuento para señores en todas las funciones.', '15%'),
(111101042320231300, 'Compra una entrada de adulto y la entrada de niño es gratis.', '100'),
(212402042520231500, '35% de descuento todos los martes.', '35%'),
(313402042520231500, '40% de descuento en funciones matutinas.', '40%'),
(414202042421231500, '45% de descuento en el día del espectador.', '45%'),
(515101042320231300, '20% de descuento para estudiantes.', '20%')
GO

INSERT INTO Opinion VALUES
(5345490002023101, '2023-05-01', 8.5, 'Excelente película con una trama envolvente.', 53454900020231, 'Drama'),
(6652690002022202, '2023-04-15', 7.0, 'Buena película, pero un poco larga para mi gusto.', 66526900020222, 'Comedia'),
(7950699682023303, '2023-04-20', 9.0, 'Impresionante secuencia de acción y efectos especiales.', 79506996820233, 'Accion'),
(6752730012021404, '2023-05-02', 5.5, 'No cumplió con mis expectativas, falta desarrollo de personajes.', 67527300120214, 'Ciencia_ficcion'),
(8572650002021605, '2023-04-18', 8.0, 'Historia de amor muy bien contada, recomendada.', 85726500020216, 'Romance'),
(6652700042022206, '2023-04-25', 6.5, 'Divertida, pero predecible.', 66527000420222, 'Comedia'),
(8372690022022507, '2023-05-03', 4.0, 'Decepcionante, esperaba mucho más.', 83726900220225, 'Suspenso'),
(6972690812023108, '2023-04-10', 7.5, 'Interesante película de drama, muy conmovedora.', 69726908120231, 'Drama'),
(6550670072021209, '2023-04-22', 8.8, 'Excelente para ver en familia, muy divertida.', 65506700720212, 'Comedia'),
(7650690002022310, '2023-04-29', 5.0, 'La trama era confusa y los diálogos muy forzados.', 76506900020223, 'Accion'),
(8365780882023411, '2023-05-04', 9.5, 'Una obra maestra del cine de ciencia ficción.', 83657808820234, 'Ciencia_ficcion'),
(7372650052021512, '2023-04-11', 3.5, 'Mala, sin más que añadir.', 73726500520215, 'Suspenso'),
(7375610842022613, '2023-04-26', 8.2, 'Muy buena representación histórica y cinematográfica.', 73756108420226, 'Romance'),
(5269690892023114, '2023-04-17', 7.8, 'Fascinante, una experiencia cultural profunda.', 52696908920231, 'Drama'),
(8465780032021415, '2023-04-30', 4.8, 'Intenta ser demasiado innovadora y termina siendo pretenciosa.', 84657800320214, 'Ciencia_ficcion')
GO

INSERT INTO ActorDirector VALUES
('RDJ5704219KA', 'Robert', 'Downey', 'N/A', 57, 'Estadounidense', 53454900020231),  -- Actor
('CEV4106125HA', 'Chris', 'Evans', 'N/A', 41, 'Estadounidense', 66526900020222),  -- Actor
('SSP4804163MA', 'Steven', 'Spielberg', 'N/A', 75, 'Estadounidense', 79506996820233),  -- Director
('CNL5403127XA', 'Christopher', 'Nolan', 'N/A', 52, 'Británico', 67527300120214),  -- Director
('CHE3908246HB', 'Chris', 'Hemsworth', 'N/A', 39, 'Australiano', 85726500020216),  -- Actor
('THO2605098JB', 'Tom', 'Holland', 'N/A', 26, 'Británico', 66527000420222),  -- Actor
('QTA6303134KC', 'Quentin', 'Tarantino', 'N/A', 60, 'Estadounidense', 83726900220225),  -- Director
('RID3306178LD', 'Ridley', 'Scott', 'N/A', 85, 'Británico', 69726908120231),  -- Director
('JLA3208239JE', 'Jennifer', 'Lawrence', 'N/A', 32, 'Estadounidense', 65506700720212),  -- Actor
('BPI5903110KF', 'Brad', 'Pitt', 'N/A', 59, 'Estadounidense', 76506900020223),  -- Actor
('LDI4807071LG', 'Leonardo', 'DiCaprio', 'N/A', 48, 'Estadounidense', 83657808820234),  -- Actor
('AJO4705182MH', 'Angelina', 'Jolie', 'N/A', 47, 'Estadounidense', 73726500520215),  -- Actor
('DWA6804223NH', 'Denzel', 'Washington', 'N/A', 68, 'Estadounidense', 73756108420226),  -- Actor
('THA6605014OI', 'Tom', 'Hanks', 'N/A', 66, 'Estadounidense', 52696908920231),  -- Actor
('PTA4103055PJ', 'Paul Thomas', 'Anderson', 'N/A', 52, 'Estadounidense', 84657800320214)  -- Director
GO

INSERT INTO Trabaja VALUES
(53454900020231, 'RDJ5704219KA', 'Drama'),  
(66526900020222, 'CEV4106125HA', 'Comedia'), 
(79506996820233, 'SSP4804163MA', 'Accion'),  
(67527300120214, 'CNL5403127XA', 'Ciencia_ficcion'), 
(85726500020216, 'CHE3908246HB', 'Romance'),  
(66527000420222, 'THO2605098JB', 'Comedia'), 
(83726900220225, 'QTA6303134KC', 'Suspenso'),  
(69726908120231, 'RID3306178LD', 'Drama'),  
(65506700720212, 'JLA3208239JE', 'Comedia'), 
(76506900020223, 'BPI5903110KF', 'Accion'), 
(83657808820234, 'LDI4807071LG', 'Ciencia_ficcion'), 
(73726500520215, 'AJO4705182MH', 'Suspenso'), 
(73756108420226, 'DWA6804223NH', 'Romance'), 
(52696908920231, 'THA6605014OI', 'Drama'),  
(84657800320214, 'PTA4103055PJ', 'Ciencia_ficcion')
GO

INSERT INTO Aplica VALUES
(101042320231300, 111101042320231300), 
(102042320231500, 505202042421231500), 
(103042320231700, 212402042520231500), 
(104042320231900, 808104042320231900),
(105042320232100, 303105042320232100),
(201042421231300, 606301042520231300),
(202042421231500, 414202042421231500),
(203042421231700, 909104042320231900), 
(301042520231300, 707501042620231300), 
(302042520231500, 101105042320232100), 
(401042520231300, 515101042320231300),
(402042520231500, 313402042520231500), 
(501042620231300, 010501042620231300), 
(502042620231500, 202503042620231700), 
(503042620231700, 404503042620231700)  
GO

INSERT INTO Dirige VALUES
('RDJ5704219KA', 'SSP4804163MA'),
('CEV4106125HA', 'CNL5403127XA'), 
('JLA3208239JE', 'QTA6303134KC'), 
('BPI5903110KF', 'RID3306178LD'), 
('LDI4807071LG', 'PTA4103055PJ'), 
('AJO4705182MH', 'SSP4804163MA'),
('THO2605098JB', 'CNL5403127XA'), 
('CHE3908246HB', 'QTA6303134KC'),
('DWA6804223NH', 'RID3306178LD'), 
('THA6605014OI', 'PTA4103055PJ'), 
('RDJ5704219KA', 'CNL5403127XA'), 
('CEV4106125HA', 'QTA6303134KC'),
('JLA3208239JE', 'RID3306178LD'), 
('BPI5903110KF', 'SSP4804163MA'), 
('LDI4807071LG', 'CNL5403127XA') 
GO

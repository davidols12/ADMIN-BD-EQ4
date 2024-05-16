USE Montevideo
GO

-- Consulta para obtener todas las opiniones de una película específica
SELECT 
    O.IdOpinion,
    O.FechaOpinion,
    O.Calificacion,
    O.Comentario,
    P.TituloDistribucion AS TituloPelicula
FROM 
    Opinion O
INNER JOIN 
    Pelicula P ON O.IdPelicula = P.IdPelicula
WHERE 
    P.TituloDistribucion = 'El Gran Camino'
GO

-- Consulta para obtener todas las Peliculas que el Idioma Original sea el Ingles
SELECT 
    F.IdFuncion,
    F.FechaFuncion,
    F.HoraDeInicio,
    P.TituloDistribucion AS TituloPelicula,
    P.Genero
FROM 
    Funcion F
INNER JOIN 
    Pelicula P ON F.IdPelicula = P.IdPelicula
WHERE 
    P.IdiomaOriginal = 'ingles';
GO

-- Funcion para obtener la cantidad de funciones por Genero
SELECT 
    F.Genero,
    COUNT(F.IdFuncion) AS NumeroDeFunciones
FROM 
    Funcion F
GROUP BY 
    F.Genero
ORDER BY 
    NumeroDeFunciones DESC;
GO

-- Consulta para obtener la cantidad de Opiniones y el Promedio de Calificacion por Pelicula.
SELECT 
    P.TituloDistribucion AS TituloPelicula,
    COUNT(O.IdOpinion) AS NumeroDeOpiniones,
    AVG(O.Calificacion) AS CalificacionPromedio
FROM 
    Opinion O
INNER JOIN 
    Pelicula P ON O.IdPelicula = P.IdPelicula
GROUP BY 
    P.TituloDistribucion
ORDER BY 
    CalificacionPromedio DESC;

-- Consulta para saber las funciones en un rango de tiempo.
SELECT 
    F.IdFuncion,
    P.TituloDistribucion AS TituloPelicula,
    C.NombreCine AS NombreCine,
    F.FechaFuncion,
    F.HoraDeInicio
FROM 
    Funcion F
INNER JOIN 
    Pelicula P ON F.IdPelicula = P.IdPelicula
INNER JOIN 
    Cine C ON F.IdCine = C.IdCine
WHERE 
    F.FechaFuncion BETWEEN '2024-05-01' AND '2024-12-31';
/*
Procedimiento almacenado que recibe como argumento el identificador de una materia y 
   la fecha de examen, y muestra los alumnos que pueden rendirla en esa fecha

   Un alumno puede rendir una materia en una fecha determinada si:

   a. Está regular en la misma, lo que implica:
     - Tiene un registro en cursado con regular = 'S'
     - Para ese registro tiene menos aplazos que la cantidad máxima definida para la carrera
     - Esa regularidad no está vencida (el año de cursado + años de regularidad definidos para la carrera 
	   es mayor al año de la fecha de examen)
   
   b. La materia no está aprobada

   Muestra: Nro. de alumno, apellido y nombres, y el año de cursado en estado regular
   ------------------------------------------------------------
	nro. alumno		apellido y nombres			año cursado
   ------------------------------------------------------------
     xxxxx			xxxxxxxxxxxxxxxxxxxxxxxxx		xxxx
     xxxxx			xxxxxxxxxxxxxxxxxxxxxxxxx		xxxx
     xxxxx			xxxxxxxxxxxxxxxxxxxxxxxxx		xxxx
     xxxxx			xxxxxxxxxxxxxxxxxxxxxxxxx		xxxx


	  Un procedimiento almacenado que reciba como parámetros el identificador de una materia y una fecha de examen, 
	  y que muestre los alumnos que pueden rendir esa materia en esa fecha
*/

CREATE PROCEDURE AlumnosQuePuedenRendir
    @cod_materia CHAR(4),
    @fecha_examen DATE
AS
BEGIN
    DECLARE @anio_examen INT;
    SET @anio_examen = YEAR(@fecha_examen);

    SELECT a.nro_alumno, 
           a.nom_alumno AS nombre, 
           c.año_cursado
    FROM alumnos a
    JOIN cursados c ON a.nro_alumno = c.nro_alumno
    JOIN carreras cr ON c.cod_carrera = cr.cod_carrera
    LEFT JOIN (
        SELECT e.nro_alumno, e.cod_carrera, e.cod_materia, COUNT(*) AS aplazos
        FROM examenes e
        JOIN carreras ca ON e.cod_carrera = ca.cod_carrera
        WHERE e.nota_examen IS NOT NULL AND e.nota_examen < ca.nota_aprobacion
        GROUP BY e.nro_alumno, e.cod_carrera, e.cod_materia
    ) AS apl ON c.nro_alumno = apl.nro_alumno AND c.cod_carrera = apl.cod_carrera AND c.cod_materia = apl.cod_materia
    LEFT JOIN (
        SELECT e.nro_alumno, e.cod_carrera, e.cod_materia, MAX(e.nota_examen) AS max_nota
        FROM examenes e
        GROUP BY e.nro_alumno, e.cod_carrera, e.cod_materia
    ) AS ex ON c.nro_alumno = ex.nro_alumno AND c.cod_carrera = ex.cod_carrera AND c.cod_materia = ex.cod_materia
    WHERE c.cod_materia = @cod_materia
      AND c.regular = 'S'
      AND (apl.aplazos IS NULL OR apl.aplazos < cr.cant_max_aplazos)
      AND (c.año_cursado + cr.años_regularidad) > @anio_examen
      AND (ex.max_nota IS NULL OR ex.max_nota < cr.nota_aprobacion)
    ORDER BY a.nro_alumno;
END;
GO

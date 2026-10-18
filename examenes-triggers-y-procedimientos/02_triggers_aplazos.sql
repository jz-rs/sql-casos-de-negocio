/*

Triggers necesarios para asegurar la siguiente regla de integridad:

   "Un alumno no puede inscribirse al examen de una materia para un cursado que ya tiene 
   la cantidad máxima de aplazos"


   Controlar la cantidad de aplazos:

   El control no se hace solo al inscribirse, sino en cualquier momento en que se viole esa regla de integridad.

   Se utiliza un cursor para analizar fila por fila

*/

/* Paso 1: determinar las filas que no cumpen con la regla de integridad */

SELECT e.nro_alumno, e.cod_carrera, e.cod_materia, COUNT(*) AS cantidad_aplazos, c.cant_max_aplazos
FROM dbo.examenes e
JOIN dbo.carreras c ON e.cod_carrera = c.cod_carrera
WHERE e.nota_examen IS NOT NULL AND e.nota_examen < c.nota_aprobacion
GROUP BY e.nro_alumno, e.cod_carrera, e.cod_materia, c.cant_max_aplazos
HAVING COUNT(*) > c.cant_max_aplazos;


/* Paso 2: determinar que trigger debo programar */

/* 
	Tabla			Insert			Delete			Update
	Examenes		 SI				  NO			  SI		

*/


/* Paso 3: Programar los trigger necesarios */

/* Trigger de insercion*/

CREATE TRIGGER trg_after_insert_examen
ON dbo.examenes
AFTER INSERT
AS
BEGIN
    DECLARE @cod_carrera SMALLINT;
    DECLARE @cod_materia CHAR(4);
    DECLARE @nro_alumno INTEGER;
    DECLARE @nota_aprobacion TINYINT;
    DECLARE @cant_max_aplazos TINYINT;
    DECLARE @cantidad_aplazos INT;

	/* Cursor: Iterar sobre las filas insertadas */
    DECLARE cur CURSOR FOR
    SELECT i.cod_carrera, i.cod_materia, i.nro_alumno, c.nota_aprobacion, c.cant_max_aplazos
    FROM inserted i
    JOIN dbo.carreras c ON i.cod_carrera = c.cod_carrera;

    OPEN cur;
    FETCH NEXT FROM cur INTO @cod_carrera, @cod_materia, @nro_alumno, @nota_aprobacion, @cant_max_aplazos;

    WHILE @@FETCH_STATUS = 0
    BEGIN

	/* Contar la cantidad de aplazos */
        SELECT @cantidad_aplazos = COUNT(*)
        FROM dbo.examenes e
        WHERE e.cod_carrera = @cod_carrera
          AND e.cod_materia = @cod_materia
          AND e.nro_alumno = @nro_alumno
          AND e.nota_examen IS NOT NULL
          AND e.nota_examen < @nota_aprobacion;

		  /* Verificar si la cantidad de aplazos alcanza el máximo permitido */
        IF @cantidad_aplazos >= @cant_max_aplazos
        BEGIN
            RAISERROR('El alumno ya ha alcanzado la cantidad máxima de aplazos para esta materia.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        FETCH NEXT FROM cur INTO @cod_carrera, @cod_materia, @nro_alumno, @nota_aprobacion, @cant_max_aplazos;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

/* Trigger de actualizacion*/

CREATE TRIGGER trg_after_update_examen
ON dbo.examenes
AFTER UPDATE
AS
BEGIN
    DECLARE @cod_carrera SMALLINT;
    DECLARE @cod_materia CHAR(4);
    DECLARE @nro_alumno INTEGER;
    DECLARE @nota_aprobacion TINYINT;
    DECLARE @cant_max_aplazos TINYINT;
    DECLARE @cantidad_aplazos INT;

	/* Cursor: Iterar sobre las filas actualizadas */
    DECLARE cur CURSOR FOR
    SELECT i.cod_carrera, i.cod_materia, i.nro_alumno, c.nota_aprobacion, c.cant_max_aplazos
    FROM inserted i
    JOIN dbo.carreras c ON i.cod_carrera = c.cod_carrera;

    OPEN cur;
    FETCH NEXT FROM cur INTO @cod_carrera, @cod_materia, @nro_alumno, @nota_aprobacion, @cant_max_aplazos;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		/* Contar la cantidad de aplazos */
        SELECT @cantidad_aplazos = COUNT(*)
        FROM dbo.examenes e
        WHERE e.cod_carrera = @cod_carrera
          AND e.cod_materia = @cod_materia
          AND e.nro_alumno = @nro_alumno
          AND e.nota_examen IS NOT NULL
          AND e.nota_examen < @nota_aprobacion;

		/* Verificar si la cantidad de aplazos alcanza el máximo permitido */
        IF @cantidad_aplazos >= @cant_max_aplazos
        BEGIN
            RAISERROR('El alumno ya ha alcanzado la cantidad máxima de aplazos para esta materia.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        FETCH NEXT FROM cur INTO @cod_carrera, @cod_materia, @nro_alumno, @nota_aprobacion, @cant_max_aplazos;
    END;

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

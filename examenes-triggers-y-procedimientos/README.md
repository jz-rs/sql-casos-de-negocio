# Control de exámenes: triggers y procedimientos almacenados

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white&style=flat-square)
![T-SQL](https://img.shields.io/badge/T--SQL-4D4D4D?style=flat-square)
![Triggers](https://img.shields.io/badge/Triggers-con%20cursor-6A1B9A?style=flat-square)

## El problema

Una institución educativa sistematiza sus actividades académicas en una base de datos. Registra:

* **Alumnos**, con sus datos personales.
* **Carreras**, cada una con la cantidad máxima de aplazos por materia y los años que dura la regularidad de un cursado.
* **Matrículas**: las carreras que cursa cada alumno y su año de ingreso.
* **Materias** de cada carrera, indicando si son obligatorias y si corresponden al trabajo final.
* **Cursados**: lo que cursó cada alumno en cada materia, el año y su situación final (regular o libre).
* **Exámenes finales**: la inscripción al examen, el cursado al que corresponde, el nro. de libro y acta donde se asentó la nota, y la nota (null si estuvo ausente).

Los alumnos solo pueden rendir materias que hayan cursado y no se permite el examen en condición libre. Había que resolver dos necesidades de negocio.

## 1. Limitar los aplazos

**Regla:** un alumno no puede inscribirse al examen de una materia para un cursado que ya tiene la cantidad máxima de aplazos.

**Cómo lo resolví:**

1. Armé una consulta que detecta las filas que no cumplen la regla (alumnos con más aplazos que el máximo de su carrera).
2. Determiné sobre qué operaciones tenía que programar triggers: la regla se puede violar al **insertar** y al **actualizar** exámenes, pero no al borrar.
3. Programé un trigger `AFTER INSERT` y otro `AFTER UPDATE` sobre `examenes`. Cada uno recorre con un **cursor** las filas afectadas, cuenta los aplazos de cada alumno y, si alcanza el máximo, lanza un error y deshace la transacción.

La regla se controla en cualquier momento en que pueda violarse, no solo cuando el alumno se inscribe.

## 2. Alumnos que pueden rendir

Un **procedimiento almacenado** recibe el código de una materia y una fecha de examen, y devuelve los alumnos que pueden rendirla ese día. Un alumno puede rendir si:

* está **regular** en la materia (cursado con `regular = 'S'`), tiene menos aplazos que el máximo de su carrera y la regularidad no está vencida (año de cursado + años de regularidad mayor al año del examen), y
* **no tiene la materia aprobada**.

Devuelve el número de alumno, el nombre y el año de cursado en estado regular.

## Contenido

```
01_modelo_y_datos.sql                       Tablas del modelo y datos de carga
02_triggers_aplazos.sql                     Consulta de control y triggers INSERT / UPDATE con cursor
03_procedimiento_alumnos_habilitados.sql    Procedimiento almacenado
```

Orden de ejecución: `01`, `02` y `03`.

## Técnicas usadas

Triggers `AFTER INSERT` y `AFTER UPDATE` · cursores · `RAISERROR` y `ROLLBACK` · procedimientos almacenados con parámetros · consultas con varios `JOIN`, subconsultas y funciones de agregación.

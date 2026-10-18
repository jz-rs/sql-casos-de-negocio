# SQL: casos de negocio

Tres casos de bases de datos relacionales que resolví con SQL: uno de **diseño**, uno de **migración de un modelo sin perder datos** y uno de **integridad con triggers y procedimientos almacenados**.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white&style=flat-square)
![T-SQL](https://img.shields.io/badge/T--SQL-4D4D4D?style=flat-square)
![Modelo relacional](https://img.shields.io/badge/Modelo-relacional-1565C0?style=flat-square)

| Caso | Problema de negocio | Qué resolví |
|---|---|---|
| [Foro de posteos](foro-diseno-de-base-de-datos) | Diseñar la base de datos de un foro con posteos, likes, temas y seguidores | Modelo entidad-relación con sus entidades, atributos y relaciones |
| [Electrodomésticos](electrodomesticos-migracion-de-modelo) | Un fabricante necesita registrar los traspasos de propiedad de un producto | Migré el modelo a una tabla de ventas sin perder datos, y armé un reporte de partes por año |
| [Exámenes finales](examenes-triggers-y-procedimientos) | Una institución educativa necesita controlar quién puede rendir | Triggers con cursor para limitar aplazos y un procedimiento almacenado de alumnos habilitados |

Cada carpeta tiene su propio README con el problema, la solución y el orden de ejecución.

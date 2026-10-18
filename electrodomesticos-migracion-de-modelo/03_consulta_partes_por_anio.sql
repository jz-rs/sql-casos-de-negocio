 /*
Consulta basada en el modelo original que muestra por año la cantidad de partes que se han utilizado para fabricar
   los diferentes electrodomésticos.

   Resultado esperado:

   ----------------------------------------------------------------------------------------------------------
   año			cod_parte		nom_parte						cantidad
   ----------------------------------------------------------------------------------------------------------
   XXXX			XXX				XXXXXXXXXXXXXXXXXXXXXXXXXXXXX		XXX
   XXXX			XXX				XXXXXXXXXXXXXXXXXXXXXXXXXXXXX		XXX

  
*/

/* Consulta para obtener la cantidad de partes utilizadas para fabricar electrodomésticos por año */

SELECT 
    YEAR(e.fecha_fabricacion) AS año,
    pm.cod_parte_electrodomestico AS cod_parte,
    pe.nom_parte_electrodomestico AS nom_parte,
    SUM(pm.cantidad) AS cantidad
FROM 
    dbo.electrodomesticos e
JOIN 
    dbo.modelos_electrodomesticos me ON e.cod_modelo_electrodomestico = me.cod_modelo_electrodomestico
JOIN 
    dbo.partes_modelos pm ON me.cod_modelo_electrodomestico = pm.cod_modelo_electrodomestico
JOIN 
    dbo.partes_electrodomesticos pe ON pm.cod_parte_electrodomestico = pe.cod_parte_electrodomestico
GROUP BY 
    YEAR(e.fecha_fabricacion),
    pm.cod_parte_electrodomestico,
    pe.nom_parte_electrodomestico
ORDER BY 
    año, cod_parte;

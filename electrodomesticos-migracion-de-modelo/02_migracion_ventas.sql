/*

Para tener un control más riguroso de los clientes que realizan reclamos, solamente se reciben reclamos cuando el 
   cliente está registrado como propietario del electrodoméstico.
   Por lo tanto, si un cliente transfiere el electrodoméstico a otro debe informar ese traspaso para que el nuevo cliente
   pueda realizar un reclamo.
   Se requiere realizar un cambio en el modelo de datos e implementarlo en la base de datos para poder registrar estas 
   transferencias de propiedad.
   Las mismas serán consideradas como "ventas" con lo cual un producto podrá tener varias "ventas".
   El modelo debe permitir determinar quien es el cliente que puede realizar un reclamo según la fecha del mismo. 
   
   Objetivo: modificar el modelo e implementar los cambios migrando los datos actuales a la nueva implementación sin 
   pérdida de información.



   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   Tener en cuenta:

   No puedo borrar todo para las nuevas modificaciones porque pierdo toda la información de la base de datos que tengo actualmente.

   Debo hacer un paso a paso para que me permita llegar a la nueva estructura de tablas que permita almacenar tanto lo nuevo como lo viejo.

   No se puede modificar el script original, es decir, ir a los datos que tengo en la base y empezar a borrar información para que se adapte a los requerimientos.

   También hay que tener en cuenta que el orden de las operaciones puede ser crítico, 
   si quiero eliminar una columna, no la puedo eliminar si tiene una regla de integridad, 
   primero debo eliminar la regla de integridad y después eliminar la columna 

   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PASOS:
   Paso 1: Creo la tabla ventas que registra cada venta de un electrodoméstico

   Los atributos de esta nueva tabla van hacer: 

	* nro_venta: Número de venta (identificador único).
	* nro_serie: Número de serie del electrodoméstico (referencia a electrodomesticos).
	* nro_cliente: Número del cliente que compra el electrodoméstico (referencia a clientes).
	* fecha_venta: Fecha de la venta.

   Paso 2: Migrar los datos a la nueva tabla recien creada
  
	* Se copian los datos de ventas existentes desde la tabla electrodomesticos a la nueva tabla ventas.

	* Solo se migran los registros donde nro_cliente y fecha_venta_cliente no son nulos.

   Paso 3: Eliminar las reglas de integridad de la tabla electrodomesticos, para poder eliminar despues esas columnas y no tener informacion redundante en la base de datos.

   Paso 4: Posteriormente eliminamos las columnas "nro_cliente" y "fecha_venta_cliente" de la tabla electrodomesticos.

   Paso 5: Se agrega una nueva restricción de verificación para asegurar que los campos "nro_comercio" y "fecha_venta_comercio" se manejen correctamente.

   --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 */


/* Crear la tabla ventas */
CREATE TABLE dbo.ventas (
    nro_venta INTEGER IDENTITY(1,1) PRIMARY KEY,
    nro_serie VARCHAR(20) NOT NULL,
    nro_cliente INTEGER NOT NULL,
    fecha_venta DATE NOT NULL,
    FOREIGN KEY (nro_serie) REFERENCES dbo.electrodomesticos(nro_serie),
    FOREIGN KEY (nro_cliente) REFERENCES dbo.clientes(nro_cliente)
);
GO

/* Migrar datos a la nueva tabla ventas */
INSERT INTO dbo.ventas (nro_serie, nro_cliente, fecha_venta)
SELECT nro_serie, nro_cliente, fecha_venta_cliente
FROM dbo.electrodomesticos
WHERE nro_cliente IS NOT NULL AND fecha_venta_cliente IS NOT NULL;
GO

/* Eliminar restricciones de la tabla electrodomesticos */
ALTER TABLE dbo.electrodomesticos DROP CONSTRAINT FK__electrodomesticos__clientes__1;
ALTER TABLE dbo.electrodomesticos DROP CONSTRAINT CK__electrodomesticos__ventas;
GO

/* Eliminar columnas de la tabla electrodomesticos */
ALTER TABLE dbo.electrodomesticos DROP COLUMN nro_cliente;
ALTER TABLE dbo.electrodomesticos DROP COLUMN fecha_venta_cliente;
GO

/* Agregar nueva restricción de ventas a la tabla electrodomesticos */
ALTER TABLE dbo.electrodomesticos
ADD CONSTRAINT CK__electrodomesticos__ventas
CHECK (
    nro_comercio IS NULL AND fecha_venta_comercio IS NULL OR
    nro_comercio IS NOT NULL AND fecha_venta_comercio IS NOT NULL
);
GO

/* Verificar la migración de datos */
SELECT * FROM dbo.ventas;
GO

/* Verificar la tabla electrodomesticos */
SELECT * FROM dbo.electrodomesticos;
GO

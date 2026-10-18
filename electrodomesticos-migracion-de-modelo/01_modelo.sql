/* -----------------------------------------------------------------------------------------------------------------------------------
Una empresa que fabrica electrodomésticos desea mantener información acerca de los mismos, sus modelos, los comercios a los cuales 
se les vendió y los clientes que los han adquirido en esos comercios. Además se registran los reclamos que han tenido. 
Para esto decide implementar una base de datos relacional.

La información a almacenar en la misma es la siguiente:

­- La empresa produce diferentes tipos de electrodomésticos. Por ejemplo: heladeras, equipos de aire acondicionado, lavarropas, cocinas, hornos, etc. 
  Se identifican por un código interno único, nombre y clase de electrodoméstico (calefacción, refrigeración, etc.)

- De cada tipo de electrodoméstico se producen varios modelos que se identifican por un código único. Cada uno tiene diferentes prestaciones o características. 
  Se debe mantener información acerca de sus características y el tiempo de garantía medido en meses otorgado por la empresa.

- Se deben registrar las partes que componen los modelos con sus características. Una parte puede ser utilizada para varios 
  modelos. 
  Se debe indicar también, que cantidad de unidades de cada parte se utiliza en el armado de cada modelo. 

­- A medida que se van fabricando los electrodomésticos se deben ir registrando. 
  Cada electrodoméstico fabricado se identifica por un nro. de serie único. Se debe indicar el tipo de electrodoméstico, el modelo, la fecha de fabricación, 
  y si está vendido, el comercio y la fecha de venta al comercio.

- Cuando el comercio lo vende registra en nuestra base de datos los datos del cliente y la fecha de venta al mismo.

- De los comercios se requiere conocer su nombre, dirección y teléfonos. 

- De los clientes se requiere conocer su nombre y DNI.

­- Se deben registrar también las fallas de los electrodomésticos informadas por los clientes. En particular se necesita conocer el electrodoméstico, 
  el cliente, la fecha de registro de la falla, una descripción de la misma y las partes reemplazadas.

La base de datos implementada es la siguiente:
*/

drop table dbo.partes_reemplazadas
drop table dbo.reclamos
drop table dbo.electrodomesticos
drop table dbo.clientes
drop table dbo.comercios
drop table dbo.partes_modelos
drop table dbo.partes_electrodomesticos
drop table dbo.modelos_electrodomesticos
drop table dbo.tipos_electrodomesticos
drop table dbo.clases_electrodomesticos

create table dbo.clases_electrodomesticos
(
 cod_clase_electrodomestico		varchar(3)	not null,
 nom_clase_electrodomestico		varchar(40)	not null,
 constraint PK__clases_electrodomesticos 
            primary key (cod_clase_electrodomestico)
)

create table dbo.tipos_electrodomesticos
(
 cod_tipo_electrodomestico		varchar(3)	not null,
 nom_tipo_electrodomestico		varchar(40)	not null,
 cod_clase_electrodomestico		varchar(3)	not null,
 constraint PK__tipos_electrodomesticos 
            primary key (cod_tipo_electrodomestico),
 constraint FK__tipos_electrodomesticos__clases_electrodomesticos__1 
            foreign key (cod_clase_electrodomestico) references dbo.clases_electrodomesticos
)

create table dbo.modelos_electrodomesticos
(
 cod_modelo_electrodomestico	varchar(10)		not null,
 cod_tipo_electrodomestico		varchar(3)		not null,
 caracteristicas				varchar(255)	not null,
 meses_garantia					smallint		not null,
 constraint PK__modelos_electrodomesticos 
            primary key (cod_modelo_electrodomestico),
 constraint FK__modelos_electrodomesticos__tipos_electrodomesticos__1 
            foreign key (cod_tipo_electrodomestico) references dbo.tipos_electrodomesticos,
 constraint CK__modelos_electrodomesticos__meses_garantia
            check (meses_garantia > 0)
)

create table dbo.partes_electrodomesticos
(
 cod_parte_electrodomestico		varchar(10)		not null,
 nom_parte_electrodomestico		varchar(255)	not null,
 caracteristicas				varchar(255)	not null,
 constraint PK__partes_electrodomesticos 
            primary key (cod_parte_electrodomestico)
)

create table dbo.partes_modelos
(
 cod_modelo_electrodomestico	varchar(10)		not null,
 cod_parte_electrodomestico		varchar(10)		not null,
 cantidad						tinyint			not null,
 constraint PK__partes_modelos 
            primary key (cod_modelo_electrodomestico, cod_parte_electrodomestico),
 constraint FK__partes_modelos__modelos_electrodomesticos__1
            foreign key (cod_modelo_electrodomestico) references dbo.modelos_electrodomesticos,
 constraint FK__partes_modelos__partes_electrodomesticos__1
            foreign key (cod_parte_electrodomestico) references dbo.partes_electrodomesticos,
 constraint CK__partes_modelos__cantidad
            check (cantidad > 0)
)

create table dbo.comercios
(
 nro_comercio					smallint		not null,
 nom_comercio					varchar(40)		not null,
 dir_comercio					varchar(255)	not null,
 tel_comercio					varchar(40)		not null,
 constraint PK__comercios
            primary key (nro_comercio)
)

create table dbo.clientes
(
 nro_cliente					integer			not null,
 nom_cliente					varchar(40)		not null,
 dni_cliente					integer			not null,
 constraint PK__clientes
            primary key (nro_cliente),
 constraint UK__clientes__1
			unique (dni_cliente)
)

create table dbo.electrodomesticos
(
 nro_serie						varchar(20)		not null,
 cod_modelo_electrodomestico	varchar(10)		not null,
 fecha_fabricacion				date			not null,
 nro_comercio					smallint		null,
 fecha_venta_comercio			date			null,
 nro_cliente					integer			null,
 fecha_venta_cliente			date			null,
 constraint PK__electrodomesticos 
            primary key (nro_serie),
 constraint FK__electrodomesticos__modelos_electrodomesticos__1
            foreign key (cod_modelo_electrodomestico) references dbo.modelos_electrodomesticos,
 constraint FK__electrodomesticos__comercios__1                                                /*ACA*/
            foreign key (nro_comercio) references dbo.comercios,
 constraint FK__electrodomesticos__clientes__1													/*ACA*/
            foreign key (nro_cliente) references dbo.clientes,
 constraint CK__electrodomesticos__ventas
            check (nro_comercio is null     and fecha_venta_comercio is null     and nro_cliente is null     and fecha_venta_cliente is null or
			       nro_comercio is not null and fecha_venta_comercio is not null and nro_cliente is null     and fecha_venta_cliente is null or
			       nro_comercio is not null and fecha_venta_comercio is not null and nro_cliente is not null and fecha_venta_cliente is not null)
)

create table dbo.reclamos
(
 nro_reclamo					integer			not null,
 nro_serie						varchar(20)		not null,
 fecha_reclamo					date			not null,
 observaciones					varchar(255)	not null,
 constraint PK__reclamos
			primary key (nro_reclamo),
 constraint FK__reclamos__electrodomesticos__1
			foreign key (nro_serie) references dbo.electrodomesticos
)

create table dbo.partes_reemplazadas
(
 nro_reclamo					integer			not null,
 cod_parte_electrodomestico		varchar(10)		not null,
 cantidad						tinyint			not null,
 constraint PK__partes_reemplazadas
            primary key (nro_reclamo, cod_parte_electrodomestico),
 constraint FK__partes_reemplazadas__reclamos__1
			foreign key (nro_reclamo) references dbo.reclamos,
 constraint FK__partes_reemplazadas__partes_electrodomesticos__1
			foreign key (cod_parte_electrodomestico) references dbo.partes_electrodomesticos
)

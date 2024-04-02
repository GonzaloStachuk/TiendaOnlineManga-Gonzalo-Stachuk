CREATE DATABASE TiendaOnlineManga;
USE TiendaOnlineManga;




-- Tabla de Usuarios
CREATE TABLE Usuario (
    UsuarioID INT NOT NULL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(255) UNIQUE NOT NULL,
    Correo VARCHAR(100) UNIQUE NOT NULL
);
-- Tabla de Productos
CREATE TABLE Producto (
    ProductoID INT NOT NULL PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(255) NOT NULL,
    Precio DECIMAL(10, 2)  -- Usamos DECIMAL para manejar precios con precisión decimal
);

-- Tabla de Pedidos
CREATE TABLE Pedido (
    PedidoID INT NOT NULL PRIMARY KEY,
    UsuarioID INT,  -- Clave foránea que hace referencia al Usuario que realizó el pedido
    Fecha DATE,
    Estado VARCHAR(50),  
    Direccion VARCHAR(255),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID)  -- Definición de la clave foránea
);

-- Tabla de Productos en Pedido (Tabla intermedia)
CREATE TABLE Producto_en_Pedido (
    PedidoID INT,
    ProductoID INT,
    Cantidad INT,
    PRIMARY KEY (PedidoID, ProductoID),  -- Clave primaria compuesta por PedidoID y ProductoID
    FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID),  -- Clave foránea que hace referencia al Pedido
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID)  -- Clave foránea que hace referencia al Producto
);

CREATE TABLE Venta (
    VentaID INT AUTO_INCREMENT PRIMARY KEY,
    UsuarioID INT,
    ProductoID INT,
    FechaVenta DATE,
    Cantidad INT,
    PrecioUnitario DECIMAL(10, 2),
    Total DECIMAL(10, 2),
    FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID),
    FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID)
);

-- Definición de la clave foránea en la tabla Pedido
ALTER TABLE Pedido
ADD CONSTRAINT FK_Pedido_Usuario
FOREIGN KEY (UsuarioID) REFERENCES Usuario(UsuarioID);

-- Definición de la clave foránea en la tabla Producto_en_Pedido
ALTER TABLE Producto_en_Pedido
ADD CONSTRAINT FK_ProductoEnPedido_Pedido
FOREIGN KEY (PedidoID) REFERENCES Pedido(PedidoID),
ADD CONSTRAINT FK_ProductoEnPedido_Producto
FOREIGN KEY (ProductoID) REFERENCES Producto(ProductoID);

SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM
    information_schema.TABLE_CONSTRAINTS
    LEFT JOIN information_schema.KEY_COLUMN_USAGE 
    USING (CONSTRAINT_NAME, TABLE_SCHEMA, TABLE_NAME)
WHERE
    TABLE_SCHEMA = 'TiendaOnlineManga';

SELECT * FROM Usuario
ORDER BY Nombre ASC;
    
  -- INFO  Vista: ResumenVenta 
  -- Descripción: Esta vista proporciona un resumen de las ventas realizadas, incluyendo el nombre del usuario, el nombre del producto, la fecha de venta, la cantidad vendida y el total de la venta.
-- Tablas involucradas: Venta, Usuario, Producto

    CREATE VIEW ResumenVenta AS
SELECT 
    u.Nombre AS NombreUsuario,
    p.Nombre AS NombreProducto,
    v.FechaVenta,
    v.Cantidad,
    v.Total
FROM 
    Venta v
INNER JOIN 
    Usuario u ON v.UsuarioID = u.UsuarioID
INNER JOIN 
    Producto p ON v.ProductoID = p.ProductoID;
    
    SELECT * FROM ResumenVenta;
    SELECT *
FROM ResumenVenta
WHERE FechaVenta BETWEEN '2024-03-01' AND '2024-03-15';
-- Esta consulta es para saber las ventas realizadas en un rango de fechas específico.

SELECT NombreProducto, SUM(Cantidad) AS TotalVendido
FROM ResumenVenta
GROUP BY NombreProducto;
-- Esta consulta es para saber el total de ventas realizadas para cada producto.
  
  -- Vista: TopProductos
-- Descripción: Esta vista muestra los productos más vendidos, ordenados por la cantidad total vendida.
-- Tablas involucradas: Venta, Producto
    CREATE VIEW TopProductos AS
SELECT 
    p.ProductoID,
    p.Nombre AS NombreProducto,
    SUM(v.Cantidad) AS TotalVendido
FROM 
    Venta v
INNER JOIN 
    Producto p ON v.ProductoID = p.ProductoID
GROUP BY 
    p.ProductoID
ORDER BY 
    TotalVendido DESC;
    
    SELECT * FROM TopProductos;
    
    SELECT NombreProducto, TotalVendido
FROM TopProductos;
-- Esta consulta muestra el total de unidades vendidas para cada producto.

    

-- Vista: VentasPorUsuario
-- Descripción: Esta vista muestra un resumen de las ventas realizadas por cada usuario, incluyendo el nombre del usuario, la cantidad total de ventas realizadas y el monto total vendido por ese usuario.
-- Tablas involucradas: Venta, Usuario
    CREATE VIEW VentasPorUsuario AS
SELECT 
    u.Nombre AS NombreUsuario,
    COUNT(v.VentaID) AS TotalVentas,
    SUM(v.Total) AS TotalVendido
FROM 
    Venta v
INNER JOIN 
    Usuario u ON v.UsuarioID = u.UsuarioID
GROUP BY 
    u.UsuarioID;
    
    SELECT * FROM VentasPorUsuario;
SELECT NombreUsuario, TotalVentas, TotalVendido
FROM VentasPorUsuario
ORDER BY TotalVentas DESC;
-- Esta consulta es para ver una lista de usuarios ordenados según la cantidad total de ventas realizadas (TotalVentas), junto con el monto total vendido (TotalVendido). Esto permite identificar rápidamente los usuarios que han realizado más ventas en tu tienda en línea.

DELIMITER //

CREATE FUNCTION TotalVentasPorProducto(nombre_producto VARCHAR(255))
RETURNS DECIMAL(10, 2) DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10, 2);
    
    SELECT SUM(Total) INTO total
    FROM ResumenVenta
    WHERE NombreProducto = nombre_producto;
    
    RETURN total;
END//

DELIMITER ;

-- Esta función TotalVentasPorProducto toma el nombre de un producto como argumento y devuelve el total de ventas de ese producto. También utiliza la vista ResumenVenta.


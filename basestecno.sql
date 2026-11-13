-- ============================================================
-- BASE DE DATOS TECHNOSTORE
-- Proyecto: Sistema de gestión de ventas e inventario
-- ============================================================

DROP DATABASE IF EXISTS technostore;

CREATE DATABASE technostore
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE technostore;


-- ============================================================
-- 1. TABLA CLIENTE
-- ============================================================

CREATE TABLE cliente (
    doc_cliente VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(150) NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (doc_cliente)
) ENGINE=InnoDB;


-- ============================================================
-- 2. TABLA PROVEEDOR
-- ============================================================

CREATE TABLE proveedor (
    id_proveedor INT NOT NULL AUTO_INCREMENT,
    empresa VARCHAR(100) NOT NULL,
    contacto VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,

    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
) ENGINE=InnoDB;


-- ============================================================
-- 3. TABLA VENDEDOR
-- ============================================================

CREATE TABLE vendedor (
    id_vendedor INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    cargo VARCHAR(50) NOT NULL,

    CONSTRAINT pk_vendedor PRIMARY KEY (id_vendedor)
) ENGINE=InnoDB;


-- ============================================================
-- 4. TABLA PRODUCTOS
-- ============================================================

CREATE TABLE productos (
    id_producto INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(12,2) NOT NULL,
    stock INT NOT NULL,

    CONSTRAINT pk_productos PRIMARY KEY (id_producto),
    CONSTRAINT ck_productos_precio CHECK (precio > 0),
    CONSTRAINT ck_productos_stock CHECK (stock >= 0)
) ENGINE=InnoDB;


-- ============================================================
-- 5. TABLA PRODUCTO_PROVEEDOR
-- Tabla intermedia entre PRODUCTOS y PROVEEDOR
-- ============================================================

CREATE TABLE producto_proveedor (
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,

    CONSTRAINT pk_producto_proveedor PRIMARY KEY (id_producto, id_proveedor),

    CONSTRAINT fk_producto_proveedor_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_producto_proveedor_proveedor
        FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


-- ============================================================
-- 6. TABLA VENTAS
-- ============================================================

CREATE TABLE ventas (
    id_venta INT NOT NULL AUTO_INCREMENT,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_vendedor INT NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    metodo_de_pago VARCHAR(30) NOT NULL,
    doc_cliente VARCHAR(20) NOT NULL,

    CONSTRAINT pk_ventas PRIMARY KEY (id_venta),

    CONSTRAINT fk_ventas_vendedor
        FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_ventas_cliente
        FOREIGN KEY (doc_cliente) REFERENCES cliente(doc_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_ventas_total CHECK (total >= 0)
) ENGINE=InnoDB;


-- ============================================================
-- 7. TABLA DETALLE_VENTA
-- Tabla intermedia entre VENTAS y PRODUCTOS
-- ============================================================

CREATE TABLE detalle_venta (
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,

    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),

    CONSTRAINT fk_detalle_venta_venta
        FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
        ON DELETE CASCADE ON UPDATE CASCADE,

    CONSTRAINT fk_detalle_venta_producto
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio CHECK (precio_unitario > 0)
) ENGINE=InnoDB;


-- ============================================================
-- INSERTAR DATOS DE EJEMPLO
-- ============================================================

-- CLIENTES
INSERT INTO cliente (doc_cliente, nombre, telefono, direccion) VALUES
('1001234567', 'Andrea Martinez', '3001234567', 'Calle 10 # 20-30'),
('1002345678', 'Carlos Rodriguez', '3012345678', 'Carrera 15 # 45-20'),
('1003456789', 'Laura Gomez', '3023456789', 'Calle 80 # 12-15'),
('1004567890', 'Juan Perez', '3034567890', 'Carrera 7 # 60-10');

-- PROVEEDORES
INSERT INTO proveedor (empresa, contacto, direccion) VALUES
('TechDistribuciones S.A.S.', 'Miguel Torres', 'Calle 20 # 15-40'),
('CompuMarket S.A.S.', 'Daniel Rojas', 'Carrera 30 # 25-60'),
('Digital World S.A.S.', 'Sofia Hernandez', 'Calle 50 # 18-25');

-- VENDEDORES
INSERT INTO vendedor (nombre, telefono, cargo) VALUES
('Camila Sanchez', '3101112233', 'Vendedor'),
('Sebastian Lopez', '3112223344', 'Vendedor'),
('Valentina Castro', '3123334455', 'Administrador');

-- PRODUCTOS
INSERT INTO productos (nombre, precio, stock) VALUES
('Laptop Lenovo IdeaPad', 2500000.00, 10),
('Mouse Logitech M185', 65000.00, 25),
('Teclado Redragon', 150000.00, 15),
('Monitor Samsung 24 pulgadas', 850000.00, 8),
('Audifonos HyperX', 280000.00, 12),
('Disco SSD Kingston 1TB', 320000.00, 20);

-- PRODUCTO_PROVEEDOR
INSERT INTO producto_proveedor (id_producto, id_proveedor) VALUES
(1, 1),
(1, 2),
(2, 2),
(3, 2),
(4, 1),
(4, 3),
(5, 3),
(6, 1);

-- VENTAS (Totales cuadrados con los precios reales del catálogo)
INSERT INTO ventas (fecha, id_vendedor, total, metodo_de_pago, doc_cliente) VALUES
('2026-11-01 10:30:00', 1, 2565000.00, 'Tarjeta', '1001234567'),
('2026-11-01 14:20:00', 2, 215000.00, 'Efectivo', '1002345678'),
('2026-11-02 09:15:00', 1, 1170000.00, 'Transferencia', '1003456789'),
('2026-11-02 16:45:00', 3, 730000.00, 'Tarjeta', '1004567890');

-- DETALLE_VENTA (El subtotal se calcula automáticamente)
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 2500000.00),
(1, 2, 1, 65000.00),

(2, 3, 1, 150000.00),
(2, 2, 1, 65000.00),

(3, 4, 1, 850000.00),
(3, 6, 1, 320000.00),

(4, 5, 1, 280000.00),
(4, 2, 2, 65000.00),
(4, 6, 1, 320000.00);


-- ============================================================
-- CONSULTAS DE VERIFICACIÓN
-- ============================================================

SHOW TABLES;

SELECT * FROM cliente;
SELECT * FROM proveedor;
SELECT * FROM vendedor;
SELECT * FROM productos;
SELECT * FROM producto_proveedor;
SELECT * FROM ventas;
SELECT * FROM detalle_venta;
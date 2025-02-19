DROP DATABASE IF EXISTS RodaMorzar;
CREATE DATABASE RodaMorzar;
USE RodaMorzar;

CREATE TABLE usuarios (
  id bigint NOT NULL AUTO_INCREMENT,
  nombre varchar(100) NOT NULL,
  contraseña varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rutas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    distancia FLOAT,
    dificultad ENUM('facil', 'media', 'dificil'),
    tiempo_estimado INT,
    es_predefinida BOOLEAN DEFAULT FALSE,
    creador_id bigint,  -- Cambiado a bigint para coincidir con usuarios.id
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creador_id) REFERENCES usuarios(id)
);

CREATE TABLE puntos_ruta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT,
    orden INT,
    latitud DECIMAL(10, 8),
    longitud DECIMAL(11, 8),
    tipo ENUM('inicio', 'punto', 'parada', 'fin'),
    nombre VARCHAR(100),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

CREATE TABLE rutas_favoritas (
    usuario_id bigint,  -- Cambiado a bigint para coincidir con usuarios.id
    ruta_id INT,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, ruta_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

INSERT INTO rutas (nombre, descripcion, distancia, dificultad, tiempo_estimado, es_predefinida)
VALUES 
('Ruta del Rio', 'Un recorrido scenic junto al río', 5.2, 'facil', 45, TRUE),
('Ruta Histórica', 'Visita los monumentos más importantes', 3.8, 'facil', 30, TRUE),
('Ruta Gastronómica', 'Descubre los mejores restaurantes', 4.5, 'media', 40, TRUE);

-- Añadir puntos para cada ruta
INSERT INTO puntos_ruta (ruta_id, orden, latitud, longitud, tipo, nombre)
VALUES 
(1, 0, 39.4699, -0.3763, 'inicio', 'Inicio Ruta Rio'),
(1, 1, 39.4701, -0.3768, 'parada', 'Mirador Rio'),
(1, 2, 39.4705, -0.3770, 'fin', 'Fin Ruta Rio');
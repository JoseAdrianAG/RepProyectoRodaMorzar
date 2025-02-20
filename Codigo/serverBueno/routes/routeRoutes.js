// routes/routeRoutes.js
import express from 'express';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { pool } from '../models/db.js';

const router = express.Router();

// Obtener todas las rutas (predefinidas y personales del usuario)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id; // Ahora podemos acceder al ID del usuario
        const [rows] = await pool.query(
            `SELECT r.*, u.nombre as creador_nombre,
            CASE WHEN rf.ruta_id IS NOT NULL THEN TRUE ELSE FALSE END as es_favorita
            FROM rutas r
            LEFT JOIN usuarios u ON r.creador_id = u.id
            LEFT JOIN rutas_favoritas rf ON r.id = rf.ruta_id AND rf.usuario_id = ?
            WHERE r.es_predefinida = TRUE OR r.creador_id = ?`,
            [userId, userId]
        );
        res.json(rows);
    } catch (error) {
        console.error('Error al obtener rutas:', error);
        res.status(500).json({ error: 'Error al obtener las rutas' });
    }
});

// Crear una nueva ruta
router.post('/', authenticateToken, async (req, res) => {
    const { nombre, descripcion, puntos, distancia, dificultad, tiempo_estimado } = req.body;
    
    try {
        const connection = await pool.getConnection();
        await connection.beginTransaction();

        try {
            // Insertar la ruta
            const [routeResult] = await connection.query(
                'INSERT INTO rutas (nombre, descripcion, distancia, dificultad, tiempo_estimado, creador_id) VALUES (?, ?, ?, ?, ?, ?)',
                [nombre, descripcion, distancia, dificultad, tiempo_estimado, req.user.id]
            );

            // Insertar los puntos de la ruta
            for (let i = 0; i < puntos.length; i++) {
                await connection.query(
                    'INSERT INTO puntos_ruta (ruta_id, orden, latitud, longitud, tipo, nombre) VALUES (?, ?, ?, ?, ?, ?)',
                    [routeResult.insertId, i, puntos[i].lat, puntos[i].lng, puntos[i].tipo, puntos[i].nombre]
                );
            }

            await connection.commit();
            res.status(201).json({ id: routeResult.insertId });
        } catch (error) {
            await connection.rollback();
            throw error;
        } finally {
            connection.release();
        }
    } catch (error) {
        res.status(500).json({ error: 'Error al crear la ruta' });
    }
});

// Marcar/Desmarcar ruta como favorita
router.post('/:rutaId/favorito', authenticateToken, async (req, res) => {
    const { rutaId } = req.params;
    const { agregar } = req.body; // true para agregar, false para quitar

    try {
        if (agregar) {
            await pool.query(
                'INSERT INTO rutas_favoritas (usuario_id, ruta_id) VALUES (?, ?)',
                [req.user.id, rutaId]
            );
        } else {
            await pool.query(
                'DELETE FROM rutas_favoritas WHERE usuario_id = ? AND ruta_id = ?',
                [req.user.id, rutaId]
            );
        }
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: 'Error al actualizar favoritos' });
    }
});

router.get('/:rutaId/details', authenticateToken, async (req, res) => {
    const { rutaId } = req.params;
    
    try {
        // Obtener los puntos de la ruta
        const [points] = await pool.query(
            'SELECT latitud, longitud, tipo, nombre FROM puntos_ruta WHERE ruta_id = ? ORDER BY orden',
            [rutaId]
        );

        // Obtener los bares cercanos a la ruta
        // Esto es un ejemplo simplificado. En una implementación real,
        // deberías usar cálculos geoespaciales para encontrar bares realmente cercanos
        const [bars] = await pool.query(`
            SELECT b.id, b.nombre, b.direccion, b.latitud, b.longitud, 
                   b.horario, b.descripcion
            FROM bares b
            WHERE ST_Distance_Sphere(
                POINT(b.longitud, b.latitud),
                POINT(
                    (SELECT AVG(longitud) FROM puntos_ruta WHERE ruta_id = ?),
                    (SELECT AVG(latitud) FROM puntos_ruta WHERE ruta_id = ?)
                )
            ) <= 1000  -- buscar bares en un radio de 1km
        `, [rutaId, rutaId]);

        res.json({
            points,
            bars
        });
    } catch (error) {
        console.error('Error al obtener detalles de la ruta:', error);
        res.status(500).json({ error: 'Error al obtener los detalles de la ruta' });
    }
});

export default router;
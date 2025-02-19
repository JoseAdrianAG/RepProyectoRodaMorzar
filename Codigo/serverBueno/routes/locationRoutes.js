import express from 'express';
import fetch from 'node-fetch';

const router = express.Router();

router.get('/search', async (req, res) => {
    const { query } = req.query;
    if (!query) {
        return res.status(400).json({ error: 'Se requiere un término de búsqueda' });
    }

    try {
        // Usar Nominatim API para geocodificación
        const response = await fetch(
            `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}`
        );
        const data = await response.json();

        // Transformar los resultados
        const locations = data.map(item => ({
            name: item.display_name,
            lat: parseFloat(item.lat),
            lon: parseFloat(item.lon),
            type: item.type
        }));

        res.json(locations);
    } catch (error) {
        res.status(500).json({ error: 'Error al buscar ubicación' });
    }
});

export default router;
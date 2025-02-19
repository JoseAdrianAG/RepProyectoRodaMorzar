import express from 'express';
import { register, login, getProfile } from '../controllers/authController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/profile', authenticateToken, getProfile);  // Nueva ruta para el perfil
router.get('/protected', authenticateToken, (req, res) => {
    res.send({ message: `Benvingut, ${req.user.username}!` });
});

export default router;
import jwt from 'jsonwebtoken';
import { registerUser, authenticateUser } from '../models/users.js';
import dotenv from 'dotenv';

dotenv.config();
const SECRET_KEY = process.env.SECRET_KEY;

// Registre d'usuari
export const register = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }
  const newUser = await registerUser(username, password);
  res.status(201).send(newUser);
};

// Login d'usuari
export const login = async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).send({ error: 'Nom d\'usuari i contrasenya requerits' });
  }

  const user = await authenticateUser(username, password);
  if (!user) {
    return res.status(401).send({ error: 'Credencials incorrectes' });
  }

  // Incluir tanto username como id en el token
  const token = jwt.sign({ 
    username: user.username,
    id: user.id 
  }, SECRET_KEY, { expiresIn: '1h' });
  
  res.send({ token });
};

export const getProfile = async (req, res) => {
  try {
      // Aquí puedes obtener más datos del usuario si los necesitas
      res.json({
          username: req.user.username,
          message: `Benvingut, ${req.user.username}!`
      });
  } catch (err) {
      res.status(500).send({ error: 'Error al obtener el perfil' });
  }
};
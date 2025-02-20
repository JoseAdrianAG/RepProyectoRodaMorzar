import bcrypt
import mysql.connector
from PySide6.QtWidgets import QApplication, QMainWindow, QTableWidget, QTableWidgetItem, QVBoxLayout, QWidget, QPushButton, QHeaderView, QDialog, QMessageBox, QInputDialog
from PySide6.QtGui import QAction
import sys
import os
from PySide6.QtUiTools import QUiLoader


class MySQLDatabase:
    def __init__(self, host="localhost", user="root", password="root", database="RodaMorzar", port=3307):
        self.config = {
            'host': host,
            'user': user,
            'password': password,
            'database': database,
            'port': port
        }
        self.connect()

    def connect(self):
        try:
            self.connection = mysql.connector.connect(**self.config)
            self.cursor = self.connection.cursor(dictionary=True)
            print("Conexión a MySQL establecida correctamente")
        except mysql.connector.Error as err:
            print(f"Error de conexión: {err}")
            raise

    def add_user(self, name, password):
        """Inserta un nuevo usuario en la base de datos MySQL con la contraseña encriptada"""
        try:
            hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            query = "INSERT INTO usuarios (nombre, contraseña) VALUES (%s, %s)"
            self.cursor.execute(query, (name, hashed_password))
            self.connection.commit()
            print("Usuario agregado exitosamente.")
        except mysql.connector.Error as err:
            print(f"Error al insertar usuario: {err}")

    def get_users(self):
        """Obtiene todos los usuarios de la base de datos"""
        try:
            self.cursor.execute("SELECT id, nombre, contraseña FROM usuarios")
            users = self.cursor.fetchall()
            return users
        except mysql.connector.Error as err:
            print(f"Error al obtener usuarios: {err}")
            return []

    def update_user(self, user_id, name, password):
        """Actualiza un usuario existente con contraseña encriptada"""
        try:
            hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            query = "UPDATE usuarios SET nombre = %s, contraseña = %s WHERE id = %s"
            self.cursor.execute(query, (name, hashed_password, user_id))
            self.connection.commit()
            print("Usuario actualizado correctamente.")
        except mysql.connector.Error as err:
            print(f"Error al actualizar usuario: {err}")

    def delete_user(self, user_id):
        """Elimina un usuario de la base de datos"""
        try:
            query = "DELETE FROM usuarios WHERE id = %s"
            self.cursor.execute(query, (user_id,))
            self.connection.commit()
            print("Usuario eliminado correctamente.")
        except mysql.connector.Error as err:
            print(f"Error al eliminar usuario: {err}")

    def get_routes(self):
        """Obtiene todas las rutas disponibles"""
        try:
            query = "SELECT id, nombre FROM rutas"
            self.cursor.execute(query)
            routes = self.cursor.fetchall()
            return routes
        except mysql.connector.Error as err:
            print(f"Error al obtener rutas: {err}")
            return []

    def add_favorite_route(self, user_id, ruta_id):
        """Añadir una ruta a los favoritos de un usuario"""
        try:
            query = "INSERT INTO rutas_favoritas (usuario_id, ruta_id) VALUES (%s, %s)"
            self.cursor.execute(query, (user_id, ruta_id))
            self.connection.commit()
            print("Ruta añadida a favoritos.")
        except mysql.connector.Error as err:
            print(f"Error al añadir ruta a favoritos: {err}")

    def delete_favorite_route(self, user_id, route_id):
        """Eliminar una ruta favorita de un usuario"""
        try:
            query = "DELETE FROM rutas_favoritas WHERE usuario_id = %s AND ruta_id = %s"
            self.cursor.execute(query, (user_id, route_id))
            self.connection.commit()
            print("Ruta favorita eliminada correctamente.")
        except mysql.connector.Error as err:
            print(f"Error al eliminar ruta favorita: {err}")


class UserApp(QMainWindow):
    def __init__(self):
        super().__init__()

        try:
            self.db = MySQLDatabase(
                host="localhost",  
                user="root",  
                password="root",  
                database="RodaMorzar",  
                port=3307
            )
        except Exception as e:
            QMessageBox.critical(self, "Error de conexión", f"No se pudo conectar a la base de datos MySQL: {str(e)}")
            sys.exit(1)

        self.setWindowTitle("Gestió d'Usuaris")
        self.setGeometry(100, 100, 600, 500)

        loader = QUiLoader()
        ui_path = os.path.join(os.path.dirname(__file__), "interfaz.ui")
        self.ui = loader.load(ui_path, None)

        barra_menus = self.menuBar()
        menu = barra_menus.addMenu("&Usuaris")
        accion = QAction("&Afegir", self)
        accion.triggered.connect(self.add_user)
        menu.addAction(accion)
        accion2 = QAction("&Cambiar el Nombre", self)
        accion2.triggered.connect(self.edit_user)
        menu.addAction(accion2)

        # Nueva acción para agregar ruta a favoritos
        accion3 = QAction("&Afegir Ruta a Favoritos", self)
        accion3.triggered.connect(self.add_favorite_route)
        menu.addAction(accion3)

        # Nueva acción para eliminar ruta favorita
        accion4 = QAction("&Eliminar Ruta Favorita", self)
        accion4.triggered.connect(self.delete_favorite_route)
        menu.addAction(accion4)

        # Widget principal
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        self.layout = QVBoxLayout()
        main_widget.setLayout(self.layout)

        # Botón para eliminar usuarios
        self.delete_button = QPushButton("Eliminar Usuari")
        self.delete_button.clicked.connect(self.delete_user)
        self.layout.addWidget(self.delete_button)

        # Tabla de usuarios
        self.table = self.create_table()
        self.layout.addWidget(self.table)

        self.load_users()

    def create_table(self):
        table = QTableWidget()
        table.setColumnCount(2)
        table.setHorizontalHeaderLabels(["Nom", "Contrasenya"])
        table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        table.setSelectionBehavior(QTableWidget.SelectRows)
        return table

    def load_users(self):
        """Carga los usuarios desde MySQL en la tabla."""
        self.table.setRowCount(0)
        users = self.db.get_users()
        for row_index, user in enumerate(users):
            self.table.insertRow(row_index)
            self.table.setItem(row_index, 0, QTableWidgetItem(user["nombre"]))
            self.table.setItem(row_index, 1, QTableWidgetItem(user["contraseña"]))  # Muestra la contraseña tal cual

    def add_user(self):
        """Añadir un usuario a la base de datos"""
        self.ui.lineEditNom.clear()
        self.ui.lineEditContrasenya.clear()

        # Asegurarse de que el campo de la contraseña no sea solo lectura
        self.ui.lineEditContrasenya.setReadOnly(False)

        if self.ui.exec() == QDialog.Accepted:
            name = self.ui.lineEditNom.text()
            password = self.ui.lineEditContrasenya.text()

            if name and password:
                self.db.add_user(name, password)
                self.load_users()

    def edit_user(self):
        """Editar un usuario en la base de datos"""
        selected_row = self.table.currentRow()
        if selected_row == -1:
            return

        user_id = self.db.get_users()[selected_row]["id"]
        current_name = self.table.item(selected_row, 0).text()
        current_password = self.table.item(selected_row, 1).text()

        # Mostrar el nombre en el campo de nombre
        self.ui.lineEditNom.setText(current_name)
        
        # Mostrar la contraseña en el campo de contraseña
        self.ui.lineEditContrasenya.setText(current_password)

        # Establecer el campo de contraseña como solo lectura
        self.ui.lineEditContrasenya.setReadOnly(True)

        # Mostrar el cuadro de diálogo
        if self.ui.exec() == QDialog.Accepted:
            new_name = self.ui.lineEditNom.text()
            
            if new_name:
                self.db.update_user(user_id, new_name, current_password)  # Solo actualiza el nombre

                self.load_users()

    def delete_user(self):
        """Eliminar un usuario de la base de datos"""
        selected_row = self.table.currentRow()
        if selected_row == -1:
            return

        user_id = self.db.get_users()[selected_row]["id"]

        # Eliminar las rutas favoritas asociadas al usuario
        try:
            query = "DELETE FROM rutas_favoritas WHERE usuario_id = %s"
            self.db.cursor.execute(query, (user_id,))
            self.db.connection.commit()
            print("Rutas favoritas eliminadas correctamente.")
        except mysql.connector.Error as err:
            print(f"Error al eliminar rutas favoritas: {err}")

        # Eliminar el usuario de la base de datos
        boton_pulsado = QMessageBox.warning(
            self, "Eliminar", "Estas seguro de que deseas eliminar este usuario?",
            buttons=QMessageBox.Yes | QMessageBox.No, defaultButton=QMessageBox.No
        )

        if boton_pulsado == QMessageBox.Yes:
            self.db.delete_user(user_id)
            self.load_users()

    def delete_favorite_route(self):
        """Eliminar una ruta favorita de un usuario"""
        selected_row = self.table.currentRow()
        if selected_row == -1:
            return
        
        # Obtener el ID del usuario seleccionado
        user_id = self.db.get_users()[selected_row]["id"]
        user_name = self.table.item(selected_row, 0).text()

        # Obtener las rutas favoritas del usuario seleccionado
        self.db.cursor.execute("SELECT rutas.id, rutas.nombre FROM rutas_favoritas JOIN rutas ON rutas_favoritas.ruta_id = rutas.id WHERE rutas_favoritas.usuario_id = %s", (user_id,))
        favorite_routes = self.db.cursor.fetchall()

        if not favorite_routes:
            QMessageBox.warning(self, "Sin rutas favoritas", "Este usuario no tiene rutas favoritas.")
            return

        # Crear un cuadro de diálogo para seleccionar una ruta favorita
        items = [f"{ruta['nombre']} (ID: {ruta['id']})" for ruta in favorite_routes]
        selected_route, ok = QInputDialog.getItem(self, "Seleccionar Ruta para Eliminar", "Elige una ruta para eliminar de favoritos:", items, 0, False)
        
        if ok and selected_route:
            # Obtener el ID de la ruta seleccionada
            selected_route_id = next(ruta['id'] for ruta in favorite_routes if f"{ruta['nombre']} (ID: {ruta['id']})" == selected_route)

            # Eliminar la ruta favorita
            try:
                self.db.delete_favorite_route(user_id, selected_route_id)
                QMessageBox.information(self, "Ruta Eliminada", f"La ruta '{selected_route}' ha sido eliminada de los favoritos.")
            except mysql.connector.Error as err:
                print(f"Error al eliminar ruta favorita: {err}")
                QMessageBox.critical(self, "Error", "No se pudo eliminar la ruta favorita.")

    def add_favorite_route(self):
        """Añadir una ruta a favoritos del usuario seleccionado"""
        selected_row = self.table.currentRow()
        if selected_row == -1:
            return
        
        user_id = self.db.get_users()[selected_row]["id"]
        user_name = self.table.item(selected_row, 0).text()

        # Obtener todas las rutas disponibles
        rutas = self.db.get_routes()

        # Crear un cuadro de diálogo para seleccionar una ruta
        items = [ruta['nombre'] for ruta in rutas]
        selected_route, ok = QInputDialog.getItem(self, "Seleccionar Ruta", "Elige una ruta para agregar a favoritos:", items, 0, False)
        
        if ok and selected_route:
            # Buscar la ruta seleccionada por nombre
            ruta_id = next(ruta['id'] for ruta in rutas if ruta['nombre'] == selected_route)
            
            # Agregar la ruta a favoritos
            self.db.add_favorite_route(user_id, ruta_id)
            QMessageBox.information(self, "Ruta Añadida", f"La ruta '{selected_route}' ha sido añadida a tus favoritos.")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = UserApp()
    window.show()
    sys.exit(app.exec())
# 🚜 Guía de Configuración Local - AgroField

Esta guía resume los pasos necesarios para configurar y correr el proyecto evitando errores comunes de entorno y red.

## 1. El orden correcto para encender todo (¡Muy importante!)

Para que la app funcione en tu celular sin errores de "Tiempo de conexión agotado", debes encender los servicios en este orden exacto:

### Paso 1: Base de Datos (Docker)
1. Abre una terminal y asegúrate de estar en la carpeta **`backend`**.
2. Ejecuta: `npm run docker:up`
*(El puerto configurado en el archivo `.env` para la BD debe ser `5433`).*

### Paso 2: Servidor Backend (NestJS)
1. En la misma terminal de la carpeta **`backend`**.
2. Ejecuta: `npm run start:dev`
3. **¡No cierres esta terminal!** Déjala abierta para que el servidor siga corriendo.

### Paso 3: Conectar el Celular (Samsung)
1. Abre una **nueva terminal** (para no cerrar la del backend).
2. Asegúrate de tener la **Depuración Inalámbrica** activada en tu celular.
3. Toma la IP y Puerto que muestra la pantalla de tu celular y ejecuta:
   `& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" connect 192.168.0.13:PUERTO`
4. Revisa abajo a la derecha en VS Code que diga "Samsung A55".

### Paso 4: Correr la App en el Celular (Frontend)
1. En tu nueva terminal, entra a la carpeta **`frontend`** escribiendo: `cd frontend`.
2. Escribe el comando para instalar y abrir la app en tu celular:
   `flutter run`
*(También puedes presionar la tecla **F5** en VS Code).*

---

## 2. Configuración de Red (Frontend -> Backend)
La app de Flutter debe saber dónde vive el backend. Hemos configurado un `baseUrl` inteligente en `frontend/lib/core/network/api_endpoints.dart`:

- **Web:** Usa `localhost:3000`.
- **Emulador Android:** Usa `10.0.2.2:3000`.
- **Celular Físico:** Debes usar la IP IPv4 de tu computadora (ej. `192.168.0.11:3000`).
  - *Nota:* Ambos dispositivos deben estar en el mismo WiFi. Si te cambias de WiFi (ej. de tu casa a la universidad), recuerda revisar tu IP con el comando `ipconfig` y actualizar el código.

## 3. ¿Sigue fallando al iniciar sesión? (Solución de problemas)
Si la app abre bien pero da error al darle al botón de ingresar:
1. **Firewall de Windows:** Es la causa #1. Desactiva temporalmente el Firewall de Windows (Red Privada) para ver si te deja pasar. Si funciona, tendrás que crearle una regla de entrada al puerto `3000`.
2. **Backend caído:** Revisa la terminal del Paso 2 para ver si NestJS arrojó algún error rojo.
3. **Ruta del SDK:** Recuerda que tu Flutter SDK debe vivir en una ruta sin espacios, como `C:\dev\flutter`.

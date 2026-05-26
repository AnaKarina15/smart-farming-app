# 🚜 AgroField - Plataforma de Agricultura Inteligente

AgroField es una solución digital diseñada para empoderar a los pequeños productores del Magdalena, Colombia. Permite la gestión técnica de cultivos, control fitosanitario y monitoreo de humedad en tiempo real mediante un ecosistema **Offline-First**.

---

## 🏗️ Estructura del Ecosistema

El proyecto está dividido en dos grandes módulos:

- **Backend (`/backend`)**: API REST robusta desarrollada con **NestJS**, PostgreSQL y TypeORM.
- **Frontend (`/frontend`)**: Aplicación móvil multiplataforma desarrollada en **Flutter** con arquitectura basada en Providers.

```text
smart-farming-app/
├── backend/                  # API REST, autenticación, módulos agrícolas y migraciones
│   ├── src/
│   │   ├── modules/          # Auth, usuarios, lotes, riego, siembras, tratamientos, etc.
│   │   ├── database/         # Migraciones, seeds y configuración TypeORM
│   │   └── common/           # Guards, filtros, interceptores y decoradores compartidos
│   ├── docker-compose.yml    # PostgreSQL para desarrollo local
│   └── .env.example          # Variables de entorno de referencia
├── frontend/                 # App Flutter para web, Android, iOS y escritorio
│   ├── lib/
│   │   ├── core/             # Red, almacenamiento local, errores y tema visual
│   │   ├── data/             # Modelos, providers y servicios HTTP/locales
│   │   └── presentation/     # Pantallas y widgets reutilizables
│   ├── web/                  # Configuración Flutter Web
│   └── pubspec.yaml          # Dependencias Flutter
└── README.md                 # Guía principal del proyecto
```

---

## 📋 Requisitos Previos

Asegúrate de tener instalado lo siguiente antes de comenzar:

| Herramienta        | Versión  | Propósito                         |
| :----------------- | :------- | :-------------------------------- |
| **Node.js**        | v20+     | Motor del Backend                 |
| **Docker Desktop** | Reciente | Contenedores de Base de Datos     |
| **Flutter SDK**    | 3.27+    | Framework de la App Móvil         |
| **Java JDK**       | 17       | Compilación Android               |
| **ADB**            | Reciente | Conexión con dispositivos físicos |

---

## 🚀 Guía de Inicio Rápido (Orden de Encendido)

Para evitar errores de conexión entre la app y el servidor, sigue este orden exacto:

### 1. Preparar el Backend (Base de Datos y API)

1.  Entra a la carpeta: `cd backend`
2.  Instala dependencias: `npm install`
3.  Configura el entorno: Copia `.env.example` a `.env`
4.  **Levantar DB**: `npm run docker:up` (Puerto por defecto: `5433`)
5.  **Correr Migraciones**: `npm run migration:run`
6.  **Iniciar Servidor**: `npm run start:dev`
    - _La API estará disponible en:_ `http://localhost:3000/api/v1`
    - _Documentación Swagger:_ `http://localhost:3000/api/docs`

### 2. Conectar Dispositivo (Celular o Emulador)

- **Si usas Celular Físico:**
  1.  Activa la **Depuración Inalámbrica** en opciones de desarrollador.
  2.  Conéctate mediante ADB: `adb connect 192.168.0.X:PUERTO`
- **Si usas Emulador:**
  1.  Abre **Android Studio** -> Device Manager.
  2.  Inicia tu dispositivo virtual (AVD).
- **Verificación:** Asegúrate de que el dispositivo aparezca en la barra inferior de VS Code.

### 3. Lanzar la Aplicación (Frontend)

1.  Entra a la carpeta: `cd frontend`
2.  Instala dependencias: `flutter pub get`
3.  **Ejecutar en modo desarrollo**:
    ```bash
    flutter run
    ```
    También puedes presionar `F5` en VS Code si ya tienes un dispositivo o navegador seleccionado.
4.  **Ejecutar en navegador con backend local**:
    ```bash
    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
    ```
5.  **Construir versión web para despliegue**:
    ```bash
    flutter build web --dart-define=API_BASE_URL=https://smart-farming-app-ak9s.onrender.com/api/v1
    ```
    El resultado queda en `frontend/build/web`.

### 4. Despliegue Web Manual (Vercel)

Si se va a publicar el frontend en Vercel desde la CLI:

```bash
cd frontend
flutter build web --dart-define=API_BASE_URL=https://smart-farming-app-ak9s.onrender.com/api/v1
npx vercel deploy build/web --prod
```

> Asegúrate de iniciar sesión en la cuenta o equipo de Vercel donde existe el proyecto de producción antes de ejecutar el despliegue.

---

## 🌐 Configuración de Red Inteligente

La aplicación detecta automáticamente el entorno para conectar con el backend. Revisa `lib/core/network/api_endpoints.dart` si necesitas ajustes:

- **Web (Chrome):** Conecta a `localhost`.
- **Emulador Android:** Conecta a `10.0.2.2`.
- **Celular Físico:** Utiliza la IP IPv4 de tu computadora (ej. `192.168.0.14`).
  > **IMPORTANTE:** Ambos dispositivos deben estar en la misma red WiFi. Si cambias de red, actualiza tu IP local con el comando `ipconfig`.

---

## 🛠️ Solución de Problemas Comunes

### 1. ¿Error al iniciar sesión? (Connection Refused)

- **Firewall de Windows:** Es la causa principal. Desactiva temporalmente el Firewall (Red Privada) o crea una regla de entrada para el puerto `3000`.
- **Backend Caído:** Verifica que la terminal del backend no muestre errores en rojo.

### 2. Docker no inicia

- Ejecuta: `docker compose down -v` para limpiar volúmenes y luego `npm run docker:up`.

### 3. Errores de SDK

- Asegúrate de que la ruta de Flutter no tenga espacios (Ej: `C:\dev\flutter` es correcto, `C:\Mis Programas\flutter` puede fallar).

---

## 👥 Equipo de Desarrollo

**Universidad del Magdalena** - Facultad de Ingeniería
_Arquitectura de Software 2026_

- Botto Jimenez Yuranis
- Capataz Gamarra Jesus
- Castaño Mazenett Camila
- Rivera Garcia Andres
- Rivera Julio Ana Karina

**Docente:** Johan Alberto Robles Solano

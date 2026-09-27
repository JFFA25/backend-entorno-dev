# <p align="center">Backend &amp; Frontend Dev Environment</p>

<p align="center">
  <strong>Entorno de desarrollo integrado para una API FastAPI y una aplicación Flutter</strong><br>
  <em>Persistencia relacional y NoSQL, autenticación centralizada y cliente multiplataforma.</em>
</p>

<p align="center">
  <img src="/flutter.png" alt="Flutter Logo" width="250"/>
</p>

<p align="center">
  <a href="#tecnologias"><img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white" alt="MongoDB"></a>
  <a href="#tecnologias"><img src="https://img.shields.io/badge/Keycloak-4D4D4D?style=for-the-badge&logo=keycloak&logoColor=white" alt="Keycloak"></a>
</p>

## Descripción General

Este repositorio reúne una infraestructura backend administrada con Docker Compose y una aplicación Flutter para móvil y web. La API de FastAPI se conecta con PostgreSQL para datos relacionales y MongoDB para datos NoSQL; Keycloak proporciona gestión de identidad y autenticación. La aplicación Flutter consume la API y se integra con Keycloak mediante configuración por entorno.

## Tecnologías

| Área | Tecnologías |
| --- | --- |
| API | Python 3.11, FastAPI, Uvicorn, SQLAlchemy, PyMongo |
| Infraestructura | Docker, Docker Compose |
| Persistencia | PostgreSQL 16, MongoDB 7 |
| Identidad | Keycloak 25.0, respaldado por PostgreSQL |
| Aplicación cliente | Flutter, Dart, Dio, `openid_client` |
| Pruebas de API | Swagger UI, OpenAPI, Postman |

## Requisitos Previos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) con Docker Compose.
- [Git](https://git-scm.com/).
- [Flutter SDK](https://docs.flutter.dev/get-started/install) y un navegador compatible, por ejemplo Google Chrome, para ejecutar la versión web.
- [Postman](https://www.postman.com/downloads/) para probar los endpoints.

## Estructura del Proyecto

```text
backend-entorno-dev/
├── app_movil/
│   ├── environments/
│   │   └── .env.dev.json
│   ├── lib/
│   │   ├── core/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── test/
│   └── pubspec.yaml
├── venv/                    # Entorno Python local opcional; no se versiona
├── .env                     # Configuración local; no se versiona
├── .env.example             # Plantilla de variables
├── Dockerfile
├── docker-compose.yml
└── main.py                  # API FastAPI
```

## Despliegue de la Infraestructura (Docker)

1. Clona el repositorio y entra en su directorio:

	```bash
	git clone https://github.com/JFFA25/backend-entorno-dev.git
	cd backend-entorno-dev
	```

2. Crea tu archivo local de variables a partir de la plantilla. En PowerShell:

	```powershell
	Copy-Item .env.example .env
	```

	En macOS o Linux:

	```bash
	cp .env.example .env
	```

	Edita `.env` y sustituye los valores de ejemplo. El archivo `.env` está excluido de Git; no publiques credenciales ni uses las credenciales de desarrollo en producción.

	> **Importante:** en la configuración actual, `docker-compose.yml` declara directamente las variables de los contenedores y no las obtiene de `.env`. Por tanto, copiar y editar la plantilla todavía no cambia las credenciales usadas por Compose. No trates este paso como gestión efectiva de secretos hasta que Compose y la API se configuren para leer esas variables.

3. Construye la imagen personalizada de FastAPI y levanta todos los servicios:

	```bash
	docker compose up -d --build
	```

	Compose construye la imagen desde el `Dockerfile` (Python 3.11-slim) y arranca la API, PostgreSQL 16, MongoDB 7 y Keycloak 25.0 en modo de desarrollo.

| Servicio | Dirección local | Uso |
| --- | --- | --- |
| FastAPI (`fastapi_api`) | `http://localhost:8000` | API backend |
| Swagger UI | `http://localhost:8000/docs` | Documentación interactiva |
| PostgreSQL (`postgres_db`) | `localhost:5432` | Base de datos relacional |
| MongoDB (`mongo_db`) | `localhost:27017` | Base de datos NoSQL |
| Keycloak | `http://localhost:8080` | Administración de identidad |

Para consultar el estado de los contenedores, ejecuta `docker compose ps`. Para detener los servicios sin eliminar los datos persistidos, ejecuta `docker compose down`.

## Configuración Inicial de Keycloak

1. Abre [http://localhost:8080](http://localhost:8080) y accede a la consola de administración con las credenciales configuradas para el entorno local.
2. Crea el Realm `app-movil`.
3. Dentro del Realm, crea el cliente `flutter-app` y habilita **Implicit Flow**.
4. En la configuración del cliente, agrega `http://localhost:*` a **Valid Redirect URIs** y `+` a **Web Origins** para permitir el desarrollo local desde distintos puertos.

Estos permisos amplios son adecuados únicamente para desarrollo local. En un despliegue real, restrínge las URL de redirección y los orígenes a los dominios autorizados.

## Ejecución del Frontend (Flutter)

Desde la raíz del repositorio, entra a la aplicación e instala sus dependencias:

```bash
cd app_movil
flutter pub get
```

Inicia la aplicación web cargando la configuración de desarrollo:

```bash
flutter run --dart-define-from-file=environments/.env.dev.json
```

El archivo define `API_BASE_URL`, `KEYCLOAK_URL`, `KEYCLOAK_REALM` y `KEYCLOAK_CLIENT_ID`. Actualmente apunta a `localhost:8000` para la API y `localhost:8080` para Keycloak. Para elegir explícitamente Chrome como destino, se puede agregar `-d chrome` al comando.

## Pruebas de Endpoints (Postman / Swagger)

FastAPI genera automáticamente la documentación interactiva de la API en [http://localhost:8000/docs](http://localhost:8000/docs). Desde Swagger UI puedes consultar los endpoints disponibles y ejecutar solicitudes.

Para importar la especificación en Postman:

1. Abre Postman y selecciona **Import**.
2. Elige **Link** e introduce `http://localhost:8000/openapi.json`.
3. Confirma la importación para crear una colección con los endpoints documentados.

La API también incluye `GET /` para comprobar que está activa y `GET /healthcheck` para revisar las conexiones con PostgreSQL y MongoDB.

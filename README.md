# Ejabberd en Railway — Servidor XMPP para WebRTC

Servidor XMPP ligero para pruebas de la app de llamadas/videollamadas con WebRTC.

## Estructura

```
ejabberd-railway/
├── Dockerfile        # imagen basada en ejabberd/ecs:24.02
├── ejabberd.yml      # configuración del servidor
├── entrypoint.sh     # inyecta variables de entorno al arrancar
├── railway.toml      # configuración de despliegue en Railway
└── README.md
```

## Despliegue en Railway

### 1. Crear proyecto en Railway
1. Ve a [railway.app](https://railway.app) y entra con GitHub
2. Click **New Project → Deploy from GitHub repo**
3. Selecciona este repositorio

### 2. Configurar variables de entorno
En Railway ve a **Variables** y agrega:

| Variable                | Valor de ejemplo          | Descripción                        |
|-------------------------|---------------------------|------------------------------------|
| `EJABBERD_DOMAIN`       | `tuapp.up.railway.app`    | Dominio público que Railway asigna |
| `EJABBERD_ADMIN_USER`   | `admin`                   | Usuario administrador              |
| `EJABBERD_ADMIN_PASSWORD` | `TuPasswordSegura123`   | Contraseña del admin               |

### 3. Exponer puerto TCP 5222
En Railway:
- Ve a **Settings → Networking**
- Click **Add Port** → escribe `5222` → protocolo **TCP**
- Railway te asignará un puerto externo (ej: `roundhouse.proxy.rlwy.net:XXXXX`)

### 4. Obtener host y puerto
Tras el despliegue, en **Settings → Networking** verás algo como:
```
roundhouse.proxy.rlwy.net:12345
```
Ese host y puerto son los que va en tu app.

---

## Configuración en la app Android

### `local.properties`
```properties
XMPP_HOST=roundhouse.proxy.rlwy.net
XMPP_PORT=12345
TURN_HOST=relay.metered.ca
TURN_USER_DEBUG=tu_user_metered
TURN_PASS_DEBUG=tu_pass_metered
TURN_USER_RELEASE=tu_user_metered
TURN_PASS_RELEASE=tu_pass_metered
```

### Conexión con Smack
```kotlin
val config = XMPPTCPConnectionConfiguration.builder()
    .setXmppDomain(BuildConfig.XMPP_HOST)
    .setHost(BuildConfig.XMPP_HOST)
    .setPort(BuildConfig.XMPP_PORT)
    .setSecurityMode(ConnectionConfiguration.SecurityMode.ifpossible)
    .build()
```

---

## Panel de administración

El panel web está disponible en el puerto 5280 de Railway (HTTP):
```
http://<host-railway>:<puerto-5280>/admin
```
Usuario: `admin@<EJABBERD_DOMAIN>`  
Contraseña: el valor de `EJABBERD_ADMIN_PASSWORD`

---

## Notas importantes

- ⚠️ **Solo para pruebas** — no uses datos reales de usuarios
- 🔒 Railway plan gratuito: 500 hrs/mes, 512 MB RAM
- 📋 Registro abierto: cualquier usuario puede crear cuenta desde la app
- 🔄 El servidor reinicia automáticamente si falla

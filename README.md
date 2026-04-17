# Ejabberd en Railway — Servidor XMPP para WebRTC

Servidor XMPP para pruebas de la app de llamadas/videollamadas con WebRTC.

## Estructura

```
ejabberd-railway/
├── Dockerfile        # imagen ejabberd/ecs:24.02
├── ejabberd.yml      # configuración del servidor
├── railway.toml      # configuración de despliegue
└── README.md
```

---

## Despliegue en Railway

### 1. Crear proyecto
1. Ve a [railway.app](https://railway.app) y entra con GitHub
2. **New Project → Deploy from GitHub repo**
3. Selecciona este repositorio

### 2. Variables de entorno
En Railway → pestaña **Variables**, agrega estas 3 variables:

| Variable        | Ejemplo                                               | Descripción                              |
|-----------------|-------------------------------------------------------|------------------------------------------|
| `XMPP_DOMAIN`   | `maglev.proxy.rlwy.net`                               | Tu host TCP asignado por Railway         |
| `CTL_ON_CREATE` | `register admin maglev.proxy.rlwy.net TuPass123`      | Crea el admin la primera vez que arranca |
| `CTL_ON_START`  | `status`                                              | Verifica que arrancó correctamente       |

> ⚠️ `CTL_ON_CREATE` solo se ejecuta **la primera vez**.
> Reemplaza `maglev.proxy.rlwy.net` y `TuPass123` con tus valores reales.

### 3. Exponer puerto TCP 5222
- Railway → **Settings → Networking → Add Port**
- Puerto: `5222` → protocolo **TCP**
- Railway asigna algo como: `maglev.proxy.rlwy.net:54674`

---

## Verificar que funciona

En los **Logs** de Railway debes ver:

```
Ejabberd 24.02 is running
```

Y la primera vez también:
```
User admin@maglev.proxy.rlwy.net successfully registered
```

---

## Configuración en la app Android

### `local.properties`
```properties
XMPP_HOST=maglev.proxy.rlwy.net
XMPP_PORT=54674
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

## Agregar usuarios desde la Console de Railway

Ve a **Deployments → Deploy activo → Console** y ejecuta:

```sh
# Crear usuario
bin/ejabberdctl register usuario maglev.proxy.rlwy.net password123

# Ver todos los usuarios
bin/ejabberdctl registered_users maglev.proxy.rlwy.net

# Eliminar usuario
bin/ejabberdctl unregister usuario maglev.proxy.rlwy.net
```

---

## Notas

- ⚠️ Solo para pruebas, no uses datos reales
- 🔒 Railway plan gratuito: 500 hrs/mes, 512 MB RAM
- 📋 Registro abierto desde la app via mod_register
- 🔄 Reinicio automático si falla

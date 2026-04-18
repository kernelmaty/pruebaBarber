# 🚀 Guía Completa: Configurar TurnosCut con Supabase
### Sin conocimiento técnico — 30 minutos en total

---

## ¿Qué vas a lograr?
Al final de esta guía vas a tener:
- ✅ Base de datos real en la nube (gratis)
- ✅ Login con email y contraseña
- ✅ Datos que se guardan y persisten
- ✅ Actualizaciones en tiempo real (Realtime)
- ✅ Cada barbería ve solo sus datos (seguridad)

---

## PASO 1 — Crear cuenta en Supabase (5 min)

1. Entrá a **[supabase.com](https://supabase.com)**
2. Clic en **"Start your project"** (botón verde)
3. Registrate con tu cuenta de GitHub o con email
4. Una vez adentro, clic en **"New project"**
5. Completá:
   - **Name:** `turnoscut` (o el nombre que quieras)
   - **Database Password:** Poné una contraseña fuerte — **guardala en algún lado**
   - **Region:** `South America (São Paulo)` — es la más cercana a Argentina
6. Clic en **"Create new project"**
7. Esperá 2-3 minutos mientras se crea el proyecto

---

## PASO 2 — Crear la base de datos (5 min)

1. En el menú de la izquierda, clic en **"SQL Editor"** (ícono de base de datos)
2. Clic en **"New query"** (botón arriba a la derecha)
3. Abrí el archivo **`supabase-setup.sql`** con un editor de texto (Notepad, TextEdit, etc.)
4. Seleccioná TODO el contenido (Ctrl+A) y copialo (Ctrl+C)
5. Pegalo en el editor de Supabase (Ctrl+V)
6. Clic en el botón **"Run"** (o F5)
7. Deberías ver: `Success. No rows returned`

✅ **¡Listo! La base de datos está creada.**

---

## PASO 3 — Copiar tus credenciales API (2 min)

1. En el menú de la izquierda, clic en **"Settings"** (ícono de engranaje, abajo del todo)
2. Clic en **"API"**
3. Vas a ver dos datos importantes:

**Project URL** — Se ve así:
```
https://abcdefghijklmnop.supabase.co
```

**anon public key** — Se ve así (mucho más larga):
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiO...
```

4. Copiá y guardá los dos datos en un bloc de notas

---

## PASO 4 — Conectar la app (3 min)

1. Abrí el archivo **`turnoscut-supabase-app.html`** en tu navegador (doble clic)
2. Vas a ver la pantalla de configuración
3. Pegá el **Project URL** en el primer campo
4. Pegá el **anon public key** en el segundo campo
5. Clic en **"🚀 Conectar y entrar"**

Si ves la pantalla de login → ¡funcionó!

---

## PASO 5 — Crear tu cuenta de barbería (2 min)

1. En la pantalla de login, clic en **"¿No tenés cuenta? Registrate"**
2. Completá:
   - **Tu nombre:** Ej: Marcos García
   - **Nombre de tu barbería:** Ej: La Vieja Escuela
   - **Email:** tu email
   - **Contraseña:** mínimo 6 caracteres
3. Clic en **"🚀 Crear cuenta gratis"**
4. Revisá tu email y confirmá la cuenta (te llega un mail de Supabase)
5. Volvé a la app y hace login

✅ **¡Ya estás adentro de tu panel de TurnosCut!**

---

## PASO 6 — Cargar tus datos iniciales (10 min)

### 6.1 — Agregar tus servicios y precios
1. Clic en **"Servicios y Precios"** en el menú lateral
2. Clic en **"+ Nuevo servicio"**
3. Cargá cada servicio que ofrecés (Corte, Barba, Combo, etc.) con su precio y duración
4. Repetí para cada servicio

### 6.2 — Agregar tus barberos
Vas a necesitar hacerlo desde Supabase directamente:
1. En Supabase → **"Table Editor"** → tabla **"usuarios"**
2. Clic en **"Insert row"**
3. Completá: empresa_id (copialo de la tabla empresas), nombre, email, rol = `barbero`

### 6.3 — Empezar a cargar clientes
1. Clic en **"Clientes"** en el menú
2. Clic en **"+ Nuevo cliente"** y cargá tus clientes habituales

### 6.4 — Tu primer turno
1. Clic en **"Turnos"**
2. Clic en **"+ Nuevo turno"**
3. Elegí cliente, servicio, barbero, fecha y hora

---

## PASO 7 — Habilitar autenticación por email (opcional, 2 min)

Por defecto Supabase manda un email de confirmación. Si querés saltear eso para pruebas:

1. Supabase → **"Authentication"** → **"Providers"** → **"Email"**
2. Desactivá **"Confirm email"**
3. Guardá

---

## Preguntas frecuentes

**¿Cuánto cuesta Supabase?**
El plan gratuito incluye: 500 MB de base de datos, 2 GB de almacenamiento, 50.000 usuarios. Más que suficiente para empezar. Cuando tengas muchos clientes, el plan Pro cuesta USD 25/mes.

**¿Los datos están seguros?**
Sí. Usamos Row Level Security (RLS) — cada barbería solo puede ver sus propios datos. La conexión es HTTPS.

**¿Puedo tener varias barberías?**
Sí. Cada cuenta es una empresa separada. Cada una tiene su propia URL, datos y configuración.

**¿Cómo hago backup de mis datos?**
Supabase → Settings → Database → "Backups". En el plan gratuito podés descargar el backup manualmente.

**¿Qué pasa si se cae internet?**
La app necesita conexión para funcionar. Los datos siempre están en la nube.

**¿Puedo ponerlo en mi dominio propio?**
Sí. Subí el archivo HTML a Netlify o Vercel (ambos gratis) y apuntá tu dominio .com.ar.

---

## Subir a internet (opcional) — Netlify en 5 min

1. Entrá a **[netlify.com](https://netlify.com)** y creá una cuenta gratis
2. En el dashboard, arrastrá el archivo `turnoscut-supabase-app.html` a la zona de deploy
3. Netlify te da una URL automática como `random-name.netlify.app`
4. Opcional: en Site Settings → Domain → agregá tu dominio `.com.ar`

---

## Stack técnico completo

```
Frontend:     HTML + CSS + React 18 (via CDN, sin build tools)
Backend:      Supabase (PostgreSQL + Auth + Realtime + Storage)
Base datos:   PostgreSQL con RLS (Row Level Security)
Autenticación: Supabase Auth (email/password, extensible a OAuth)
Realtime:     Supabase Realtime (WebSockets)
Deploy:       Netlify / Vercel / cualquier hosting estático
Pagos:        Mercado Pago (integración futura)
WhatsApp:     Z-API o Twilio (integración futura)
```

---

## Próximos pasos después de configurarlo

- [ ] **Integrar WhatsApp:** Crear cuenta en Z-API + webhook en Make
- [ ] **Cobros con Mercado Pago:** Activar suscripciones recurrentes
- [ ] **App móvil:** Convertir a PWA (una línea de código)
- [ ] **Recordatorios automáticos:** Make.com + Z-API (gratis hasta 1.000 ops/mes)
- [ ] **Estadísticas avanzadas:** Agregar gráficos con Recharts

---

*TurnosCut — Guía de configuración v1.0*
*Soporte: hola@turnoscut.com.ar*

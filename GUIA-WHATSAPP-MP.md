# 💬💳 Guía: WhatsApp + Mercado Pago para TurnosCut
### Configuración completa paso a paso — Sin código

---

## PARTE 1 — WhatsApp con Z-API

### ¿Qué hace?
- Cuando se crea un turno → manda confirmación automática al cliente
- 24 hs antes → manda recordatorio por WhatsApp
- Si se cancela → manda aviso

### Paso 1 — Crear cuenta en Z-API

1. Entrá a **[z-api.io](https://z-api.io)** → Crear cuenta gratis
2. Plan gratuito: 500 mensajes/mes (suficiente para empezar)
3. Hacé clic en **"Nueva instancia"**
4. Te aparece un QR
5. Abrí WhatsApp en tu celular → ⋮ (tres puntos) → **Dispositivos vinculados** → **Vincular dispositivo**
6. Escaneá el QR
7. ✅ Tu WhatsApp ya está conectado a Z-API

### Paso 2 — Copiar credenciales

En el panel de Z-API, tu instancia:
- **Instance ID** → ej: `3ABC456DEF`
- **Token** → ej: `F4D9...`
- **Client-Token** → ej: `Fxxx...` (está en Security → Client-Token)

### Paso 3 — Pegar en TurnosCut

1. Abrí `turnoscut-integraciones.html`
2. Sección WhatsApp → pegá los 3 datos
3. Hacé clic en **"Probar conexión"**
4. Si dice "conectado" → ✅ listo
5. Clic en **"Guardar configuración WhatsApp"**

---

### Automatizar con Make (recordatorios automáticos)

Make es el pegamento que conecta todo sin código. Plan gratuito: 1.000 operaciones/mes.

#### Flujo 1: Confirmación automática al crear turno

1. Entrá a **[make.com](https://make.com)** → Crear cuenta
2. **Create a new scenario**
3. Agregar módulo **Supabase** → "Watch Rows" → tabla `turnos` → filtro `estado = pendiente`
4. Agregar módulo **HTTP** → Make an API call:
   ```
   URL: https://api.z-api.io/instances/{TU_INSTANCE_ID}/token/{TU_TOKEN}/send-text
   Method: POST
   Headers:
     Content-Type: application/json
     Client-Token: {TU_CLIENT_TOKEN}
   Body:
   {
     "phone": "54{{clientes.telefono}}",
     "message": "¡Hola {{clientes.nombre}}! ✂️ Tu turno en *Tu Barbería* está confirmado para el *{{turnos.fecha}}* a las *{{turnos.hora_inicio}}*."
   }
   ```
5. Agregar módulo **Supabase** → "Update a Row" → tabla `whatsapp_logs` → insertar registro

#### Flujo 2: Recordatorio 24hs antes

1. Nuevo scenario en Make
2. Módulo: **Schedule** → cada 1 hora
3. Módulo: **Supabase** → "Search Rows" → tabla `turnos`:
   - `fecha = TOMORROW` (usá la función de fecha de Make)
   - `recordatorio_enviado = false`
   - `estado = pendiente OR confirmado`
4. Módulo: **HTTP** → mismo endpoint Z-API con el mensaje de recordatorio
5. Módulo: **Supabase** → "Update a Row" → `recordatorio_enviado = true`

---

## PARTE 2 — Mercado Pago (cobros automáticos)

### ¿Qué hace?
- El barbero suscribe a un plan mensual
- MP debita automáticamente cada mes
- Cuando paga → su plan se activa solo
- Si no paga → acceso suspendido

### Paso 1 — Crear cuenta en Mercado Pago Desarrolladores

1. Entrá a **[mercadopago.com.ar](https://www.mercadopago.com.ar)** → Crear cuenta
2. Completá verificación de identidad (CUIL, DNI)
3. Entrá a **[developers.mercadopago.com](https://developers.mercadopago.com)**
4. Clic en **"Crear aplicación"**
   - Nombre: `TurnosCut`
   - Tipo: Pagos online
5. En tu aplicación → **Credenciales de producción** → copiá:
   - **Access Token** (empieza con `APP_USR-`)
   - **Public Key** (empieza con `APP_USR-`)

### Paso 2 — Crear planes de suscripción en MP

1. Entrá a **[mercadopago.com.ar/subscriptions](https://www.mercadopago.com.ar/subscriptions)**
2. Clic en **"Crear plan"**
3. Para cada plan:

   **Plan Básico:**
   - Nombre: `TurnosCut Básico`
   - Monto: `$8.000 ARS`
   - Frecuencia: `Mensual`
   - Clic en Crear → copiá el ID del plan

   **Plan Pro:**
   - Nombre: `TurnosCut Pro`
   - Monto: `$14.000 ARS`
   - Frecuencia: `Mensual`

   **Plan Premium:**
   - Nombre: `TurnosCut Premium`
   - Monto: `$22.000 ARS`
   - Frecuencia: `Mensual`

4. Pegá los 3 IDs en `turnoscut-integraciones.html` → sección MP → Guardar

### Paso 3 — Link de pago para el barbero

En `turnoscut-integraciones.html` → sección Mercado Pago → hacé clic en **"Generar link"** del plan correspondiente. Te copia automáticamente un link como:
```
https://www.mercadopago.com.ar/subscriptions/checkout?preapproval_plan_id=2c938084...
```

Ese link se lo mandás al barbero. Cuando paga, recibe acceso.

### Paso 4 — Automatizar activación con Make

1. Nuevo scenario en Make
2. Módulo: **Webhooks** → "Custom webhook" → copiá la URL del webhook
3. Configurar en MP: Developers → tu app → **Webhooks** → pegá la URL de Make → eventos: `subscription_preapproval`
4. Módulo: **JSON** → parsear el body del webhook
5. Módulo: **Router** → si `status = authorized`:
   a. **Supabase** → insertar en `mp_suscripciones` con estado `authorized`
   b. **Supabase** → insertar en `mp_pagos` con estado `approved`
   c. **Supabase** → update `empresas.plan = pro` y `plan_activo = true`
   d. **HTTP** → Z-API → mandar WhatsApp al dueño: "¡Tu plan Pro está activo! 🎉"

---

## PARTE 3 — Flujo completo integrado

```
NUEVO CLIENTE PAGA:
MP cobra → Webhook → Make → Supabase activa plan
       └→ Z-API → WhatsApp bienvenida al barbero

NUEVO TURNO:
Barbero crea turno → Make detecta → Z-API → WhatsApp confirmación al cliente

NOCHE ANTERIOR:
Make corre cada hora → busca turnos del día siguiente → Z-API → WhatsApp recordatorio

PAGO MENSUAL:
MP debita automático → Webhook → Make → Supabase renueva plan
                              └→ Z-API → "Tu plan fue renovado 🎉"
```

---

## Costos mensuales (a 30 clientes)

| Servicio | Plan | Costo |
|---|---|---|
| Supabase | Free tier | $0 |
| Z-API | Starter (5.000 msgs/mes) | ~USD 20 = ~$20.000 ARS |
| Make | Core (10.000 ops/mes) | ~USD 10 = ~$10.000 ARS |
| Mercado Pago | % por transacción (2.99%) | ~$12.600 ARS |
| Netlify (hosting) | Free | $0 |
| **Total costos** | | **~$42.600/mes** |
| **Ingresos (30 × Pro)** | | **$420.000/mes** |
| **Ganancia neta** | | **$377.400/mes** |

---

## FAQ

**¿El barbero necesita hacer algo especial?**
No. Solo recibe el link de MP, paga, y su sistema se activa solo.

**¿Los mensajes de WhatsApp parecen spam?**
No, porque salen de un número real con tu WhatsApp escaneado, no de un número genérico.

**¿Puedo usar el WhatsApp de la barbería?**
Sí, y es lo recomendado. El cliente ve el nombre de la barbería como remitente.

**¿Qué pasa si Z-API se desconecta?**
El celular tiene que estar con carga y conectado a internet. Si se desconecta, reconectás escaneando el QR de nuevo.

**¿MP funciona con CBU propio?**
Sí, el dinero se deposita directo en tu cuenta de MP, que podés transferir a cualquier CBU/CVU.

**¿Puedo probar sin cobrar?**
Sí, tanto Z-API como MP tienen entornos de sandbox (prueba) con credenciales de test separadas.

---

*TurnosCut — Guía de integraciones v1.0*

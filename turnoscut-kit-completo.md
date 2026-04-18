# TurnosCut — Kit de Lanzamiento Completo

---

## 1. GUIÓN DE ENTREVISTAS CON BARBEROS

**Objetivo:** Validar que el problema existe y que pagarían por la solución.
**Duración:** 15-20 minutos. En persona o por WhatsApp de voz.
**Meta:** Hablar con 10 barberos. Si 3 dicen "sí pagaría" → arrancás.

---

### Apertura (2 min)
> "Hola [nombre], te llamo porque estoy desarrollando un sistema para barberías y quiero entender cómo trabajan. No te voy a vender nada hoy, solo quiero aprender. ¿Tenés 15 minutos?"

---

### Preguntas (en orden)

**Sobre su situación actual:**
1. ¿Cómo manejan los turnos hoy? ¿WhatsApp, papel, de palabra?
2. ¿Cuántos turnos tienen por día aproximadamente?
3. ¿Les pasa que la gente no avisa y no viene? ¿Con qué frecuencia?
4. ¿Cómo registran cuánto facturan por día?
5. ¿Tienen forma de saber a qué clientes hace tiempo que no ven?

**Sobre el dolor:**
6. ¿Qué es lo que más tiempo les quita en el día a día que no sea cortar?
7. Si pudieran cambiar UNA sola cosa del modo en que gestionan la barbería, ¿qué sería?

**Sobre la solución:**
8. ¿Conocen algún sistema para barberías? ¿Usaron algo?
9. Si hubiera un sistema donde los clientes sacan turno solos y les llega un recordatorio por WhatsApp, ¿lo usarían?
10. ¿Cuánto estarían dispuestos a pagar por mes por algo así?

---

### Cierre
> "Perfecto, me ayudaste un montón. Cuando tenga algo para probar, ¿te puedo contactar para que seas de los primeros en usarlo gratis?"

**Anotá siempre:** nombre, barbería, ciudad, precio que mencionaron, frase textual más importante que dijeron.

---

## 2. COPY DE VENTAS (para WhatsApp / Instagram DM)

### Mensaje de primer contacto (WhatsApp)
```
Hola [nombre] 👋

Vi tu barbería en Instagram y quería preguntarte algo rápido.

¿Todavía manejás los turnos por WhatsApp o por teléfono?

Te pregunto porque estoy armando un sistema específico para barberías acá en Argentina — turnos online + recordatorio automático por WhatsApp + control de caja — y busco 5 barberías para probarlo GRATIS el primer mes a cambio de feedback.

¿Te interesaría saber más?
```

---

### Mensaje de seguimiento (si no responde en 2 días)
```
Hola [nombre], te escribo de nuevo por lo del sistema de turnos.

Solo quería aclarar que la prueba es 100% gratis, sin tarjeta ni contrato. Si no te sirve, no perdés nada.

¿Tenés 10 minutos esta semana para que te muestre cómo funciona?
```

---

### Mensaje después de la demo (cierre)
```
Gracias por el tiempo [nombre] 🙌

Como te comenté, el plan Pro que incluye WhatsApp automático + caja es $14.000/mes.

Para vos, como uno de los primeros, el primer mes es gratis. A partir del segundo, si querés seguir, me avisás y activamos el pago.

¿Arrancamos?
```

---

### Caption para Instagram (post o historia)
```
💈 ¿Cuántos turnos perdiste esta semana porque alguien no avisó que no venía?

Con TurnosCut, tus clientes reciben un recordatorio por WhatsApp automático 24hs antes del turno.

Sin ausentes. Sin mensajes de ida y vuelta. Sin papeles.

👇 Probalo gratis 14 días — link en bio.

#barberia #barbershop #barberiaargentina #turnosonline #sistemaparbarberias
```

---

## 3. ESTRUCTURA DEL MVP

### Stack recomendado (todo sin código)

| Herramienta | Rol | Costo |
|---|---|---|
| **Glide** | La app (turnos, clientes, caja) | Gratis hasta 25 usuarios |
| **Framer** | Landing page | Gratis |
| **Make (Integromat)** | Automatizaciones | Gratis hasta 1.000 ops/mes |
| **Z-API** | WhatsApp | ~$30 USD/mes |
| **Mercado Pago** | Cobros recurrentes | % por transacción |
| **NIC Argentina** | Dominio .com.ar | ~$2.000/año |

**Inversión inicial estimada: $0 a $50 USD/mes**

---

### Las 3 pantallas del MVP en Glide

**Pantalla 1 — TURNOS**
- El cliente entra al link de su barbería
- Elige barbero (si hay más de uno)
- Elige servicio (corte, barba, combo)
- Elige día y hora disponibles
- Pone nombre y teléfono → turno confirmado

**Pantalla 2 — CLIENTES (solo para el barbero)**
- Lista de clientes con nombre, tel, última visita
- Historial de turnos por cliente
- Botón para contactar por WhatsApp

**Pantalla 3 — CAJA (solo para el barbero)**
- Registro de ingresos del día
- Total del día, semana, mes
- Tipos de servicio más realizados

---

### Automatización con Make

**Flujo 1 — Turno confirmado:**
1. Cliente reserva turno en Glide
2. Make detecta la nueva fila en Google Sheets
3. Z-API manda WhatsApp de confirmación al cliente
4. 24hs antes: Z-API manda recordatorio automático

**Flujo 2 — Pago y activación:**
1. Barbero paga por Mercado Pago
2. Make activa su cuenta en Glide
3. Make manda email de bienvenida con link al sistema
4. Make registra la fecha de vencimiento

---

## 4. MODELO DE NEGOCIO

### Proyección a 12 meses

| Mes | Clientes | Ingreso mensual |
|---|---|---|
| 1-2 | 5 (gratis) | $0 |
| 3 | 10 | $140.000 |
| 6 | 20 | $280.000 |
| 9 | 30 | $420.000 |
| 12 | 50 | $700.000 |

*Basado en plan Pro ($14.000/mes)*

### Costos mensuales (mes 3 en adelante)
- Z-API: ~$30.000
- Make Pro: ~$15.000
- Glide Team: ~$40.000
- Total: ~$85.000/mes

**Ganancia neta a 30 clientes: ~$335.000/mes**

---

## 5. PRÓXIMOS PASOS CONCRETOS

### Esta semana:
- [ ] Hacer las 10 entrevistas
- [ ] Registrar el dominio turnoscut.com.ar en NIC Argentina
- [ ] Crear cuenta en Framer (gratis)

### Próximas 2 semanas:
- [ ] Armar la landing en Framer con el copy de arriba
- [ ] Crear cuenta en Glide y armar las 3 pantallas
- [ ] Configurar Make con el flujo de recordatorios

### Primer mes:
- [ ] Conseguir 5 barberías para la prueba gratuita
- [ ] Iterar el sistema según el feedback
- [ ] Activar cobros con Mercado Pago

---

*TurnosCut — Sistema para barberías argentinas*
*Versión 1.0 — Plan de lanzamiento*

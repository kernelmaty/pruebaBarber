-- ================================================================
--  TurnosCut — Migración: WhatsApp + Mercado Pago
--  Pegá en Supabase > SQL Editor > New query > Run
-- ================================================================

-- ============================================================
-- TABLA: configuracion_empresa (settings por barbería)
-- ============================================================
CREATE TABLE IF NOT EXISTS configuracion_empresa (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id            UUID UNIQUE NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,

  -- WhatsApp / Z-API
  zapi_instance_id      TEXT,
  zapi_token            TEXT,
  zapi_client_token     TEXT,
  wp_recordatorio_hs    INT  NOT NULL DEFAULT 24,   -- horas antes del turno
  wp_recordatorio_activo BOOLEAN NOT NULL DEFAULT FALSE,
  wp_confirmacion_activo BOOLEAN NOT NULL DEFAULT FALSE,
  wp_msg_confirmacion   TEXT DEFAULT '¡Hola {cliente}! ✂️ Tu turno en *{barberia}* está confirmado para el *{fecha}* a las *{hora}*. ¡Te esperamos!',
  wp_msg_recordatorio   TEXT DEFAULT '🔔 Hola {cliente}, te recordamos que mañana tenés turno en *{barberia}* a las *{hora}*. Si no podés venir, avisanos. ¡Gracias!',
  wp_msg_cancelacion    TEXT DEFAULT 'Hola {cliente}, tu turno del {fecha} a las {hora} en *{barberia}* fue cancelado. Escribinos para reprogramar.',

  -- Mercado Pago
  mp_access_token       TEXT,
  mp_public_key         TEXT,
  mp_webhook_secret     TEXT,
  mp_plan_id_basico     TEXT,   -- ID del plan en MP
  mp_plan_id_pro        TEXT,
  mp_plan_id_premium    TEXT,

  creado_en             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: whatsapp_logs (historial de mensajes enviados)
-- ============================================================
CREATE TABLE IF NOT EXISTS whatsapp_logs (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id   UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  turno_id     UUID REFERENCES turnos(id),
  cliente_id   UUID REFERENCES clientes(id),
  telefono     TEXT NOT NULL,
  tipo         TEXT NOT NULL CHECK (tipo IN ('confirmacion','recordatorio','cancelacion','manual')),
  mensaje      TEXT NOT NULL,
  estado       TEXT NOT NULL DEFAULT 'enviado' CHECK (estado IN ('enviado','error','pendiente')),
  zapi_msg_id  TEXT,
  error_detail TEXT,
  enviado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: mp_suscripciones (suscripciones activas de barberías)
-- ============================================================
CREATE TABLE IF NOT EXISTS mp_suscripciones (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id          UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  mp_preapproval_id   TEXT UNIQUE,        -- ID de preapproval en MP
  mp_payer_email      TEXT,
  plan_slug           TEXT NOT NULL,
  monto               NUMERIC(10,2) NOT NULL,
  estado              TEXT NOT NULL DEFAULT 'pending'
                        CHECK (estado IN ('pending','authorized','paused','cancelled')),
  fecha_inicio        DATE,
  fecha_proximo_pago  DATE,
  creado_en           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: mp_pagos (historial de cobros recibidos)
-- ============================================================
CREATE TABLE IF NOT EXISTS mp_pagos (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id      UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  suscripcion_id  UUID REFERENCES mp_suscripciones(id),
  mp_payment_id   TEXT UNIQUE,
  monto           NUMERIC(10,2) NOT NULL,
  estado          TEXT NOT NULL,   -- approved | rejected | pending
  metodo          TEXT,
  descripcion     TEXT,
  fecha_pago      TIMESTAMPTZ,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- FUNCIÓN: activar plan al recibir pago aprobado
-- ============================================================
CREATE OR REPLACE FUNCTION activar_plan_tras_pago()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_empresa_id UUID;
  v_plan TEXT;
BEGIN
  IF NEW.estado = 'approved' AND (OLD.estado IS DISTINCT FROM 'approved') THEN
    SELECT s.empresa_id, s.plan_slug INTO v_empresa_id, v_plan
    FROM mp_suscripciones s WHERE s.id = NEW.suscripcion_id;

    UPDATE empresas SET plan = v_plan, plan_activo = TRUE, actualizado_en = NOW()
    WHERE id = v_empresa_id;

    INSERT INTO suscripciones (empresa_id, plan_id, estado, monto, metodo_pago, mp_payment_id, periodo_desde, periodo_hasta)
    SELECT v_empresa_id, p.id, 'activa', NEW.monto, 'mp', NEW.mp_payment_id,
           CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days'
    FROM planes p WHERE p.slug = v_plan;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_mp_pago_aprobado
  AFTER UPDATE ON mp_pagos
  FOR EACH ROW EXECUTE FUNCTION activar_plan_tras_pago();

-- ============================================================
-- RLS para nuevas tablas
-- ============================================================
ALTER TABLE configuracion_empresa ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_logs         ENABLE ROW LEVEL SECURITY;
ALTER TABLE mp_suscripciones      ENABLE ROW LEVEL SECURITY;
ALTER TABLE mp_pagos              ENABLE ROW LEVEL SECURITY;

CREATE POLICY "config_owner" ON configuracion_empresa
  FOR ALL USING (empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid()));

CREATE POLICY "wp_logs_owner" ON whatsapp_logs
  FOR ALL USING (empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid()));

CREATE POLICY "mp_subs_owner" ON mp_suscripciones
  FOR ALL USING (empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid()));

CREATE POLICY "mp_pagos_owner" ON mp_pagos
  FOR ALL USING (empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid()));

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE whatsapp_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE mp_suscripciones;
ALTER PUBLICATION supabase_realtime ADD TABLE mp_pagos;

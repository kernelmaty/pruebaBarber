-- ================================================================
--  TurnosCut — Supabase Migration Script
--  Pegá este SQL completo en: Supabase > SQL Editor > New query
--  Luego hacé clic en "Run" (F5)
-- ================================================================

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABLA: empresas
-- ============================================================
CREATE TABLE IF NOT EXISTS empresas (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id        UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  nombre          TEXT NOT NULL,
  slug            TEXT UNIQUE NOT NULL,
  email           TEXT UNIQUE NOT NULL,
  telefono        TEXT,
  direccion       TEXT,
  ciudad          TEXT,
  provincia       TEXT,
  logo_url        TEXT,
  plan            TEXT NOT NULL DEFAULT 'basico' CHECK (plan IN ('basico','pro','premium')),
  plan_activo     BOOLEAN NOT NULL DEFAULT TRUE,
  trial_hasta     DATE DEFAULT (CURRENT_DATE + INTERVAL '14 days'),
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: planes
-- ============================================================
CREATE TABLE IF NOT EXISTS planes (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre          TEXT NOT NULL,
  slug            TEXT UNIQUE NOT NULL,
  precio_mensual  NUMERIC(10,2) NOT NULL,
  max_barberos    INT NOT NULL DEFAULT 2,
  whatsapp_auto   BOOLEAN NOT NULL DEFAULT FALSE,
  control_caja    BOOLEAN NOT NULL DEFAULT FALSE,
  multi_sede      BOOLEAN NOT NULL DEFAULT FALSE,
  estadisticas    BOOLEAN NOT NULL DEFAULT FALSE,
  descripcion     TEXT,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO planes (nombre, slug, precio_mensual, max_barberos, whatsapp_auto, control_caja, multi_sede, estadisticas, descripcion)
VALUES
  ('Básico',  'basico',  8000,  2,  FALSE, FALSE, FALSE, FALSE, 'Turnos online + clientes.'),
  ('Pro',     'pro',     14000, 5,  TRUE,  TRUE,  FALSE, TRUE,  'WhatsApp automático + caja + estadísticas.'),
  ('Premium', 'premium', 22000, 99, TRUE,  TRUE,  TRUE,  TRUE,  'Multi-sede + barberos ilimitados.')
ON CONFLICT (slug) DO NOTHING;

-- ============================================================
-- TABLA: usuarios (barberos)
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  empresa_id  UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nombre      TEXT NOT NULL,
  email       TEXT NOT NULL,
  telefono    TEXT,
  rol         TEXT NOT NULL DEFAULT 'barbero' CHECK (rol IN ('dueño','barbero','admin')),
  avatar_url  TEXT,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: clientes
-- ============================================================
CREATE TABLE IF NOT EXISTS clientes (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id      UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nombre          TEXT NOT NULL,
  telefono        TEXT,
  email           TEXT,
  fecha_nac       DATE,
  notas           TEXT,
  ultima_visita   DATE,
  total_visitas   INT NOT NULL DEFAULT 0,
  total_gastado   NUMERIC(12,2) NOT NULL DEFAULT 0,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: servicios
-- ============================================================
CREATE TABLE IF NOT EXISTS servicios (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id    UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nombre        TEXT NOT NULL,
  descripcion   TEXT,
  precio        NUMERIC(10,2) NOT NULL,
  duracion_min  INT NOT NULL DEFAULT 30,
  color         TEXT DEFAULT '#c9a84c',
  activo        BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: turnos
-- ============================================================
CREATE TABLE IF NOT EXISTS turnos (
  id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id            UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  cliente_id            UUID REFERENCES clientes(id),
  barbero_id            UUID NOT NULL REFERENCES usuarios(id),
  servicio_id           UUID NOT NULL REFERENCES servicios(id),
  fecha                 DATE NOT NULL,
  hora_inicio           TIME NOT NULL,
  hora_fin              TIME NOT NULL,
  estado                TEXT NOT NULL DEFAULT 'pendiente'
                          CHECK (estado IN ('pendiente','confirmado','completado','cancelado','ausente')),
  precio_cobrado        NUMERIC(10,2),
  notas                 TEXT,
  recordatorio_enviado  BOOLEAN NOT NULL DEFAULT FALSE,
  creado_en             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: caja
-- ============================================================
CREATE TABLE IF NOT EXISTS caja (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id  UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  usuario_id  UUID REFERENCES usuarios(id),
  turno_id    UUID REFERENCES turnos(id),
  tipo        TEXT NOT NULL CHECK (tipo IN ('ingreso','egreso')),
  categoria   TEXT CHECK (categoria IN ('servicio','producto','alquiler','insumo','otro')),
  descripcion TEXT NOT NULL,
  monto       NUMERIC(12,2) NOT NULL,
  metodo_pago TEXT DEFAULT 'efectivo'
                CHECK (metodo_pago IN ('efectivo','transferencia','tarjeta','mp')),
  fecha       DATE NOT NULL DEFAULT CURRENT_DATE,
  hora        TIME NOT NULL DEFAULT CURRENT_TIME,
  creado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: deudas
-- ============================================================
CREATE TABLE IF NOT EXISTS deudas (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id      UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  cliente_id      UUID NOT NULL REFERENCES clientes(id),
  turno_id        UUID REFERENCES turnos(id),
  monto_original  NUMERIC(12,2) NOT NULL,
  monto_pagado    NUMERIC(12,2) NOT NULL DEFAULT 0,
  estado          TEXT NOT NULL DEFAULT 'pendiente'
                    CHECK (estado IN ('pendiente','parcial','pagada')),
  fecha_venc      DATE,
  notas           TEXT,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: pagos_deudas
-- ============================================================
CREATE TABLE IF NOT EXISTS pagos_deudas (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  deuda_id    UUID NOT NULL REFERENCES deudas(id) ON DELETE CASCADE,
  monto       NUMERIC(12,2) NOT NULL,
  metodo_pago TEXT DEFAULT 'efectivo',
  notas       TEXT,
  pagado_en   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: productos
-- ============================================================
CREATE TABLE IF NOT EXISTS productos (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id      UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  nombre          TEXT NOT NULL,
  descripcion     TEXT,
  precio_costo    NUMERIC(10,2),
  precio_venta    NUMERIC(10,2),
  stock           INT NOT NULL DEFAULT 0,
  stock_minimo    INT NOT NULL DEFAULT 0,
  unidad          TEXT DEFAULT 'unidad',
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  actualizado_en  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLA: suscripciones
-- ============================================================
CREATE TABLE IF NOT EXISTS suscripciones (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id      UUID NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  plan_id         UUID NOT NULL REFERENCES planes(id),
  estado          TEXT NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','vencida','cancelada')),
  monto           NUMERIC(10,2) NOT NULL,
  metodo_pago     TEXT,
  mp_payment_id   TEXT,
  periodo_desde   DATE NOT NULL,
  periodo_hasta   DATE NOT NULL,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_turnos_empresa_fecha  ON turnos(empresa_id, fecha);
CREATE INDEX IF NOT EXISTS idx_turnos_cliente        ON turnos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_caja_empresa_fecha    ON caja(empresa_id, fecha);
CREATE INDEX IF NOT EXISTS idx_clientes_empresa      ON clientes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_deudas_cliente        ON deudas(cliente_id);
CREATE INDEX IF NOT EXISTS idx_deudas_estado         ON deudas(estado);

-- ============================================================
-- VISTAS
-- ============================================================
CREATE OR REPLACE VIEW v_caja_diaria AS
SELECT
  empresa_id,
  fecha,
  SUM(CASE WHEN tipo='ingreso' THEN monto ELSE 0 END)          AS total_ingresos,
  SUM(CASE WHEN tipo='egreso'  THEN monto ELSE 0 END)          AS total_egresos,
  SUM(CASE WHEN tipo='ingreso' THEN monto ELSE -monto END)     AS saldo_neto,
  COUNT(CASE WHEN tipo='ingreso' THEN 1 END)                   AS cant_ingresos,
  COUNT(CASE WHEN tipo='egreso'  THEN 1 END)                   AS cant_egresos
FROM caja
GROUP BY empresa_id, fecha;

CREATE OR REPLACE VIEW v_clientes_deudores AS
SELECT
  cl.empresa_id,
  cl.id AS cliente_id,
  cl.nombre,
  cl.telefono,
  SUM(d.monto_original - d.monto_pagado) AS deuda_total
FROM clientes cl
JOIN deudas d ON d.cliente_id = cl.id AND d.estado IN ('pendiente','parcial')
GROUP BY cl.empresa_id, cl.id, cl.nombre, cl.telefono;

-- ============================================================
-- FUNCIÓN: actualizar updated_at automáticamente
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.actualizado_en = NOW(); RETURN NEW; END;
$$;

CREATE TRIGGER trg_empresas_updated  BEFORE UPDATE ON empresas  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_clientes_updated  BEFORE UPDATE ON clientes  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_turnos_updated    BEFORE UPDATE ON turnos    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_deudas_updated    BEFORE UPDATE ON deudas    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_productos_updated BEFORE UPDATE ON productos FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- FUNCIÓN: actualizar stats del cliente al completar turno
-- ============================================================
CREATE OR REPLACE FUNCTION actualizar_stats_cliente()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.estado = 'completado' AND (OLD.estado IS DISTINCT FROM 'completado') THEN
    UPDATE clientes SET
      total_visitas  = total_visitas + 1,
      total_gastado  = total_gastado + COALESCE(NEW.precio_cobrado, 0),
      ultima_visita  = NEW.fecha,
      actualizado_en = NOW()
    WHERE id = NEW.cliente_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_turno_completado
  AFTER UPDATE ON turnos
  FOR EACH ROW EXECUTE FUNCTION actualizar_stats_cliente();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Cada barbería solo ve sus propios datos
-- ============================================================
ALTER TABLE empresas   ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios   ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes   ENABLE ROW LEVEL SECURITY;
ALTER TABLE servicios  ENABLE ROW LEVEL SECURITY;
ALTER TABLE turnos     ENABLE ROW LEVEL SECURITY;
ALTER TABLE caja       ENABLE ROW LEVEL SECURITY;
ALTER TABLE deudas     ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos  ENABLE ROW LEVEL SECURITY;

-- Política: cada usuario accede solo a su empresa
CREATE POLICY "empresa_owner" ON empresas
  FOR ALL USING (owner_id = auth.uid());

CREATE POLICY "empresa_clientes" ON clientes
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

CREATE POLICY "empresa_servicios" ON servicios
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

CREATE POLICY "empresa_turnos" ON turnos
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

CREATE POLICY "empresa_caja" ON caja
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

CREATE POLICY "empresa_deudas" ON deudas
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

CREATE POLICY "empresa_productos" ON productos
  FOR ALL USING (
    empresa_id IN (SELECT id FROM empresas WHERE owner_id = auth.uid())
  );

-- ============================================================
-- REALTIME: habilitar cambios en vivo
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE turnos;
ALTER PUBLICATION supabase_realtime ADD TABLE caja;
ALTER PUBLICATION supabase_realtime ADD TABLE deudas;
ALTER PUBLICATION supabase_realtime ADD TABLE clientes;

-- ============================================================
-- DATOS DE EJEMPLO (opcional — borrá si no querés datos demo)
-- ============================================================
-- NOTA: Primero creá una cuenta en la app, luego
-- reemplazá 'TU-AUTH-UUID' con el UUID de tu usuario en
-- Supabase > Authentication > Users

/*
INSERT INTO empresas (owner_id, nombre, slug, email, telefono, ciudad, provincia, plan)
VALUES ('TU-AUTH-UUID', 'Barbería La Vieja Escuela', 'la-vieja-escuela', 'marcos@demo.com', '341-555-0101', 'Rosario', 'Santa Fe', 'pro');
*/

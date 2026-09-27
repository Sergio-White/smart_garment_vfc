# Backend del chatbot de bitácora — CardioSense (arquitectura híbrida)

Servidor que combina dos piezas:

1. **Clasificadores locales propios** (`classifier.py`, modelos en `models/`,
   entrenados con `train.py` a partir de `data/`): detectan síntoma físico y
   estado de ánimo a partir del texto del usuario. Corren en este servidor,
   sin costo por uso y sin depender de un tercero. Sus métricas reales están
   en `reporte_metricas.txt` (F1-macro 0.89 en síntomas, 0.68 en ánimo).
2. **El LLM (Claude)**, que solo se encarga de sostener la conversación de
   forma natural y de pedir los datos que los clasificadores no pueden dar
   (intensidad 1-10, qué estaba haciendo el usuario). Nunca decide en
   solitario si hay un síntoma preocupante: ese aviso lo dispara el propio
   servidor de forma determinística en cuanto el clasificador de síntomas
   detecta algo de la lista `SINTOMAS_QUE_REQUIEREN_AVISO` con confianza
   suficiente — así ese aviso no depende de que el modelo de lenguaje "se
   acuerde" de decirlo.

La API key nunca está guardada dentro de la app Flutter, solo aquí como
variable de entorno.

## 1. Obtener una API key

Crea una cuenta en https://console.anthropic.com y genera una API key. **Este servicio
tiene costo por uso** (se cobra por tokens procesados) — revisa los precios del modelo
`claude-haiku-4-5` en la consola antes de hacer pruebas extensas con usuarios reales, y
considera meter este gasto recurrente al análisis de viabilidad económica del proyecto.
Como ahora los clasificadores locales absorben la parte de extracción de datos, el LLM
se usa solo para la parte conversacional — esto mantiene el consumo de tokens bajo.

## 2. Correrlo en tu computadora (para desarrollo/demo)

```bash
cd backend
python -m venv venv
source venv/bin/activate        # En Windows: venv\Scripts\activate
pip install -r requirements.txt

export ANTHROPIC_API_KEY=sk-ant-tu-key-aqui   # En Windows (cmd): set ANTHROPIC_API_KEY=...

uvicorn main:app --reload --port 8000
```

Prueba que funciona abriendo http://127.0.0.1:8000 en el navegador (debe responder
`{"status":"ok", ...}`), o con:

```bash
curl -X POST http://127.0.0.1:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "hoy me sentí muy estresado en el trabajo", "history": []}'
```

La respuesta ahora incluye, además de `reply` y `extraction`, el bloque
`clasificacion_local` (lo que detectaron tus propios modelos) y `aviso_medico`
(booleano, si se disparó el aviso automático).

## 3. Volver a entrenar los clasificadores (si agregan más ejemplos a los CSV)

```bash
cd backend
python train.py
```

Esto regenera `models/modelo_sintomas.pkl`, `models/modelo_animo.pkl` y
`reporte_metricas.txt`. **Nota:** `train.py` guarda los `.pkl` en la carpeta
`backend/` (junto a él); si los vuelves a generar, muévelos a `backend/models/`
para que `classifier.py` los encuentre, o ajusta `MODELS_DIR` en ese archivo.

## 4. Cómo lo alcanza la app Flutter

- **Emulador de Android**: usa `http://10.0.2.2:8000` (así el emulador ve tu máquina).
- **Simulador de iOS, Flutter web o escritorio**: usa `http://127.0.0.1:8000` directo.
- **Celular físico**: no puede ver "localhost" de tu compu. Opciones: conectarlo a la
  misma red Wi-Fi y usar la IP local de tu computadora (ej. `http://192.168.1.X:8000`),
  o mejor, desplegar el backend (paso 5) y usar esa URL pública desde cualquier lado.

Este valor se configura en `lib/chatbot_bitacora.dart`, constante `kBackendBaseUrl`.

## 5. Desplegarlo para que no dependa de tu computadora (recomendado para las pruebas piloto)

Cuando ya quieran probar con usuarios reales fuera del salón de clases, este mismo
código de FastAPI se puede desplegar gratis en servicios como **Render** o **Railway**:

1. Suben esta carpeta `backend/` a un repositorio de GitHub (incluyendo `models/*.pkl`).
2. Crean un "Web Service" en Render apuntando a ese repo.
3. Comando de arranque: `uvicorn main:app --host 0.0.0.0 --port $PORT`
4. Agregan `ANTHROPIC_API_KEY` como variable de entorno en el panel de Render (nunca
   en el código).
5. Render les da una URL pública (algo como `https://cardiosense-backend.onrender.com`);
   esa es la que ponen en `kBackendBaseUrl` en la app.

## Notas de seguridad y privacidad para el documento del proyecto

- La API key vive únicamente en este servidor (variable de entorno), nunca en el
  código de la app ni en el repositorio.
- Los mensajes del usuario (posibles datos de salud) se envían a la API de Anthropic
  para la parte conversacional; esto debe declararse en el aviso de privacidad de la
  app, ya que en México los datos de salud son "datos personales sensibles" según la
  LFPDPPP. La clasificación de síntoma/ánimo, en cambio, ocurre localmente en este
  servidor con los modelos propios, sin salir hacia un tercero.
- Este backend es un prototipo mínimo para fines de proyecto integrador: no incluye
  autenticación de usuarios ni límites de uso (rate limiting). Antes de un despliegue
  con usuarios reales fuera del piloto controlado, se recomienda agregar ambas cosas.

"""
Backend intermediario para el chatbot de bitácora de CardioSense — versión híbrida.

Arquitectura híbrida (por qué está dividido así):
  1. Los CLASIFICADORES LOCALES (classifier.py, entrenados por el equipo con
     TF-IDF + SVM/Regresión Logística) leen el mensaje del usuario y detectan
     síntoma físico y estado de ánimo. Son rápidos, gratis, deterministas, y
     son el componente de IA "propio" del proyecto: se puede mostrar su
     matriz de confusión y sus métricas reales (reporte_metricas.txt).
  2. El LLM (Claude) se dedica solo a lo que sí requiere lenguaje natural:
     sostener una conversación cálida, pedir el dato que aún falte
     (intensidad 1-10, qué estaba haciendo) y despedirse con naturalidad.
  3. El aviso de "esto no es diagnóstico médico, busca atención profesional"
     ante un síntoma físico relevante NO depende de que el LLM se acuerde de
     decirlo: lo dispara este servidor de forma determinística en cuanto el
     clasificador detecta un síntoma de la lista SINTOMAS_QUE_REQUIEREN_AVISO
     con confianza suficiente.

La API key del LLM sigue viviendo únicamente aquí (variable de entorno),
nunca en la app Flutter.

Ejecutar en local:
    pip install -r requirements.txt
    export ANTHROPIC_API_KEY=sk-ant-...      (en Windows: set ANTHROPIC_API_KEY=...)
    uvicorn main:app --reload --port 8000

Endpoint único: POST /chat
Body:      {"message": "texto del usuario", "history": [{"role": "user"|"assistant", "content": "..."}]}
Respuesta: {
  "reply": "texto de respuesta del asistente",
  "extraction": {...} | null,          # evento listo para guardar en la bitácora
  "clasificacion_local": {             # transparencia: lo que detectó TU modelo
     "sintoma": {"etiqueta": "...", "confianza": 0.0},
     "animo":   {"etiqueta": "...", "confianza": 0.0}
  },
  "aviso_medico": true | false          # disparado de forma determinística
}
"""

import os
from typing import Any, Optional

import httpx
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from classifier import (
    clasificar_sintoma,
    clasificar_animo,
    ETIQUETAS_SINTOMA_LEGIBLE,
    MAPEO_ANIMO_A_SENTIMIENTO_APP,
    SINTOMAS_QUE_REQUIEREN_AVISO,
)

app = FastAPI(title="CardioSense Chatbot Backend (híbrido)")

# En producción, cambia allow_origins=["*"] por el dominio real de tu app/servidor.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "")
ANTHROPIC_URL = "https://api.anthropic.com/v1/messages"
# Haiku: modelo pequeño y económico, adecuado para una conversación breve de bitácora.
MODEL = "claude-haiku-4-5-20251001"

SENTIMIENTOS_VALIDOS = ["Estrés", "Enojo", "Tristeza", "Miedo", "Alegría", "Otro"]
ACTIVIDADES_VALIDAS = [
    "Trabajando sentado",
    "Caminando",
    "Descansando",
    "Haciendo ejercicio",
    "Comiendo",
    "Otro",
]

AVISO_MEDICO_TEXTO = (
    "Antes de seguir: esto que me cuentas suena a un síntoma físico que vale la pena "
    "tomar en serio. Recuerda que no soy una herramienta de diagnóstico — si el "
    "síntoma persiste o se siente fuerte, lo mejor es buscar atención médica."
)

TOOLS = [
    {
        "name": "registrar_evento",
        "description": (
            "Guarda el evento de bitácora emocional una vez que ya se conversó "
            "lo suficiente con el usuario para tener los datos necesarios."
        ),
        "input_schema": {
            "type": "object",
            "properties": {
                "estado_alterado": {
                    "type": "boolean",
                    "description": "Si el estado de ánimo del usuario se alteró.",
                },
                "sentimientos": {
                    "type": "array",
                    "items": {"type": "string", "enum": SENTIMIENTOS_VALIDOS},
                },
                "intensidad": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 10,
                    "description": "Intensidad percibida del 1 al 10.",
                },
                "actividad": {"type": "string", "enum": ACTIVIDADES_VALIDAS},
                "nota": {
                    "type": "string",
                    "description": "Resumen breve en palabras del propio usuario, o vacío.",
                },
            },
            "required": ["estado_alterado", "sentimientos", "intensidad", "actividad"],
        },
    }
]


class ChatRequest(BaseModel):
    message: str
    history: list[dict[str, Any]] = []


class PrediccionOut(BaseModel):
    etiqueta: str
    confianza: float


class ClasificacionLocal(BaseModel):
    sintoma: PrediccionOut
    animo: PrediccionOut


class ChatResponse(BaseModel):
    reply: str
    extraction: Optional[dict[str, Any]] = None
    clasificacion_local: ClasificacionLocal
    aviso_medico: bool


def _construir_pista_para_el_llm(
    pred_sintoma, pred_animo, disparar_aviso: bool
) -> str:
    """Arma el bloque de contexto que se agrega al system prompt en cada turno,
    con lo que detectaron los clasificadores locales. El LLM lo usa como apoyo,
    no como verdad absoluta (por eso se distingue confiable / no confiable)."""

    sentimiento_sugerido = MAPEO_ANIMO_A_SENTIMIENTO_APP.get(pred_animo.etiqueta)

    partes = ["Contexto detectado por el clasificador local para el último mensaje del usuario:"]

    if pred_sintoma.confiable:
        partes.append(
            f"- Síntoma físico probable: {ETIQUETAS_SINTOMA_LEGIBLE[pred_sintoma.etiqueta]} "
            f"(confianza {pred_sintoma.confianza:.2f})."
        )
    else:
        partes.append(
            f"- El clasificador de síntomas no está seguro (mejor opción: "
            f"{ETIQUETAS_SINTOMA_LEGIBLE[pred_sintoma.etiqueta]}, confianza baja "
            f"{pred_sintoma.confianza:.2f}). No lo des por hecho, pregunta si notas algo físico."
        )

    if pred_animo.confiable and sentimiento_sugerido:
        partes.append(
            f"- Estado de ánimo probable: {pred_animo.etiqueta} "
            f"(mapea a sentimiento '{sentimiento_sugerido}' en la app, confianza {pred_animo.confianza:.2f})."
        )
    elif pred_animo.confiable and sentimiento_sugerido is None:
        partes.append(
            f"- Estado de ánimo probable: {pred_animo.etiqueta} (confianza {pred_animo.confianza:.2f}), "
            "es decir, sin alteración emocional relevante."
        )
    else:
        partes.append(
            f"- El clasificador de ánimo no está seguro (confianza {pred_animo.confianza:.2f}). "
            "Pregunta abiertamente cómo se siente en vez de asumir."
        )

    if disparar_aviso:
        partes.append(
            "- Ya se le mostró al usuario un aviso automático de que esto no es diagnóstico "
            "médico. Sé empático y no lo repitas de forma robótica, pero tampoco lo minimices."
        )

    partes.append(
        "Usa esta información como apoyo para no repetir preguntas obvias, pero SIEMPRE "
        "confirma con tus propias palabras en vez de asumir que el clasificador tiene la "
        "razón. Sigue faltando obtener, si aún no las tienes: intensidad (1-10) y qué estaba "
        "haciendo el usuario, antes de llamar a registrar_evento."
    )

    return "\n".join(partes)


def _system_prompt(pista_clasificador: str) -> str:
    return f"""Eres el asistente conversacional de bitácora de CardioSense, una app de
monitoreo de bienestar cardiovascular. IMPORTANTE: no eres una herramienta de diagnóstico
médico, no diagnostiques ni receta nada.

Tu trabajo es platicar de forma breve, cálida y natural para entender cómo se siente el
usuario en este momento, sin que se sienta como llenar un formulario. Haz como máximo 1 o 2
preguntas de seguimiento antes de registrar el evento (no interrogues de golpe).

Cuando ya tengas información suficiente sobre: si su estado de ánimo se alteró o no, qué
sintió, qué tan intenso fue (1 a 10) y qué estaba haciendo, usa la herramienta
"registrar_evento" para guardarlo.

Reglas estrictas:
- El campo "sentimientos" solo puede contener valores de esta lista: {SENTIMIENTOS_VALIDOS}.
- El campo "actividad" solo puede contener un valor de esta lista: {ACTIVIDADES_VALIDAS}.
- Si el usuario menciona un síntoma físico relevante, sé empático y recuérdale con calidez
  que esta app no diagnostica y que ante síntomas importantes debe buscar atención médica.
  Nunca minimices un síntoma físico que suene serio.
- Sé breve: 1 a 3 oraciones por mensaje, tono cercano, nunca clínico.

{pista_clasificador}
"""


@app.get("/")
async def root():
    return {"status": "ok", "service": "cardiosense-chatbot-backend-hibrido"}


@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    if not ANTHROPIC_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="Falta configurar la variable de entorno ANTHROPIC_API_KEY en el servidor.",
        )

    # 1) Clasificadores locales propios, sobre el mensaje que acaba de llegar.
    pred_sintoma = clasificar_sintoma(req.message)
    pred_animo = clasificar_animo(req.message)

    disparar_aviso = (
        pred_sintoma.confiable and pred_sintoma.etiqueta in SINTOMAS_QUE_REQUIEREN_AVISO
    )

    pista_clasificador = _construir_pista_para_el_llm(pred_sintoma, pred_animo, disparar_aviso)

    # 2) El LLM solo conversa, apoyado por la pista de los clasificadores locales.
    messages = list(req.history) + [{"role": "user", "content": req.message}]

    async with httpx.AsyncClient(timeout=30) as client:
        try:
            r = await client.post(
                ANTHROPIC_URL,
                headers={
                    "x-api-key": ANTHROPIC_API_KEY,
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json",
                },
                json={
                    "model": MODEL,
                    "max_tokens": 500,
                    "system": _system_prompt(pista_clasificador),
                    "messages": messages,
                    "tools": TOOLS,
                },
            )
            r.raise_for_status()
        except httpx.HTTPStatusError as exc:
            raise HTTPException(
                status_code=502, detail=f"Error del proveedor del LLM: {exc.response.text}"
            ) from exc
        except httpx.RequestError as exc:
            raise HTTPException(
                status_code=502, detail=f"No se pudo contactar al LLM: {exc}"
            ) from exc

        data = r.json()

    reply_text = ""
    extraction: Optional[dict[str, Any]] = None

    for block in data.get("content", []):
        if block.get("type") == "text":
            reply_text += block.get("text", "")
        elif block.get("type") == "tool_use" and block.get("name") == "registrar_evento":
            extraction = block.get("input")
            if not reply_text:
                reply_text = "Gracias por contarme, ya lo registré en tu bitácora."

    if not reply_text and not extraction:
        reply_text = "¿Podrías contarme un poco más sobre cómo te sientes?"

    # 3) El aviso médico se antepone de forma determinística, no depende del LLM.
    if disparar_aviso:
        reply_text = f"{AVISO_MEDICO_TEXTO}\n\n{reply_text}"

    return ChatResponse(
        reply=reply_text,
        extraction=extraction,
        clasificacion_local=ClasificacionLocal(
            sintoma=PrediccionOut(etiqueta=pred_sintoma.etiqueta, confianza=pred_sintoma.confianza),
            animo=PrediccionOut(etiqueta=pred_animo.etiqueta, confianza=pred_animo.confianza),
        ),
        aviso_medico=disparar_aviso,
    )

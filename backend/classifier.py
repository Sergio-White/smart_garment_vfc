"""
classifier.py
Carga los clasificadores locales (TF-IDF + SVM/Regresión Logística) entrenados
con train.py y expone funciones simples para usarlos desde main.py.

Estos modelos son el componente de IA propio del proyecto: entrenado por el
equipo, con sus propios datos y métricas (ver reporte_metricas.txt). Corren
localmente en este servidor, sin costo por uso y sin depender de un tercero.
"""

from pathlib import Path
from dataclasses import dataclass

import joblib

MODELS_DIR = Path(__file__).parent / "models"

_modelo_sintomas = joblib.load(MODELS_DIR / "modelo_sintomas.pkl")
_modelo_animo = joblib.load(MODELS_DIR / "modelo_animo.pkl")

# Umbral de confianza por debajo del cual NO se le pide al LLM que confíe
# en la predicción del clasificador; simplemente se le indica que pregunte.
UMBRAL_CONFIANZA = 0.45

# Síntomas físicos que ameritan el aviso de "esto no es diagnóstico médico,
# busca atención profesional" de forma determinística, sin depender de que
# el LLM se acuerde de decirlo.
SINTOMAS_QUE_REQUIEREN_AVISO = {"dolor_pecho", "falta_aire", "palpitaciones", "mareo"}

# Traducción de las etiquetas del clasificador de síntomas a texto legible.
ETIQUETAS_SINTOMA_LEGIBLE = {
    "dolor_pecho": "Dolor en el pecho",
    "falta_aire": "Falta de aire",
    "palpitaciones": "Palpitaciones",
    "mareo": "Mareo",
    "cansancio": "Cansancio",
    "dolor_cabeza": "Dolor de cabeza",
    "sin_sintoma": "Sin síntoma físico relevante",
}

# El clasificador de ánimo se entrenó con sus propias 5 categorías
# (ansiedad, calma, enojo, neutral, tristeza), que NO son exactamente las
# mismas que usa el formulario original de la app (Estrés, Enojo, Tristeza,
# Miedo, Alegría, Otro). Este mapeo hace la conversión explícita en un solo
# lugar, para no perder esa correspondencia dentro de la lógica del chat.
MAPEO_ANIMO_A_SENTIMIENTO_APP = {
    "ansiedad": "Estrés",
    "enojo": "Enojo",
    "tristeza": "Tristeza",
    "calma": None,     # No es una alteración; no se marca ningún "sentimiento".
    "neutral": None,
}


@dataclass
class PrediccionClasificador:
    etiqueta: str
    confianza: float
    confiable: bool  # True si confianza >= UMBRAL_CONFIANZA


def clasificar_sintoma(texto: str) -> PrediccionClasificador:
    etiqueta = str(_modelo_sintomas.predict([texto])[0])
    confianza = float(_modelo_sintomas.predict_proba([texto]).max())
    return PrediccionClasificador(etiqueta, confianza, confianza >= UMBRAL_CONFIANZA)


def clasificar_animo(texto: str) -> PrediccionClasificador:
    etiqueta = str(_modelo_animo.predict([texto])[0])
    confianza = float(_modelo_animo.predict_proba([texto]).max())
    return PrediccionClasificador(etiqueta, confianza, confianza >= UMBRAL_CONFIANZA)

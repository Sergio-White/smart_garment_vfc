"""
train.py
Entrena dos clasificadores de texto (síntoma físico y estado de ánimo)
a partir de los CSV en data/, usando TF-IDF + Regresión Logística.

Uso:
    python train.py

Genera:
    modelo_sintomas.pkl
    modelo_animo.pkl
    reporte_metricas.txt   (para pegar en el capítulo de resultados de la tesis)
"""

import csv
import joblib
from pathlib import Path

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split, StratifiedGroupKFold
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report, confusion_matrix, f1_score

DATA_DIR = Path(__file__).parent / "data"
OUT_DIR = Path(__file__).parent
MODELS_DIR = Path(__file__).parent / "models"
MODELS_DIR.mkdir(exist_ok=True)

DATASETS = {
    "sintomas": DATA_DIR / "dataset_sintomas.csv",
    "animo": DATA_DIR / "dataset_animo.csv",
}


def cargar_csv(ruta: Path):
    textos, etiquetas, grupos = [], [], []
    with open(ruta, encoding="utf-8") as f:
        lector = csv.DictReader(f)
        for fila in lector:
            textos.append(fila["text"])
            etiquetas.append(fila["label"])
            # 'group' identifica de qué frase núcleo salió cada variante.
            # Si no existe la columna, cada fila es su propio grupo (comportamiento normal).
            grupos.append(fila.get("group", fila["text"]))
    return textos, etiquetas, grupos


def entrenar_clasificador(nombre: str, ruta_csv: Path, reporte_lines: list):
    print(f"\n{'=' * 60}")
    print(f"Entrenando clasificador: {nombre}")
    print(f"{'=' * 60}")

    textos, etiquetas, grupos = cargar_csv(ruta_csv)
    print(f"Total de ejemplos: {len(textos)}")

    n_grupos_unicos = len(set(grupos))
    if n_grupos_unicos < len(textos):
        # Hay frases núcleo con varias variantes -> dividir por grupo
        # para que ninguna variante de la misma frase base quede a la vez
        # en entrenamiento y en prueba (evita fuga de datos / accuracy inflado).
        print(f"Dividiendo por grupo, estratificado por clase ({n_grupos_unicos} frases núcleo detectadas)")
        # StratifiedGroupKFold asegura que ninguna variante de la misma frase base
        # quede repartida entre train/test, Y que cada clase tenga representación
        # proporcional en ambos conjuntos (a diferencia de GroupShuffleSplit simple).
        n_splits = 5  # equivale aprox. a un 80/20
        splitter = StratifiedGroupKFold(n_splits=n_splits, shuffle=True, random_state=42)
        idx_train, idx_test = next(splitter.split(textos, etiquetas, groups=grupos))
        X_train = [textos[i] for i in idx_train]
        X_test = [textos[i] for i in idx_test]
        y_train = [etiquetas[i] for i in idx_train]
        y_test = [etiquetas[i] for i in idx_test]
    else:
        X_train, X_test, y_train, y_test = train_test_split(
            textos, etiquetas,
            test_size=0.2,
            random_state=42,
            stratify=etiquetas,
        )

    # Comparamos dos clasificadores sobre el MISMO split, y nos quedamos con el
    # que tenga mejor F1-macro (más justo que accuracy simple con clases balanceadas).
    candidatos = {
        "logistic_regression": LogisticRegression(max_iter=1000, class_weight="balanced"),
        "svm_lineal": SVC(kernel="linear", probability=True, class_weight="balanced"),
    }

    mejor_nombre, mejor_pipeline, mejor_f1 = None, None, -1
    resultados_comparacion = []

    for clf_nombre, clf in candidatos.items():
        pipeline = Pipeline([
            ("tfidf", TfidfVectorizer(
                lowercase=True,
                ngram_range=(1, 2),
                min_df=1,
            )),
            ("clf", clf),
        ])
        pipeline.fit(X_train, y_train)
        y_pred = pipeline.predict(X_test)
        f1_macro = f1_score(y_test, y_pred, average="macro", zero_division=0)
        reporte_clf = classification_report(y_test, y_pred, zero_division=0)

        print(f"\n--- {clf_nombre} (F1-macro: {f1_macro:.3f}) ---")
        print(reporte_clf)

        resultados_comparacion.append((clf_nombre, f1_macro, reporte_clf))

        if f1_macro > mejor_f1:
            mejor_f1 = f1_macro
            mejor_nombre = clf_nombre
            mejor_pipeline = pipeline

    print(f"\n>>> Mejor modelo para '{nombre}': {mejor_nombre} (F1-macro: {mejor_f1:.3f})")

    pipeline = mejor_pipeline
    y_pred = pipeline.predict(X_test)
    reporte = classification_report(y_test, y_pred, zero_division=0)
    matriz = confusion_matrix(y_test, y_pred, labels=sorted(set(etiquetas)))

    print("\nMatriz de confusión del modelo ganador (filas=real, columnas=predicho):")
    print(sorted(set(etiquetas)))
    print(matriz)

    # Guardar el modelo entrenado
    ruta_modelo = MODELS_DIR / f"modelo_{nombre}.pkl"
    joblib.dump(pipeline, ruta_modelo)
    print(f"\nModelo guardado en: {ruta_modelo}")

    # Acumular texto para el reporte de métricas (útil para la tesis)
    reporte_lines.append(f"\n{'=' * 60}\nClasificador: {nombre}\n{'=' * 60}\n")
    reporte_lines.append(f"Total de ejemplos: {len(textos)}\n")
    reporte_lines.append(f"Ejemplos de entrenamiento: {len(X_train)} | Ejemplos de prueba: {len(X_test)}\n\n")
    reporte_lines.append("Comparación de modelos sobre el mismo split:\n")
    for clf_nombre, f1_macro, reporte_clf in resultados_comparacion:
        reporte_lines.append(f"\n[{clf_nombre}] F1-macro: {f1_macro:.3f}\n")
        reporte_lines.append(reporte_clf)
    reporte_lines.append(f"\n>>> Modelo ganador: {mejor_nombre} (F1-macro: {mejor_f1:.3f})\n\n")
    reporte_lines.append("Reporte detallado del modelo ganador:\n")
    reporte_lines.append(reporte)
    reporte_lines.append("\nMatriz de confusión (filas=real, columnas=predicho):\n")
    reporte_lines.append(f"Etiquetas: {sorted(set(etiquetas))}\n")
    reporte_lines.append(f"{matriz}\n")


def probar_ejemplo(nombre: str):
    """Carga un modelo guardado y prueba una frase de ejemplo, para verificar rápido."""
    ruta_modelo = MODELS_DIR / f"modelo_{nombre}.pkl"
    pipeline = joblib.load(ruta_modelo)
    ejemplos = {
        "sintomas": ["siento que me falta el aire y el corazón me late rápido"],
        "animo": ["hoy ando muy nervioso y con los pensamientos acelerados"],
    }
    frase = ejemplos[nombre][0]
    pred = pipeline.predict([frase])[0]
    proba = pipeline.predict_proba([frase]).max()
    print(f"\n[Prueba manual - {nombre}] '{frase}' -> {pred} (confianza: {proba:.2f})")


if __name__ == "__main__":
    reporte_lines = []

    for nombre, ruta_csv in DATASETS.items():
        if not ruta_csv.exists():
            print(f"ATENCIÓN: no se encontró {ruta_csv}. Sáltalo o revisa la ruta.")
            continue
        entrenar_clasificador(nombre, ruta_csv, reporte_lines)

    # Guardar reporte de métricas en texto plano
    ruta_reporte = OUT_DIR / "reporte_metricas.txt"
    with open(ruta_reporte, "w", encoding="utf-8") as f:
        f.writelines(reporte_lines)
    print(f"\nReporte de métricas guardado en: {ruta_reporte}")

    # Pruebas manuales rápidas
    for nombre in DATASETS:
        if (MODELS_DIR / f"modelo_{nombre}.pkl").exists():
            probar_ejemplo(nombre)

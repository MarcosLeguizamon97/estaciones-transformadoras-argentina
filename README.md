# Análisis de Consumo y Red de Energía en la Provincia de Santa Fe

Repositorio para el análisis estadístico y espacial de la infraestructura eléctrica y el consumo energético en la provincia de Santa Fe, desarrollado en **RStudio** y sincronizado con control de versiones en **Git/GitHub**.

---

## 📂 Estructura del Proyecto

* `data/`: Contiene los datasets oficiales descargados (`.csv`).
* `scripts/`: Código en R para la limpieza, procesamiento espacial y generación de mapas interactivos.
* `outputs/`: Gráficos, salidas procesadas y mapas exportados.

---

## 📊 Diccionario de Datos: Estaciones Transformadoras de Alta Tensión

El dataset oficial utiliza las siguientes variables para describir la infraestructura eléctrica:

| Variable | Tipo / Formato | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| `nombre` | Carácter (`chr`) | Nombre oficial de la estación transformadora. | `RIO TURBIO` |
| `id` | Carácter (`chr`) | Identificador único o sigla asignada a la estación. | `RT` |
| `propiedad` | Carácter (`chr`) | Entidad o empresa propietaria de las instalaciones. | `CENTRAL TERMICA...` |
| `concesion` | Carácter (`chr`) | Empresa concesionaria operadora del transporte eléctrico. | `TRANSPA S.A.` |
| `potencia_instalada_mv` | Numérico (`dbl`) | Potencia total instalada expresada en Megavoltiamperios (MVA). | `400` |
| `fecha_puesta_servicio` | Fecha (`date`) | Fecha en la que la estación entró en servicio operativo (formato AAAA-MM-DD). | `2013-01-01` |
| `tension_entrada` | Carácter (`chr`) | Nivel de tensión de entrada o alta tensión en kilovoltios (kV). | `500 kV` |
| `tension_salida` | Carácter (`chr`) | Nivel de tensión de salida de la estación en kilovoltios (kV). | `132 kV` |
| `geojson` | Carácter (`chr`) | Geometría de la estación expresada en estructura GeoJSON. | `{...}` |
| `geom` | Carácter (`chr`) | Coordenadas espaciales en formato de texto WKT (Well-Known Text). | `POINT (-72.3 -51.5)` |

---

## 🛠️ Tecnologías y Librerías Utilizadas

* **R / RStudio:** Entorno de desarrollo para computación estadística.
* **`tidyverse`:** Manipulación y limpieza de datos (`dplyr`, `stringr`, `readr`).
* **`sf`:** Manejo y transformación de datos espaciales.
* **`leaflet`:** Generación de mapas interactivos basados en web.

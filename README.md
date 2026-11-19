# Análisis de Infraestructura de Transporte Eléctrico en Argentina

Repositorio oficial para el análisis estadístico, procesamiento espacial y visualización de la infraestructura de transporte de energía eléctrica en Argentina, enfocado en las **Estaciones Transformadoras de Alta Tensión (AT)**. El proyecto está desarrollado íntegramente en **RStudio** y sincronizado mediante control de versiones con **Git y GitHub**.

---

## 📋 Fuente de Datos y Metainformación

Los datos utilizados provienen de fuentes oficiales abiertas de la Secretaría de Energía de la Nación:

* **Datos del Organismo :** Secretaría de Energía. Subsecretaría de Eficiencia e Información Energética. Dirección Nacional de Información Energética.
* **Nombre del Dataset:** Transporte Eléctrico AT Estaciones Transformadoras.
* **Descripción:** Estaciones transformadoras de Alta Tensión bajo la norma ISO 19126 (*PowerSupplies*), correspondientes a los conceptos de producción, transporte y distribución de energía eléctrica.
* **Temas y Etiquetas:** Información Geográfica, Transporte de Energía Eléctrica, Alta Tensión, Estaciones Transformadoras.
* **Licencia:** Creative Commons Attribution 4.0.
* **Frecuencia de Actualización:** Eventual.
* * **Última Actualización / Cambio del Dataset:** 5 de octubre de 2026.

## Visualización Interactiva
👉 [Abrir Mapa de Estaciones Transformadoras en el Navegador](https://marcosleguizamon97.github.io/estaciones-transformadoras-argentina/)

## Fuentes de Datos
* **Dataset Oficial:** [Transporte Eléctrico AT - Estaciones Transformadoras](http://datos.energia.gob.ar/dataset/transporte-electrico-at-estaciones-transformadoras) - Secretaría de Energía de la Nación.
---

## 📂 Estructura del Proyecto

* `data/`: Contiene los datasets oficiales descargados en formato `.csv` y archivos espaciales.
* `scripts/`: Códigos fuente en R para la limpieza, extracción de coordenadas desde objetos `geojson`, transformación espacial (`sf`) y generación de mapas interactivos (`leaflet`).
* `outputs/`: Productos finales, mapas exportados y gráficos estadísticos.

---

## 📊 Diccionario de Datos

El dataset cuenta con 10 variables principales que describen las características técnicas y operativas de cada estación transformadora:

| Variable | Tipo / Formato | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| `nombre` | Carácter (`chr`) | Nombre oficial de la estación transformadora de alta tensión. | `RIO TURBIO` |
| `id` | Carácter (`chr`) | Identificador único o sigla abreviada de la estación. | `RT` |
| `propiedad` | Carácter (`chr`) | Entidad, empresa o central propietaria de las instalaciones. | `CENTRAL TÉRMICA RÍO TURBIO` |
| `concesion` | Carácter (`chr`) | Empresa concesionaria operadora del transporte eléctrico. | `TRANSPA S.A.` |
| `potencia_instalada_mv` | Numérico (`dbl`) | Potencia total instalada expresada en Megavoltiamperios (MVA). | `400.0` |
| `fecha_puesta_servicio` | Fecha (`date`) | Fecha de entrada en servicio operativo (formato AAAA-MM-DD). | `2013-01-01` |
| `tension_entrada` | Carácter (`chr`) | Nivel de tensión de entrada o alta tensión en kilovoltios (kV). | `220` |
| `tension_salida` | Carácter (`chr`) | Nivel(es) de tensión de salida de la estación en kilovoltios (kV). | `13.2 \| 33` |
| `geojson` | Carácter (`chr`) | Estructura en texto JSON con el tipo de geometría y coordenadas. | `{"type":"MultiPoint",...}` |
| `geom` | Carácter (`chr`) | Binario espacial (WKB) utilizado por el motor GIS por defecto. | `0104000020...` |

---

## 🛠️ Tecnologías y Librerías Utilizadas

* **R / RStudio:** Entorno principal para el análisis estadístico y computación espacial.
* **`tidyverse`:** Manipulación, limpieza de datos y expresiones regulares (`dplyr`, `stringr`, `readr`).
* **`sf`:** Gestión de clases y operaciones de datos espaciales (Sistema de Proyección EPSG:4326).
* **`leaflet`:** Desarrollo de mapas interactivos web con múltiples capas base (Claro, OpenStreetMap, Satélite).

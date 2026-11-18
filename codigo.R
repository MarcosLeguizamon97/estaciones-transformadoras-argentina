# Cargar librerías necesarias
install.packages("sf")
install.packages("leaflet")

library(tidyverse)
library(sf)
library(leaflet)
library(tidyverse)

estaciones <- read_csv("data/transporte-elctrico-at-estaciones-transformadoras.csv") 

names(estaciones)
head(estaciones)
summary(estaciones)


# 1. Transformación: Extraer longitud y latitud directamente de la columna geojson
estaciones_nacionales <- estaciones %>%
  drop_na(geojson) %>%
  mutate(
    # Extraer los números decimales dentro del texto JSON
    coordenadas = str_extract(geojson, "\\[-?[0-9.]+,\\s*-?[0-9.]+\\]"),
    coords_limpias = str_remove_all(coordenadas, "\\[|\\]"),
    # Separar en longitud y latitud
    lon = as.numeric(word(coords_limpias, 1, sep = ",")),
    lat = as.numeric(word(coords_limpias, 2, sep = ","))
  ) %>%
  drop_na(lon, lat) %>%
  # 2. Convertir a objeto espacial sf para todo el país
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# 2. Crear el mapa interactivo
leaflet(estaciones_nacionales) %>%
  # Centrar de entrada en una vista general óptima (ej. zona núcleo / Buenos Aires con zoom 6)
  setView(lng = -60.0, lat = -36.0, zoom = 6) %>%
  
  # Capas base
  addTiles(group = "OpenStreetMap") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
  
  # Marcadores estilizados con iconos de alta tensión/electricidad
  addAwesomeMarkers(
    icon = makeAwesomeIcon(
      icon = "bolt",          # Símbolo vectorial de rayo/electricidad
      library = "fa",         # FontAwesome
      markerColor = "orange", # Color del marcador de fondo
      iconColor = "white"     # Color del símbolo interno
    ),
    popup = ~paste(
      "<strong>Estación:</strong> ", nombre, "<br>",
      "<strong>Propietario:</strong> ", propiedad, "<br>",
      "<strong>Tensión Entrada:</strong> ", tension_entrada, " kV<br>",
      "<strong>Potencia:</strong> ", potencia_instalada_mv, " MVA"
    ),
    # Opción avanzada para hacer zoom automático al hacer clic en un punto (requiere una pequeña función de JS integrada)
    options = popupOptions(closeOnClick = TRUE)
  ) %>%
  
  # Controles de capas
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Satélite"),
    options = layersControlOptions(collapsed = FALSE)
  )

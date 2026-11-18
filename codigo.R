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

# 2. SVG moderno de torre de alta tensión dentro de un círculo naranja
svg_torre <- '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 36 36">
  <circle cx="18" cy="18" r="16" fill="#ff7f00" stroke="#ffffff" stroke-width="2.5"/>
  <path fill="#ffffff" d="M18 7l-4.5 18h2.2l1.4-5.5h1.8l1.4 5.5h2.2L18 7zm-3 8.5h6l-.4-1.6h-5.2l-.4 1.6zm.9 2.2h4.2l-.3-1.3h-3.6l-.3 1.3z"/>
</svg>'

icono_torre <- makeIcon(
  iconUrl = paste0("data:image/svg+xml;utf8,", URLencode(svg_torre, reserved = TRUE)),
  iconWidth = 36,
  iconHeight = 36,
  iconAnchorX = 18,
  iconAnchorY = 18,
  popupAnchorX = 0,
  popupAnchorY = -18
)

# 3. Mapa interactivo
leaflet(estaciones_nacionales) %>%
  setView(lng = -60.0, lat = -36.0, zoom = 6) %>%
  addTiles(group = "OpenStreetMap") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
  addMarkers(
    icon = icono_torre,
    popup = ~paste(
      "<div style='font-family: sans-serif; font-size: 12px; line-height: 1.4;'>",
      "<b style='color: #d95f02; font-size: 14px;'>⚡ Estación Transformadora</b><br>",
      "<strong>Nombre:</strong> ", nombre, "<br>",
      "<strong>Propietario:</strong> ", propiedad, "<br>",
      "<strong>Tensión de Entrada:</strong> ", tension_entrada, " kV<br>",
      "<strong>Potencia Instalada:</strong> ", potencia_instalada_mv, " MVA",
      "</div>"
    ),
    options = popupOptions(closeOnClick = TRUE)
  ) %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Satélite"),
    options = layersControlOptions(collapsed = FALSE)
  )

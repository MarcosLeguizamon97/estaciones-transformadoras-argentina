# Cargar librerías necesarias
install.packages("sf")
install.packages("leaflet")

library(tidyverse)
library(sf)
library(leaflet)
library(jsonlite)
library(htmlwidgets)

estaciones <- read_csv("data/transporte-elctrico-at-estaciones-transformadoras.csv")

# 1. Transformación espacial de las 323 estaciones
estaciones_nacionales <- estaciones %>%
  drop_na(geojson) %>%
  mutate(
    coordenadas = str_extract(geojson, "\\[-?[0-9.]+,\\s*-?[0-9.]+\\]"),
    coords_limpias = str_remove_all(coordenadas, "\\[|\\]"),
    lon = as.numeric(word(coords_limpias, 1, sep = ",")),
    lat = as.numeric(word(coords_limpias, 2, sep = ","))
  ) %>%
  drop_na(lon, lat) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# 2. Definir SVG e icono de torre eléctrica
svg_torre <- '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 36 36">
  <circle cx="18" cy="18" r="16" fill="#ff7f00" stroke="#ffffff" stroke-width="2.5"/>
  <path fill="#ffffff" d="M18 7l-4.5 18h2.2l1.4-5.5h1.8l1.4 5.5h2.2L18 7zm-3 8.5h6l-.4-1.6h-5.2l-.4 1.6zm.9 2.2h4.2l-.3-1.3h-3.6l-.3 1.3z"/>
</svg>'

svg_torre_uri <- paste0(
  "data:image/svg+xml;utf8,",
  URLencode(svg_torre, reserved = TRUE)
)

icono_torre <- makeIcon(
  iconUrl = svg_torre_uri,
  iconWidth = 36,
  iconHeight = 36,
  iconAnchorX = 18,
  iconAnchorY = 18,
  popupAnchorX = 0,
  popupAnchorY = -18
)

# 3. Preparar JSON con los campos del dataset
datos_json <- estaciones_nacionales %>%
  mutate(
    lon = st_coordinates(.)[, 1],
    lat = st_coordinates(.)[, 2],
    nombre_limpio = replace_na(as.character(nombre), "Sin especificar"),
    propiedad_limpia = if_else(
      is.na(propiedad) | str_squish(as.character(propiedad)) == "",
      "Sin especificar",
      str_squish(as.character(propiedad))
    ),
    concesion_limpia = if_else(
      is.na(concesion) | str_squish(as.character(concesion)) == "",
      "Sin especificar",
      str_squish(as.character(concesion))
    ),
    tension_limpia = if_else(
      is.na(tension_entrada) | str_squish(as.character(tension_entrada)) == "",
      "Sin especificar",
      paste0(str_squish(as.character(tension_entrada)), " kV")
    ),
    potencia_limpia = if_else(
      is.na(potencia_instalada_mv),
      "Sin especificar",
      paste0(potencia_instalada_mv, " MVA")
    ),
    popup_html = paste0(
      "<div style='font-family:sans-serif;font-size:12px;line-height:1.4;'>",
      "<b style='color:#d95f02;font-size:14px;'>⚡ Estación Transformadora</b><br>",
      "<strong>Nombre:</strong> ", nombre_limpio, "<br>",
      "<strong>Propietario:</strong> ", propiedad_limpia, "<br>",
      "<strong>Operador/concesionario:</strong> ", concesion_limpia, "<br>",
      "<strong>Tensión de Entrada:</strong> ", tension_limpia, "<br>",
      "<strong>Potencia Instalada:</strong> ", potencia_limpia,
      "</div>"
    )
  ) %>%
  st_drop_geometry() %>%
  select(
    nombre_limpio,
    propiedad_limpia,
    concesion_limpia,
    tension_limpia,
    lon,
    lat,
    popup_html
  ) %>%
  toJSON(
    dataframe = "rows",
    auto_unbox = TRUE,
    na = "string"
  )

# 4. Mapa con filtros interactivos
mapa_estaciones <- leaflet(estaciones_nacionales) %>%
  setView(lng = -60, lat = -36, zoom = 6) %>%
  addTiles(group = "OpenStreetMap") %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap", "Satélite"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  onRender(
    sprintf(
      '
      function(el, x) {
        var map = this;
        var datos = %s;

        var controlDiv = L.DomUtil.create(
          "div",
          "leaflet-bar leaflet-control"
        );

        controlDiv.style.background = "white";
        controlDiv.style.padding = "8px";
        controlDiv.style.borderRadius = "6px";
        controlDiv.style.boxShadow = "0 2px 6px rgba(0,0,0,.25)";
        controlDiv.style.fontFamily = "sans-serif";
        controlDiv.style.fontSize = "12px";
        controlDiv.style.minWidth = "260px";

        controlDiv.innerHTML =
          "<b>Filtrar estaciones</b>" +
          "<label style=\\"display:block;margin-top:6px\\">Operador/concesionario:</label>" +
          "<select id=\\"filtro-concesion\\" style=\\"width:100%%;margin-top:3px;padding:4px\\"></select>" +
          "<label style=\\"display:block;margin-top:6px\\">Propietario:</label>" +
          "<select id=\\"filtro-propietario\\" style=\\"width:100%%;margin-top:3px;padding:4px\\"></select>" +
          "<label style=\\"display:block;margin-top:6px\\">Tensión de entrada:</label>" +
          "<select id=\\"filtro-tension\\" style=\\"width:100%%;margin-top:3px;padding:4px\\"></select>" +
          "<div id=\\"cantidad-estaciones\\" style=\\"margin-top:7px;font-weight:bold\\"></div>" +
          "<button id=\\"limpiar-filtros\\" type=\\"button\\" " +
          "style=\\"margin-top:7px;width:100%%;padding:5px\\">Limpiar filtros</button>";

        L.DomEvent.disableClickPropagation(controlDiv);
        L.DomEvent.disableScrollPropagation(controlDiv);

        var CustomControl = L.Control.extend({
          options: { position: "topleft" },
          onAdd: function() {
            return controlDiv;
          }
        });

        map.addControl(new CustomControl());

        var capaMarcadores = L.layerGroup().addTo(map);

        var iconoTorre = L.icon({
          iconUrl: "%s",
          iconSize: [36, 36],
          iconAnchor: [18, 18],
          popupAnchor: [0, -18]
        });

        function opcionesOrdenadas(field) {
          return [...new Set(datos.map(function(d) {
            return d[field];
          }))].sort(function(a, b) {
            return String(a).localeCompare(String(b), "es");
          });
        }

        function cargarOpciones(selectId, field) {
          var select = document.getElementById(selectId);

          var opcionTodas = document.createElement("option");
          opcionTodas.value = "TODAS";
          opcionTodas.textContent = "Todas";
          select.appendChild(opcionTodas);

          opcionesOrdenadas(field).forEach(function(valor) {
            var opcion = document.createElement("option");
            opcion.value = valor;
            opcion.textContent = valor;
            select.appendChild(opcion);
          });
        }

        cargarOpciones("filtro-concesion", "concesion_limpia");
        cargarOpciones("filtro-propietario", "propiedad_limpia");
        cargarOpciones("filtro-tension", "tension_limpia");

        function coincide(filtro, valor) {
          return filtro === "TODAS" || valor === filtro;
        }

        function renderizarMarcadores() {
          var filtroConcesion =
            document.getElementById("filtro-concesion").value;

          var filtroPropietario =
            document.getElementById("filtro-propietario").value;

          var filtroTension =
            document.getElementById("filtro-tension").value;

          capaMarcadores.clearLayers();
          var cantidad = 0;

          datos.forEach(function(d) {
            if (
              coincide(filtroConcesion, d.concesion_limpia) &&
              coincide(filtroPropietario, d.propiedad_limpia) &&
              coincide(filtroTension, d.tension_limpia)
            ) {
              var marker = L.marker([d.lat, d.lon], {
                icon: iconoTorre
              });

              marker.bindPopup(d.popup_html);
              capaMarcadores.addLayer(marker);
              cantidad++;
            }
          });

          document.getElementById("cantidad-estaciones").textContent =
            cantidad + " estación(es) mostrada(s)";
        }

        ["filtro-concesion", "filtro-propietario", "filtro-tension"]
          .forEach(function(id) {
            document.getElementById(id).addEventListener(
              "change",
              renderizarMarcadores
            );
          });

        document.getElementById("limpiar-filtros").addEventListener(
          "click",
          function() {
            document.getElementById("filtro-concesion").value = "TODAS";
            document.getElementById("filtro-propietario").value = "TODAS";
            document.getElementById("filtro-tension").value = "TODAS";
            renderizarMarcadores();
          }
        );

        renderizarMarcadores();
      }
      ',
      datos_json,
      svg_torre_uri
    )
  )

# 5. Exportar a docs/index.html para GitHub Pages
dir.create("docs", showWarnings = FALSE)
saveWidget(mapa_estaciones, file = "docs/index.html", selfcontained = TRUE)

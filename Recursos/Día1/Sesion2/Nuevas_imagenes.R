library(reticulate) # Conexión con Python
library(rgee) # Conexión con Google Earth Engine
library(sf) # Paquete para manejar datos geográficos
library(dplyr) # Paquete para procesamiento de datos
library(concaveman)
library(magrittr)
library(purrr)

rgee_environment_dir = "C://Users//sguerrero//Anaconda3//envs//rgee_py//python.exe"
rgee_environment_dir = "C://Users//agutierrez1//Anaconda3//envs//rgee_py//python.exe"

# Configurar python (Algunas veces no es detectado y se debe reiniciar R)
reticulate::use_python(rgee_environment_dir, required=T)

rgee::ee_install_set_pyenv(py_path = rgee_environment_dir, py_env = "rgee_py")

Sys.setenv(RETICULATE_PYTHON = rgee_environment_dir)
Sys.setenv(EARTHENGINE_PYTHON = rgee_environment_dir)
rgee::ee_Initialize(drive = T)
shape <- read_sf("Recursos/Día1/Sesion3/Shape/CHL_dam.shp")

mls <- shape["dam"] %>% filter(dam == "10") 

mls.envelope <- mls %>%
  st_combine() %>%
  st_cast("POINT") %>%
  st_sf() %>%
  concaveman()

mls.envelope %<>% 
  mutate(dam = "10") %>% 
  rename(geometry = polygons)

shape <- bind_rows(mls.envelope,
                   shape  %>% filter(dam != "10")  )

mls <- shape["dam"] %>% filter(dam == "11") 

mls.envelope <- mls %>%
  st_combine() %>%
  st_cast("POINT") %>%
  st_sf() %>%
  concaveman()

mls.envelope %<>% 
  mutate(dam = "11") %>% 
  rename(geometry = polygons)

shape <- bind_rows(mls.envelope,
                   shape  %>% filter(dam != "11")  )

mls <- shape["dam"] %>% filter(dam == "12") 

mls.envelope <- mls %>%
  st_combine() %>%
  st_cast("POINT") %>%
  st_sf() %>%
  concaveman()

mls.envelope %<>% 
  mutate(dam = "12") %>% 
  rename(geometry = polygons)

shape <- bind_rows(mls.envelope,
                   shape  %>% filter(dam != "12")  )


mls <- shape["dam"] %>% filter(dam == "05") 
mls.envelope <- mls %>%
  st_combine() %>%
  st_cast("POINT") %>%
  st_sf() %>%
  concaveman()

mls.envelope %<>% 
  mutate(dam = "05") %>% 
  rename(geometry = polygons)

shape <- bind_rows(mls.envelope,
                   shape  %>% filter(dam != "05")  )
##pop_worldpop <- ee$ImageCollection("WorldPop/GP/100m/pop")
#######
pop_worldpop <- ee$ImageCollection("CIESIN/GPWv411/GPW_UNWPP-Adjusted_Population_Density")
pop_2020 <- pop_worldpop$filter(ee$Filter$date('2020-01-01', '2020-12-31'))$first()
pop_2020 <- pop_2020$select('unwpp-adjusted_population_density');
ee_print(pop_2020)

shape_Pob3 <- map(unique(shape$dam),
                 ~tryCatch(ee_extract(
                   x = pop_2020,
                   y = shape["dam"] %>% filter(dam == .x),
                   ee$Reducer$mean(),
                   sf = FALSE
                 ) %>% mutate(dam = .x),
                 error = function(e)data.frame(dam = .x)))

shape_Pob3 %<>% bind_rows()
saveRDS(shape_Pob3,"Recursos/Día1/Sesion3/0Recursos/shape_Pob_dam.rds")

#############################
precipitation <- ee$ImageCollection('NASA/GPM_L3/IMERG_MONTHLY_V06')
precipitation <- precipitation$filterDate('2019-01-01', '2021-01-01');
precipitation <- precipitation$select('precipitation')
precipitation <- precipitation$reduce(ee$Reducer$mean())
ee_print(precipitation)


shape_precipitation <- map(unique(shape$dam),
                  ~tryCatch(ee_extract(
                    x = precipitation,
                    y = shape["dam"] %>% filter(dam == .x),
                    ee$Reducer$mean(),
                    sf = FALSE
                  ) %>% mutate(dam = .x),
                  error = function(e)data.frame(dam = .x)))

shape_precipitation %<>% bind_rows()
saveRDS(shape_precipitation,"Recursos/Día1/Sesion3/0Recursos/shape_precipitation_dam.rds")

###############################################
temperatura <- ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")
temperatura <- temperatura$filter(ee$Filter$date('2021-01-01', '2022-01-01'));
temperatura <- temperatura$select("temperature_2m","soil_temperature_level_4", "total_precipitation_hourly")
temperatura <- temperatura$reduce(ee$Reducer$mean())
ee_print(temperatura)


shape_temperatura <- map(unique(shape$dam)[1],
                           ~tryCatch(ee_extract(
                             x = temperatura,
                             y = shape["dam"] %>% filter(dam == .x),
                             ee$Reducer$mean(),
                             sf = FALSE
                           ) %>% mutate(dam = .x),
                           error = function(e)data.frame(dam = .x)))

shape_temperatura %<>% bind_rows()
saveRDS(shape_temperatura,"Recursos/Día1/Sesion3/0Recursos/shape_temperatura_dam.rds")


######################################
elevation <- ee$ImageCollection('COPERNICUS/DEM/GLO30');
elevation <- elevation$select('DEM')
elevation <- elevation$reduce(ee$Reducer$mean())
ee_print(elevation)

shape_elevation <- map(unique(shape$dam),
                         ~tryCatch(ee_extract(
                           x = elevation,
                           y = shape["dam"] %>% filter(dam == .x),
                           ee$Reducer$mean(),
                           sf = FALSE
                         ) %>% mutate(dam = .x),
                         error = function(e)data.frame(dam = .x)))

shape_elevation %<>% bind_rows()
saveRDS(shape_elevation,"Recursos/Día1/Sesion3/0Recursos/shape_elevation_dam.rds")

##################################################################

elevation2 = ee$Image('USGS/GMTED2010');
elevation2 = elevation2$select('be75');
ee_print(elevation2)

shape_elevation2 <- map(unique(shape$dam),
                       ~tryCatch(ee_extract(
                         x = elevation2,
                         y = shape["dam"] %>% filter(dam == .x),
                         ee$Reducer$mean(),
                         sf = FALSE
                       ) %>% mutate(dam = .x),
                       error = function(e)data.frame(dam = .x)))

shape_elevation2 %<>% bind_rows()
saveRDS(shape_elevation2,"Recursos/Día1/Sesion3/0Recursos/shape_elevation2_dam.rds")


##################################################################

vegetation_NDVI <- ee$ImageCollection('MODIS/061/MOD13A1')
vegetation_NDVI <- vegetation_NDVI$filter(ee$Filter$date('2022-01-01', '2023-01-01'));
vegetation_NDVI <- vegetation_NDVI$select('NDVI');
vegetation_NDVI <- vegetation_NDVI$reduce(ee$Reducer$mean())
ee_print(vegetation_NDVI)

shape_vegetation_NDVI <- map(unique(shape$dam),
                        ~tryCatch(ee_extract(
                          x = vegetation_NDVI,
                          y = shape["dam"] %>% filter(dam == .x),
                          ee$Reducer$mean(),
                          sf = FALSE
                        ) %>% mutate(dam = .x),
                        error = function(e)data.frame(dam = .x)))

shape_vegetation_NDVI %<>% bind_rows()
saveRDS(shape_vegetation_NDVI,"Recursos/Día1/Sesion3/0Recursos/shape_vegetation_NDVI_dam.rds")

#####################################################
pollution <- ee$ImageCollection('COPERNICUS/S5P/OFFL/L3_CO')
pollution <- pollution$filterDate('2021-01-01', '2022-01-01');
pollution <- pollution$select('CO_column_number_density')
pollution <- pollution$reduce(ee$Reducer$mean())
ee_print(pollution)

shape_pollution <- map(unique(shape$dam),
                             ~tryCatch(ee_extract(
                               x = pollution,
                               y = shape["dam"] %>% filter(dam == .x),
                               ee$Reducer$mean(),
                               sf = FALSE
                             ) %>% mutate(dam = .x),
                             error = function(e)data.frame(dam = .x)))

shape_pollution %<>% bind_rows()
saveRDS(shape_pollution,"Recursos/Día1/Sesion3/0Recursos/shape_pollution_dam.rds")


temp <- list.files("Recursos/Día1/Sesion3/0Recursos/",pattern = "dam.rds$",
           full.names = TRUE) %>% 
  map(~readRDS(.x)) %>% reduce(.f = full_join)  
  
temp %<>% select_if(~!anyNA(.)) %>% 
  rename(Elevation = be75, 
         population_density = unwpp.adjusted_population_density, # The estimated number of persons per square kilometer.
         pollution_CO =  CO_column_number_density_mean, # Vertically integrated CO column density.
         precipitation = precipitation_mean,     # Merged satellite-gauge precipitation estimate
         vegetation_NDVI = NDVI_mean)

shape_temp <- read_sf("Recursos/Día1/Sesion3/Shape/CHL_dam.shp")
plot(inner_join(shape_temp,temp)[,"Elevation"])
plot(inner_join(shape_temp,temp)[,"population_density"])
plot(inner_join(shape_temp,temp)[,"pollution_CO"])
plot(inner_join(shape_temp,temp)[,"precipitation"])
plot(inner_join(shape_temp,temp)[,"vegetation_NDVI"])

saveRDS(temp,"Recursos/Día1/Sesion3/0Recursos/satelitales_new_dam.rds")

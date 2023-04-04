library(reticulate) # Conexión con Python
library(rgee) # Conexión con Google Earth Engine
library(sf) # Paquete para manejar datos geográficos
library(dplyr) # Paquete para procesamiento de datos
library(concaveman)
library(magrittr)
library(purrr)

rgee_environment_dir = "C://Users//sguerrero//Anaconda3//envs//rgee_py//python.exe"
rgee_environment_dir = "C://Users//agutierrez1//Anaconda3//envs//rgee_py//python.exe"
rgee_environment_dir = "C://Users//gnieto//Anaconda3//envs//rgee_py//python.exe"
# Configurar python (Algunas veces no es detectado y se debe reiniciar R)
reticulate::use_python(rgee_environment_dir, required=T)

rgee::ee_install_set_pyenv(py_path = rgee_environment_dir, py_env = "rgee_py")

Sys.setenv(RETICULATE_PYTHON = rgee_environment_dir)
Sys.setenv(EARTHENGINE_PYTHON = rgee_environment_dir)
rgee::ee_Initialize(drive = T)
shape <- read_sf("Recursos/Día1/Sesion2/Shape/CHL_dam2.shp")

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
saveRDS(shape_Pob3, "Recursos/Día1/Sesion3/0Recursos/shape_Pob_dam2.rds")

#############################
precipitation <- ee$ImageCollection('NASA/GPM_L3/IMERG_MONTHLY_V06')
precipitation <- precipitation$filterDate('2019-01-01', '2021-01-01');
precipitation <- precipitation$select('precipitation', "probabilityLiquidPrecipitation")
precipitation <- precipitation$reduce(ee$Reducer$mean())
ee_print(precipitation)


shape_precipitation <- map(unique(shape$dam2),
                  ~tryCatch(ee_extract(
                    x = precipitation,
                    y = shape[,c("dam","dam2")] %>% filter(dam2== .x),
                    ee$Reducer$mean(),
                    sf = FALSE
                  ) %>% mutate(dam2 = .x),
                  error = function(e)data.frame(dam2 = .x)))

shape_precipitation %<>% bind_rows()

saveRDS(shape_precipitation, "Recursos/Día1/Sesion3/0Recursos/shape_precipitation_dam2.rds")

###############################################
temperatura <- ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")
temperatura <- temperatura$filter(ee$Filter$date('2021-01-01', '2022-01-01'));
temperatura <- temperatura$select("temperature_2m","soil_temperature_level_4", "total_precipitation_hourly")
temperatura <- temperatura$reduce(ee$Reducer$mean())
ee_print(temperatura)


shape_temperatura <- map(unique(shape$dam2),
                         ~tryCatch(ee_extract(
                           x = temperatura,
                           y = shape[,c("dam","dam2")] %>% filter(dam2 == .x),
                           ee$Reducer$mean(),
                           sf = FALSE
                         ) %>% mutate(dam2 = .x),
                         error = function(e)data.frame(dam2 = .x)))

shape_temperatura %<>% bind_rows()
saveRDS(shape_temperatura,"Recursos/Día1/Sesion3/0Recursos/shape_temperatura_dam2.rds")

######################################
elevation <- ee$ImageCollection('COPERNICUS/DEM/GLO30');
elevation <- elevation$select('DEM')
elevation <- elevation$reduce(ee$Reducer$mean())
ee_print(elevation)

shape_elevation <- map(unique(shape$dam2),
                       ~tryCatch(ee_extract(
                         x = elevation,
                         y = shape[,c("dam","dam2")] %>% filter(dam2 == .x),
                         ee$Reducer$mean(),
                         sf = FALSE
                       ) %>% mutate(dam2 = .x),
                       error = function(e)data.frame(dam2 = .x)))

shape_elevation %<>% bind_rows()
saveRDS(shape_elevation,"Recursos/Día1/Sesion3/0Recursos/shape_elevation_dam2.rds")

##################################################################

elevation2 = ee$Image('USGS/GMTED2010');
elevation2 = elevation2$select('be75');
ee_print(elevation2)

shape_elevation2 <- map(unique(shape$dam2),
                        ~tryCatch(ee_extract(
                          x = elevation2,
                          y = shape[,c("dam","dam2")] %>% filter(dam2 == .x),
                          ee$Reducer$mean(),
                          sf = FALSE
                        ) %>% mutate(dam2 = .x),
                        error = function(e)data.frame(dam2 = .x)))

shape_elevation2 %<>% bind_rows()
saveRDS(shape_elevation2,"Recursos/Día1/Sesion3/0Recursos/shape_elevation2_dam2.rds")


##################################################################

vegetation_NDVI <- ee$ImageCollection('MODIS/061/MOD13A1')
vegetation_NDVI <- vegetation_NDVI$filter(ee$Filter$date('2022-01-01', '2023-01-01'));
vegetation_NDVI <- vegetation_NDVI$select('NDVI');
vegetation_NDVI <- vegetation_NDVI$reduce(ee$Reducer$mean())
ee_print(vegetation_NDVI)

shape_vegetation_NDVI <- map(unique(shape$dam2),
                             ~tryCatch(ee_extract(
                               x = vegetation_NDVI,
                               y = shape[,c("dam","dam2")] %>% filter(dam2 == .x),
                               ee$Reducer$mean(),
                               sf = FALSE
                             ) %>% mutate(dam2 = .x),
                             error = function(e)data.frame(dam2 = .x)))

shape_vegetation_NDVI %<>% bind_rows()
saveRDS(shape_vegetation_NDVI,"Recursos/Día1/Sesion3/0Recursos/shape_vegetation_NDVI_dam2.rds")

#####################################################
pollution <- ee$ImageCollection('COPERNICUS/S5P/OFFL/L3_CO')
pollution <- pollution$filterDate('2021-01-01', '2022-01-01');
pollution <- pollution$select('CO_column_number_density')
pollution <- pollution$reduce(ee$Reducer$mean())
ee_print(pollution)

shape_pollution <- map(unique(shape$dam2),
                       ~tryCatch(ee_extract(
                         x = pollution,
                         y = shape["dam2"] %>% filter(dam2 == .x),
                         ee$Reducer$mean(),
                         sf = FALSE
                       ) %>% mutate(dam2 = .x),
                       error = function(e)data.frame(dam2 = .x)))

shape_pollution %<>% bind_rows()
saveRDS(shape_pollution,"Recursos/Día1/Sesion3/0Recursos/shape_pollution_dam2.rds")



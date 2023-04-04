# Día 3 - Sesión 3- Modelo de unidad para la estimación de la pobreza 



Lo primero a tener en cuenta, es que no se debe usar una regresión lineal cuando se tiene una variable de tipo  binario como variable dependiente, ya que no es posible estimar la probabilidad del evento estudiado de manera directa, por esta razón se emplea una regresión logística, en la que para obtener las estimaciones          de la probabilidad del evento estudiado se debe realizar una transformación (logit), lo cual consiste en          tomar el logaritmo de la probabilidad de éxito entre la probabilidad de fracaso, de la siguiente manera:  

$$
\ln \frac{\theta}{1-\theta}
$$
donde $\theta$ representa la probabilidad de éxito del evento.  

## Modelo de regresión logistica. 

Sea 
$$
y_{ji}=\begin{cases}
1 & ingreso_{ji}\le lp\\
0 & e.o.c.
\end{cases}
$$ 
donde $ingreso_{ji}$ representa el ingreso de la $i$-ésima persona en el $j$-ésimo post-estrato y $lp$ es un valor limite, en particular la linea de pobreza. Empleando un modelo de regresión logística de efecto aleatorios pretende establecer la relación entre la expectativa $\theta_{ji}$  de la variable dicotómica con las covariables de información auxiliar disponibles para ser incluidas. El procedimiento correspondiente a este proceso, modela el logaritmo del cociente entre la probabilidad de estar por debajo de la linea de pobreza  a su complemento en relación al conjunto de covariables a nivel de unidad, $x_{ji}$, y el efecto aleatorio $u_d$.     

$$
\begin{eqnarray*}
\ln\left(\frac{\theta_{ji}}{1-\theta_{ji}}\right)=\boldsymbol{x}_{ji}^{T}\boldsymbol{\beta}+u_d
\end{eqnarray*}
$$

Donde los coeficientes $\boldsymbol{\beta}$ hacen referencia a los efectos fijos de las variables $x_{ji}^T$  sobre las probabilidades de que la $i$-ésima persona este por debajo de la linea de pobreza; por otro lado, $u_d$ son los efectos fijos aleatorios, donde $u_{d}\sim N\left(0,\sigma^2_{u}\right)$. 

Para este caso se asumen las distribuciones previas

$$
\begin{eqnarray*}
\beta_k & \sim   & N(0, 1000)\\
\sigma^2_u &\sim & IG(0.0001,0.0001)
\end{eqnarray*}
$$ las cuales se toman no informativas.


#### Obejtivo {-}

Estimar la proporción de personas que están por debajo de la linea pobreza, es decir, 
$$
P_d = \frac{\sum_{U_d}y_{di}}{N_d}
$$
donde $y_{di}$ toma el valor de 1 cuando el ingreso de la persona es menor a la linea de pobreza 0 en caso contrario. 

Note que, 

$$
\begin{equation*}
\bar{Y}_d = P_d =  \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}y_{di}}{N_d} 
\end{equation*}
$$

Ahora, el estimador de $P$ esta dado por: 

$$
\hat{P} = \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}\hat{y}_{di}}{N_d}
$$

donde

$$\hat{y}_{di}=E_{\mathscr{M}}\left(y_{di}\mid\boldsymbol{x}_{d},\boldsymbol{\beta}\right)$$,

donde $\mathscr{M}$ hace referencia a la medida de probabilidad inducida por el modelamiento. 
De esta forma se tiene que, 

$$
\hat{P} = \frac{\sum_{U_{d}}\hat{y}_{di}}{N_d}
$$



A continuación se muestra el proceso realizado para la obtención de la predicción de la tasa de pobreza.

## Proceso de estimación en `R`

Para desarrollar la metodología se hace uso de las siguientes librerías.


```r
# Interprete de STAN en R
library(rstan)
library(rstanarm)
# Manejo de bases de datos.
library(tidyverse)
# Gráficas de los modelos. 
library(bayesplot)
library(patchwork)
# Organizar la presentación de las tablas
library(kableExtra)
library(printr)
```

Un conjunto de funciones desarrolladas para realizar de forma simplificada los procesos están consignadas en la siguiente rutina.


```r
source("Recursos/Día3/Sesion3/0Recursos/funciones_mrp.R")
```

Entre las funciones incluidas en el archivo encuentra

-   *plot_interaction*: Esta crea un diagrama de lineas donde se estudia la interacción entre las variables, en el caso de presentar un traslape de las lineas se recomienda incluir el interacción en el modelo.

-   *Plot_Compare* Puesto que es necesario realizar una homologar la información del censo y la encuesta es conveniente llevar a cabo una validación de las variables que han sido homologadas, por tanto, se espera que las proporciones resultantes del censo y la encuesta estén cercanas entre sí.

-   *Aux_Agregado*: Esta es función permite obtener estimaciones a diferentes niveles de agregación, toma mucha relevancia cuando se realiza un proceso repetitivo.

**Las funciones están diseñada específicamente  para este  proceso**

### Encuesta de hogares

Los datos empleados en esta ocasión corresponden a la ultima encuesta de hogares, la cual ha sido estandarizada por *CEPAL* y se encuentra disponible en *BADEHOG*


```r
encuesta <- readRDS("Recursos/Día3/Sesion3/Data/encuesta2017CHL.Rds")


encuesta_mrp <- encuesta %>% 
  transmute(
    dam =  haven::as_factor(dam_ee ,levels = "values"),
    dam2 =  haven::as_factor(comuna,levels = "values"),
    dam = str_pad(dam, width = 2, pad = "0"),
    dam2 = str_pad(dam2, width = 5, pad = "0"),  
  ingreso = ingcorte,lp,li,
   pobreza = ifelse(ingcorte < lp,1,0),
  area = case_when(area_ee == 1 ~ "1", TRUE ~ "0"),
  sexo = as.character(sexo),

  anoest = case_when(
    edad < 6 | is.na(anoest)   ~ "98"  , #No aplica
    anoest == 99 ~ "99", #NS/NR
    anoest == 0  ~ "1", # Sin educacion
    anoest %in% c(1:6) ~ "2",       # 1 - 6
    anoest %in% c(7:12) ~ "3",      # 7 - 12
    anoest > 12 ~ "4",      # mas de 12
    TRUE ~ "Error"  ),

  edad = case_when(
    edad < 15 ~ "1",
    edad < 30 ~ "2",
    edad < 45 ~ "3",
    edad < 65 ~ "4",
    TRUE ~ "5"),

  etnia = case_when(
    etnia_ee == 1 ~ "1", # Indigena
    etnia_ee == 2 ~ "2",
     TRUE ~ "3"), # Otro
 fep = `_feh`
) 

tba(encuesta_mrp %>% head(10)) 
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam </th>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> ingreso </th>
   <th style="text-align:right;"> lp </th>
   <th style="text-align:right;"> li </th>
   <th style="text-align:right;"> pobreza </th>
   <th style="text-align:left;"> area </th>
   <th style="text-align:left;"> sexo </th>
   <th style="text-align:left;"> anoest </th>
   <th style="text-align:left;"> edad </th>
   <th style="text-align:left;"> etnia </th>
   <th style="text-align:right;"> fep </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 250000.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 211091.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 296750.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 296750.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 113889.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 113889.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 113889.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 98 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 231666.5 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 231666.5 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 418750.0 </td>
   <td style="text-align:right;"> 113958 </td>
   <td style="text-align:right;"> 51309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39 </td>
  </tr>
</tbody>
</table>

La base de datos de la encuesta tiene la siguientes columnas: 

-   *dam*: Corresponde al código asignado a la división administrativa mayor del país.

-   *dam2*: Corresponde al código asignado a la segunda división administrativa del país.

-   *lp* y *li* lineas de pobreza y pobreza extrema definidas por CEPAL. 

-   *área* división geográfica (Urbano y Rural). 

-   *sexo* Hombre y Mujer. 

-   *etnia* En estas variable se definen tres grupos:  afrodescendientes, indígenas y Otros. 

-   Años de escolaridad (*anoest*) 

-   Rangos de edad (*edad*) 

-   Factor de expansión por persona (*fep*)


Ahora, inspeccionamos el comportamiento de la variable de interés: 


```r
tab <- encuesta_mrp %>% group_by(pobreza) %>% 
  tally() %>%
  mutate(prop = round(n/sum(n),2),
         pobreza = ifelse(pobreza == 1, "Si", "No"))

ggplot(data = tab, aes(x = pobreza, y = prop)) +
  geom_bar(stat = "identity") + 
  labs(y = "", x = "") +
  geom_text(aes(label = paste(prop*100,"%")), 
            nudge_y=0.05) +
  theme_bw(base_size = 20) +
  theme(axis.text.y = element_blank(),
        axis.ticks = element_blank())
```

<div class="figure">
<img src="10-D3S3_Modelo_unidad_pobreza_files/figure-html/unnamed-chunk-4-1.svg" alt="Proporción de personas por debajo de la linea de pobreza" width="672" />
<p class="caption">(\#fig:unnamed-chunk-4)Proporción de personas por debajo de la linea de pobreza</p>
</div>


La información auxiliar disponible ha sido extraída del censo  e imágenes satelitales


```r
statelevel_predictors_df <- 
  readRDS("Recursos/Día3/Sesion3/Data/statelevel_predictors_df_dam2.rds") %>% 
    mutate_at(.vars = c("luces_nocturnas",
                      "cubrimiento_cultivo",
                      "cubrimiento_urbano",
                      "modificacion_humana",
                      "accesibilidad_hospitales",
                      "accesibilidad_hosp_caminado"),
            function(x) as.numeric(scale(x)))
tba(statelevel_predictors_df  %>%  head(10))
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> area0 </th>
   <th style="text-align:right;"> area1 </th>
   <th style="text-align:right;"> etnia2 </th>
   <th style="text-align:right;"> sexo2 </th>
   <th style="text-align:right;"> edad2 </th>
   <th style="text-align:right;"> edad3 </th>
   <th style="text-align:right;"> edad4 </th>
   <th style="text-align:right;"> edad5 </th>
   <th style="text-align:right;"> anoest2 </th>
   <th style="text-align:right;"> anoest3 </th>
   <th style="text-align:right;"> anoest4 </th>
   <th style="text-align:right;"> anoest99 </th>
   <th style="text-align:right;"> etnia1 </th>
   <th style="text-align:right;"> piso_tierra </th>
   <th style="text-align:right;"> material_paredes </th>
   <th style="text-align:right;"> material_techo </th>
   <th style="text-align:right;"> rezago_escolar </th>
   <th style="text-align:right;"> alfabeta </th>
   <th style="text-align:right;"> tasa_desocupacion </th>
   <th style="text-align:right;"> pollution_CO </th>
   <th style="text-align:right;"> vegetation_NDVI </th>
   <th style="text-align:right;"> Elevation </th>
   <th style="text-align:right;"> temperature_ECMWF </th>
   <th style="text-align:right;"> temperature_2metros </th>
   <th style="text-align:right;"> total_precipitation </th>
   <th style="text-align:right;"> precipitation </th>
   <th style="text-align:right;"> population_density </th>
   <th style="text-align:right;"> luces_nocturnas </th>
   <th style="text-align:right;"> cubrimiento_cultivo </th>
   <th style="text-align:right;"> cubrimiento_urbano </th>
   <th style="text-align:right;"> modificacion_humana </th>
   <th style="text-align:right;"> accesibilidad_hospitales </th>
   <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 0.0126 </td>
   <td style="text-align:right;"> 0.9874 </td>
   <td style="text-align:right;"> 0.0016 </td>
   <td style="text-align:right;"> 0.5044 </td>
   <td style="text-align:right;"> 0.2374 </td>
   <td style="text-align:right;"> 0.2338 </td>
   <td style="text-align:right;"> 0.2242 </td>
   <td style="text-align:right;"> 0.0926 </td>
   <td style="text-align:right;"> 0.1360 </td>
   <td style="text-align:right;"> 0.4547 </td>
   <td style="text-align:right;"> 0.2711 </td>
   <td style="text-align:right;"> 0.0245 </td>
   <td style="text-align:right;"> 0.1709 </td>
   <td style="text-align:right;"> 0.0051 </td>
   <td style="text-align:right;"> 0.2133 </td>
   <td style="text-align:right;"> 0.5059 </td>
   <td style="text-align:right;"> 0.3940 </td>
   <td style="text-align:right;"> 0.0285 </td>
   <td style="text-align:right;"> 0.0703 </td>
   <td style="text-align:right;"> 0.0229 </td>
   <td style="text-align:right;"> -1.7713 </td>
   <td style="text-align:right;"> -0.0492 </td>
   <td style="text-align:right;"> 2.0871 </td>
   <td style="text-align:right;"> 1.3892 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0057 </td>
   <td style="text-align:right;"> -0.3101 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.9633 </td>
   <td style="text-align:right;"> -0.3591 </td>
   <td style="text-align:right;"> -0.6911 </td>
   <td style="text-align:right;"> 0.0238 </td>
   <td style="text-align:right;"> 0.0469 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:right;"> 0.0230 </td>
   <td style="text-align:right;"> 0.9770 </td>
   <td style="text-align:right;"> 0.0011 </td>
   <td style="text-align:right;"> 0.4998 </td>
   <td style="text-align:right;"> 0.2723 </td>
   <td style="text-align:right;"> 0.2157 </td>
   <td style="text-align:right;"> 0.1863 </td>
   <td style="text-align:right;"> 0.0426 </td>
   <td style="text-align:right;"> 0.1856 </td>
   <td style="text-align:right;"> 0.5305 </td>
   <td style="text-align:right;"> 0.0978 </td>
   <td style="text-align:right;"> 0.0358 </td>
   <td style="text-align:right;"> 0.2949 </td>
   <td style="text-align:right;"> 0.0372 </td>
   <td style="text-align:right;"> 0.2447 </td>
   <td style="text-align:right;"> 0.5403 </td>
   <td style="text-align:right;"> 0.1832 </td>
   <td style="text-align:right;"> 0.0528 </td>
   <td style="text-align:right;"> 0.0851 </td>
   <td style="text-align:right;"> 0.0229 </td>
   <td style="text-align:right;"> -1.7300 </td>
   <td style="text-align:right;"> 0.2182 </td>
   <td style="text-align:right;"> 2.3984 </td>
   <td style="text-align:right;"> 1.6136 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0078 </td>
   <td style="text-align:right;"> -0.2644 </td>
   <td style="text-align:right;"> -0.1883 </td>
   <td style="text-align:right;"> -0.9633 </td>
   <td style="text-align:right;"> -0.3157 </td>
   <td style="text-align:right;"> -0.4150 </td>
   <td style="text-align:right;"> -0.2180 </td>
   <td style="text-align:right;"> -0.0922 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01401 </td>
   <td style="text-align:right;"> 0.3575 </td>
   <td style="text-align:right;"> 0.6425 </td>
   <td style="text-align:right;"> 0.0004 </td>
   <td style="text-align:right;"> 0.4280 </td>
   <td style="text-align:right;"> 0.2539 </td>
   <td style="text-align:right;"> 0.2415 </td>
   <td style="text-align:right;"> 0.2023 </td>
   <td style="text-align:right;"> 0.0719 </td>
   <td style="text-align:right;"> 0.1781 </td>
   <td style="text-align:right;"> 0.5285 </td>
   <td style="text-align:right;"> 0.1377 </td>
   <td style="text-align:right;"> 0.0280 </td>
   <td style="text-align:right;"> 0.4207 </td>
   <td style="text-align:right;"> 0.0193 </td>
   <td style="text-align:right;"> 0.6109 </td>
   <td style="text-align:right;"> 0.8826 </td>
   <td style="text-align:right;"> 0.2323 </td>
   <td style="text-align:right;"> 0.0513 </td>
   <td style="text-align:right;"> 0.0762 </td>
   <td style="text-align:right;"> 0.0209 </td>
   <td style="text-align:right;"> -1.7393 </td>
   <td style="text-align:right;"> 0.9481 </td>
   <td style="text-align:right;"> 1.8649 </td>
   <td style="text-align:right;"> 1.5590 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0068 </td>
   <td style="text-align:right;"> -0.3569 </td>
   <td style="text-align:right;"> -0.5357 </td>
   <td style="text-align:right;"> -0.9607 </td>
   <td style="text-align:right;"> -0.3883 </td>
   <td style="text-align:right;"> -1.3414 </td>
   <td style="text-align:right;"> 0.4371 </td>
   <td style="text-align:right;"> 0.1599 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01402 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 0.4744 </td>
   <td style="text-align:right;"> 0.2064 </td>
   <td style="text-align:right;"> 0.1792 </td>
   <td style="text-align:right;"> 0.2376 </td>
   <td style="text-align:right;"> 0.1568 </td>
   <td style="text-align:right;"> 0.2536 </td>
   <td style="text-align:right;"> 0.4256 </td>
   <td style="text-align:right;"> 0.0752 </td>
   <td style="text-align:right;"> 0.0720 </td>
   <td style="text-align:right;"> 0.8568 </td>
   <td style="text-align:right;"> 0.0194 </td>
   <td style="text-align:right;"> 0.6728 </td>
   <td style="text-align:right;"> 0.9187 </td>
   <td style="text-align:right;"> 0.1814 </td>
   <td style="text-align:right;"> 0.1854 </td>
   <td style="text-align:right;"> 0.0380 </td>
   <td style="text-align:right;"> 0.0190 </td>
   <td style="text-align:right;"> -1.7546 </td>
   <td style="text-align:right;"> 2.2707 </td>
   <td style="text-align:right;"> 1.1709 </td>
   <td style="text-align:right;"> 0.6441 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0093 </td>
   <td style="text-align:right;"> -0.3582 </td>
   <td style="text-align:right;"> -0.5581 </td>
   <td style="text-align:right;"> -0.9618 </td>
   <td style="text-align:right;"> -0.3905 </td>
   <td style="text-align:right;"> -1.4837 </td>
   <td style="text-align:right;"> 0.9270 </td>
   <td style="text-align:right;"> 0.2968 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01403 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 0.0006 </td>
   <td style="text-align:right;"> 0.4242 </td>
   <td style="text-align:right;"> 0.2685 </td>
   <td style="text-align:right;"> 0.2378 </td>
   <td style="text-align:right;"> 0.2269 </td>
   <td style="text-align:right;"> 0.1209 </td>
   <td style="text-align:right;"> 0.2529 </td>
   <td style="text-align:right;"> 0.3686 </td>
   <td style="text-align:right;"> 0.1539 </td>
   <td style="text-align:right;"> 0.0799 </td>
   <td style="text-align:right;"> 0.8113 </td>
   <td style="text-align:right;"> 0.0864 </td>
   <td style="text-align:right;"> 0.9684 </td>
   <td style="text-align:right;"> 0.9782 </td>
   <td style="text-align:right;"> 0.2796 </td>
   <td style="text-align:right;"> 0.1937 </td>
   <td style="text-align:right;"> 0.0494 </td>
   <td style="text-align:right;"> 0.0153 </td>
   <td style="text-align:right;"> -1.5885 </td>
   <td style="text-align:right;"> 4.3891 </td>
   <td style="text-align:right;"> -1.1246 </td>
   <td style="text-align:right;"> -2.0702 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0228 </td>
   <td style="text-align:right;"> -0.3581 </td>
   <td style="text-align:right;"> -0.5595 </td>
   <td style="text-align:right;"> -0.9362 </td>
   <td style="text-align:right;"> -0.3875 </td>
   <td style="text-align:right;"> -1.4958 </td>
   <td style="text-align:right;"> 0.1454 </td>
   <td style="text-align:right;"> -0.0117 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01404 </td>
   <td style="text-align:right;"> 0.5938 </td>
   <td style="text-align:right;"> 0.4062 </td>
   <td style="text-align:right;"> 0.0011 </td>
   <td style="text-align:right;"> 0.4502 </td>
   <td style="text-align:right;"> 0.1967 </td>
   <td style="text-align:right;"> 0.1894 </td>
   <td style="text-align:right;"> 0.2447 </td>
   <td style="text-align:right;"> 0.1418 </td>
   <td style="text-align:right;"> 0.2733 </td>
   <td style="text-align:right;"> 0.4425 </td>
   <td style="text-align:right;"> 0.0883 </td>
   <td style="text-align:right;"> 0.0542 </td>
   <td style="text-align:right;"> 0.6029 </td>
   <td style="text-align:right;"> 0.0422 </td>
   <td style="text-align:right;"> 0.7778 </td>
   <td style="text-align:right;"> 0.9239 </td>
   <td style="text-align:right;"> 0.1838 </td>
   <td style="text-align:right;"> 0.1314 </td>
   <td style="text-align:right;"> 0.0529 </td>
   <td style="text-align:right;"> 0.0204 </td>
   <td style="text-align:right;"> -1.7537 </td>
   <td style="text-align:right;"> 1.5028 </td>
   <td style="text-align:right;"> 1.5619 </td>
   <td style="text-align:right;"> 1.0517 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0104 </td>
   <td style="text-align:right;"> -0.3581 </td>
   <td style="text-align:right;"> -0.5604 </td>
   <td style="text-align:right;"> -0.9623 </td>
   <td style="text-align:right;"> -0.3884 </td>
   <td style="text-align:right;"> -1.5003 </td>
   <td style="text-align:right;"> 0.4858 </td>
   <td style="text-align:right;"> 0.1803 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01405 </td>
   <td style="text-align:right;"> 0.5792 </td>
   <td style="text-align:right;"> 0.4208 </td>
   <td style="text-align:right;"> 0.0016 </td>
   <td style="text-align:right;"> 0.2954 </td>
   <td style="text-align:right;"> 0.1962 </td>
   <td style="text-align:right;"> 0.3483 </td>
   <td style="text-align:right;"> 0.2547 </td>
   <td style="text-align:right;"> 0.0756 </td>
   <td style="text-align:right;"> 0.1046 </td>
   <td style="text-align:right;"> 0.5089 </td>
   <td style="text-align:right;"> 0.2812 </td>
   <td style="text-align:right;"> 0.0350 </td>
   <td style="text-align:right;"> 0.4530 </td>
   <td style="text-align:right;"> 0.0137 </td>
   <td style="text-align:right;"> 0.5493 </td>
   <td style="text-align:right;"> 0.8489 </td>
   <td style="text-align:right;"> 0.3684 </td>
   <td style="text-align:right;"> 0.0269 </td>
   <td style="text-align:right;"> 0.0284 </td>
   <td style="text-align:right;"> 0.0162 </td>
   <td style="text-align:right;"> -1.6587 </td>
   <td style="text-align:right;"> 3.6152 </td>
   <td style="text-align:right;"> -0.4069 </td>
   <td style="text-align:right;"> -1.1352 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0140 </td>
   <td style="text-align:right;"> -0.3553 </td>
   <td style="text-align:right;"> -0.5266 </td>
   <td style="text-align:right;"> -0.9592 </td>
   <td style="text-align:right;"> -0.3893 </td>
   <td style="text-align:right;"> -1.2729 </td>
   <td style="text-align:right;"> 0.4531 </td>
   <td style="text-align:right;"> 0.0377 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:right;"> 0.0215 </td>
   <td style="text-align:right;"> 0.9785 </td>
   <td style="text-align:right;"> 0.0010 </td>
   <td style="text-align:right;"> 0.4975 </td>
   <td style="text-align:right;"> 0.2610 </td>
   <td style="text-align:right;"> 0.2324 </td>
   <td style="text-align:right;"> 0.2170 </td>
   <td style="text-align:right;"> 0.0789 </td>
   <td style="text-align:right;"> 0.1356 </td>
   <td style="text-align:right;"> 0.4654 </td>
   <td style="text-align:right;"> 0.2543 </td>
   <td style="text-align:right;"> 0.0326 </td>
   <td style="text-align:right;"> 0.0768 </td>
   <td style="text-align:right;"> 0.0085 </td>
   <td style="text-align:right;"> 0.1644 </td>
   <td style="text-align:right;"> 0.4710 </td>
   <td style="text-align:right;"> 0.3795 </td>
   <td style="text-align:right;"> 0.0312 </td>
   <td style="text-align:right;"> 0.0809 </td>
   <td style="text-align:right;"> 0.0174 </td>
   <td style="text-align:right;"> -1.7986 </td>
   <td style="text-align:right;"> 2.0859 </td>
   <td style="text-align:right;"> 0.8208 </td>
   <td style="text-align:right;"> 0.1203 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0081 </td>
   <td style="text-align:right;"> -0.3511 </td>
   <td style="text-align:right;"> -0.5137 </td>
   <td style="text-align:right;"> -0.9632 </td>
   <td style="text-align:right;"> -0.3875 </td>
   <td style="text-align:right;"> -1.0542 </td>
   <td style="text-align:right;"> 1.1580 </td>
   <td style="text-align:right;"> 0.2452 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02102 </td>
   <td style="text-align:right;"> 0.0381 </td>
   <td style="text-align:right;"> 0.9619 </td>
   <td style="text-align:right;"> 0.0008 </td>
   <td style="text-align:right;"> 0.4034 </td>
   <td style="text-align:right;"> 0.2467 </td>
   <td style="text-align:right;"> 0.2538 </td>
   <td style="text-align:right;"> 0.2473 </td>
   <td style="text-align:right;"> 0.0563 </td>
   <td style="text-align:right;"> 0.1357 </td>
   <td style="text-align:right;"> 0.5822 </td>
   <td style="text-align:right;"> 0.1380 </td>
   <td style="text-align:right;"> 0.0383 </td>
   <td style="text-align:right;"> 0.0916 </td>
   <td style="text-align:right;"> 0.0074 </td>
   <td style="text-align:right;"> 0.3384 </td>
   <td style="text-align:right;"> 0.6778 </td>
   <td style="text-align:right;"> 0.2201 </td>
   <td style="text-align:right;"> 0.0318 </td>
   <td style="text-align:right;"> 0.0596 </td>
   <td style="text-align:right;"> 0.0212 </td>
   <td style="text-align:right;"> -1.8383 </td>
   <td style="text-align:right;"> 0.2505 </td>
   <td style="text-align:right;"> 2.2986 </td>
   <td style="text-align:right;"> 1.6722 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0047 </td>
   <td style="text-align:right;"> -0.3564 </td>
   <td style="text-align:right;"> -0.5005 </td>
   <td style="text-align:right;"> -0.9633 </td>
   <td style="text-align:right;"> -0.3847 </td>
   <td style="text-align:right;"> -1.2393 </td>
   <td style="text-align:right;"> 0.3183 </td>
   <td style="text-align:right;"> 0.1580 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02103 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 0.0014 </td>
   <td style="text-align:right;"> 0.1496 </td>
   <td style="text-align:right;"> 0.2073 </td>
   <td style="text-align:right;"> 0.4704 </td>
   <td style="text-align:right;"> 0.2784 </td>
   <td style="text-align:right;"> 0.0124 </td>
   <td style="text-align:right;"> 0.0260 </td>
   <td style="text-align:right;"> 0.5480 </td>
   <td style="text-align:right;"> 0.3980 </td>
   <td style="text-align:right;"> 0.0113 </td>
   <td style="text-align:right;"> 0.1347 </td>
   <td style="text-align:right;"> 0.0088 </td>
   <td style="text-align:right;"> 0.5344 </td>
   <td style="text-align:right;"> 0.9065 </td>
   <td style="text-align:right;"> 0.4256 </td>
   <td style="text-align:right;"> 0.0047 </td>
   <td style="text-align:right;"> 0.0138 </td>
   <td style="text-align:right;"> 0.0184 </td>
   <td style="text-align:right;"> -1.8399 </td>
   <td style="text-align:right;"> 1.6519 </td>
   <td style="text-align:right;"> 1.6284 </td>
   <td style="text-align:right;"> 1.1642 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0045 </td>
   <td style="text-align:right;"> -0.3580 </td>
   <td style="text-align:right;"> -0.4989 </td>
   <td style="text-align:right;"> -0.9633 </td>
   <td style="text-align:right;"> -0.3909 </td>
   <td style="text-align:right;"> -1.4201 </td>
   <td style="text-align:right;"> 0.9112 </td>
   <td style="text-align:right;"> 0.2166 </td>
  </tr>
</tbody>
</table>


### Niveles de agregación para colapsar la encuesta

Después de realizar una investigación en la literatura especializada y realizar estudios de simulación fue posible evidenciar que las predicciones obtenidas con la muestra sin agregar y la muestra agregada convergen a la media del dominio. 


```r
byAgrega <- c("dam2",  "area", 
              "sexo",   "anoest", "edad",   "etnia" )
```

### Creando base con la encuesta agregada

El resultado de agregar la base de dato se muestra a continuación:


```r
encuesta_df_agg <-
  encuesta_mrp %>%                    # Encuesta  
  group_by_at(all_of(byAgrega)) %>%   # Agrupar por el listado de variables
  summarise(n = n(),                  # Número de observaciones
  # conteo de personas con características similares.           
             pobreza = sum(pobreza),
             no_pobreza = n-pobreza,
            .groups = "drop") %>%     
  arrange(desc(pobreza))                    # Ordenar la base.
```

La tabla obtenida es la siguiente: 

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:left;"> area </th>
   <th style="text-align:left;"> sexo </th>
   <th style="text-align:left;"> anoest </th>
   <th style="text-align:left;"> edad </th>
   <th style="text-align:left;"> etnia </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> pobreza </th>
   <th style="text-align:right;"> no_pobreza </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 15101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 334 </td>
   <td style="text-align:right;"> 59 </td>
   <td style="text-align:right;"> 275 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 391 </td>
   <td style="text-align:right;"> 52 </td>
   <td style="text-align:right;"> 339 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 432 </td>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:right;"> 383 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 15101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 225 </td>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:right;"> 177 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 194 </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:right;"> 147 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04102 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 157 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:right;"> 111 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 15101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 340 </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:right;"> 294 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 265 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 221 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 15101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 98 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 208 </td>
   <td style="text-align:right;"> 44 </td>
   <td style="text-align:right;"> 164 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 06101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 232 </td>
   <td style="text-align:right;"> 43 </td>
   <td style="text-align:right;"> 189 </td>
  </tr>
</tbody>
</table>
El paso a seguir es unificar las tablas creadas. 


```r
encuesta_df_agg <- inner_join(encuesta_df_agg, statelevel_predictors_df)
```

### Definiendo el modelo multinivel.

Después de haber ordenado la encuesta, podemos pasar a la definición del modelo.


```r
options(mc.cores = parallel::detectCores()) # Permite procesar en paralelo. 
fit <- stan_glmer(
  cbind(pobreza, no_pobreza) ~                              
    (1 | dam2) +                          # Efecto aleatorio (ud)
    edad +                               # Efecto fijo (Variables X)
    sexo  + 
    tasa_desocupacion +
  luces_nocturnas +
   cubrimiento_cultivo +
   cubrimiento_urbano +
   modificacion_humana +
   accesibilidad_hospitales + 
   accesibilidad_hosp_caminado ,
                  data = encuesta_df_agg, # Encuesta agregada 
                  verbose = TRUE,         # Muestre el avance del proceso
                  chains = 4,             # Número de cadenas.
                 iter = 1000,              # Número de realizaciones de la cadena
         cores = 4,
      family = binomial(link = "logit")
                )
saveRDS(fit, file = "Recursos/Día3/Sesion3/Data/fit_pobreza2.rds")
```

Después de esperar un tiempo prudente se obtiene el siguiente modelo.


```r
fit <- readRDS("Recursos/Día3/Sesion3/Data/fit_pobreza2.rds")
```

Validación del modelo 



```r
library(posterior)
library(bayesplot)
encuesta_mrp2 <- inner_join(encuesta_mrp %>% filter(), statelevel_predictors_df)
y_pred_B <- posterior_epred(fit, newdata = encuesta_mrp2)
rowsrandom <- sample(nrow(y_pred_B), 100)
y_pred2 <- y_pred_B[rowsrandom, ]
ppc_dens_overlay(y = as.numeric(encuesta_mrp2$pobreza), y_pred2) 
```

<div class="figure" style="text-align: center">
<img src="Recursos/Día3/Sesion3/0Recursos/ppc_pobreza.PNG" alt="Tasa de pobreza por dam2" width="500px" height="250px" />
<p class="caption">(\#fig:unnamed-chunk-13)Tasa de pobreza por dam2</p>
</div>



```r
var_names <- c("luces_nocturnas", "cubrimiento_cultivo","cubrimiento_urbano", 
               "modificacion_humana", "accesibilidad_hospitales",
               "(Intercept)", "edad2","edad3","edad4","edad5")
mcmc_areas(fit,pars = var_names)
```

<img src="Recursos/Día3/Sesion3/0Recursos/pobreza1.PNG" width="500px" height="250px" style="display: block; margin: auto;" />



```r
mcmc_trace(fit,pars = var_names)
```

<img src="Recursos/Día3/Sesion3/0Recursos/pobreza2.PNG" width="500px" height="250px" style="display: block; margin: auto;" />


Los coeficientes del modelo para las primeras dam2 son: 

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> (Intercept) </th>
   <th style="text-align:right;"> edad2 </th>
   <th style="text-align:right;"> edad3 </th>
   <th style="text-align:right;"> edad4 </th>
   <th style="text-align:right;"> edad5 </th>
   <th style="text-align:right;"> sexo2 </th>
   <th style="text-align:right;"> tasa_desocupacion </th>
   <th style="text-align:right;"> luces_nocturnas </th>
   <th style="text-align:right;"> cubrimiento_cultivo </th>
   <th style="text-align:right;"> cubrimiento_urbano </th>
   <th style="text-align:right;"> modificacion_humana </th>
   <th style="text-align:right;"> accesibilidad_hospitales </th>
   <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> -3.1975 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:right;"> -2.5600 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01401 </td>
   <td style="text-align:right;"> -2.7212 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01402 </td>
   <td style="text-align:right;"> -3.3391 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01404 </td>
   <td style="text-align:right;"> -2.2557 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01405 </td>
   <td style="text-align:right;"> -1.6502 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:right;"> -2.8488 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02102 </td>
   <td style="text-align:right;"> -2.7664 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02103 </td>
   <td style="text-align:right;"> -3.2529 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02104 </td>
   <td style="text-align:right;"> -3.5320 </td>
   <td style="text-align:right;"> -0.4901 </td>
   <td style="text-align:right;"> -0.6377 </td>
   <td style="text-align:right;"> -1.0517 </td>
   <td style="text-align:right;"> -1.7314 </td>
   <td style="text-align:right;"> 0.153 </td>
   <td style="text-align:right;"> 14.8301 </td>
   <td style="text-align:right;"> -0.4713 </td>
   <td style="text-align:right;"> -0.0105 </td>
   <td style="text-align:right;"> 0.1646 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> -0.2702 </td>
   <td style="text-align:right;"> 0.1635 </td>
  </tr>
</tbody>
</table>

## Proceso de estimación y predicción

Obtener el modelo es solo un paso más, ahora se debe realizar la predicción en el censo, el cual fue estandarizado y homologado con la encuesta previamente. 


```r
poststrat_df <- readRDS("Recursos/Día3/Sesion3/Data/censo_dam2.rds") %>% 
     inner_join(statelevel_predictors_df) 
tba( poststrat_df %>% arrange(desc(n)) %>% head(10))
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam </th>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:left;"> area </th>
   <th style="text-align:left;"> etnia </th>
   <th style="text-align:left;"> sexo </th>
   <th style="text-align:left;"> edad </th>
   <th style="text-align:left;"> anoest </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> area0 </th>
   <th style="text-align:right;"> area1 </th>
   <th style="text-align:right;"> etnia2 </th>
   <th style="text-align:right;"> sexo2 </th>
   <th style="text-align:right;"> edad2 </th>
   <th style="text-align:right;"> edad3 </th>
   <th style="text-align:right;"> edad4 </th>
   <th style="text-align:right;"> edad5 </th>
   <th style="text-align:right;"> anoest2 </th>
   <th style="text-align:right;"> anoest3 </th>
   <th style="text-align:right;"> anoest4 </th>
   <th style="text-align:right;"> anoest99 </th>
   <th style="text-align:right;"> etnia1 </th>
   <th style="text-align:right;"> piso_tierra </th>
   <th style="text-align:right;"> material_paredes </th>
   <th style="text-align:right;"> material_techo </th>
   <th style="text-align:right;"> rezago_escolar </th>
   <th style="text-align:right;"> alfabeta </th>
   <th style="text-align:right;"> tasa_desocupacion </th>
   <th style="text-align:right;"> pollution_CO </th>
   <th style="text-align:right;"> vegetation_NDVI </th>
   <th style="text-align:right;"> Elevation </th>
   <th style="text-align:right;"> temperature_ECMWF </th>
   <th style="text-align:right;"> temperature_2metros </th>
   <th style="text-align:right;"> total_precipitation </th>
   <th style="text-align:right;"> precipitation </th>
   <th style="text-align:right;"> population_density </th>
   <th style="text-align:right;"> luces_nocturnas </th>
   <th style="text-align:right;"> cubrimiento_cultivo </th>
   <th style="text-align:right;"> cubrimiento_urbano </th>
   <th style="text-align:right;"> modificacion_humana </th>
   <th style="text-align:right;"> accesibilidad_hospitales </th>
   <th style="text-align:right;"> accesibilidad_hosp_caminado </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13201 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 46766 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> 0.5157 </td>
   <td style="text-align:right;"> 0.2513 </td>
   <td style="text-align:right;"> 0.2042 </td>
   <td style="text-align:right;"> 0.2518 </td>
   <td style="text-align:right;"> 0.0765 </td>
   <td style="text-align:right;"> 0.1496 </td>
   <td style="text-align:right;"> 0.4951 </td>
   <td style="text-align:right;"> 0.2124 </td>
   <td style="text-align:right;"> 0.0280 </td>
   <td style="text-align:right;"> 0.1096 </td>
   <td style="text-align:right;"> 4e-04 </td>
   <td style="text-align:right;"> 0.0736 </td>
   <td style="text-align:right;"> 0.6202 </td>
   <td style="text-align:right;"> 0.3179 </td>
   <td style="text-align:right;"> 0.0385 </td>
   <td style="text-align:right;"> 0.0688 </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> -0.8190 </td>
   <td style="text-align:right;"> 0.1107 </td>
   <td style="text-align:right;"> 0.1069 </td>
   <td style="text-align:right;"> 0.1652 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0689 </td>
   <td style="text-align:right;"> 5.1790 </td>
   <td style="text-align:right;"> 2.6378 </td>
   <td style="text-align:right;"> -0.3121 </td>
   <td style="text-align:right;"> 1.8661 </td>
   <td style="text-align:right;"> 1.7482 </td>
   <td style="text-align:right;"> -0.4728 </td>
   <td style="text-align:right;"> -0.1807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13119 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 45879 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.9934 </td>
   <td style="text-align:right;"> 0.0003 </td>
   <td style="text-align:right;"> 0.5192 </td>
   <td style="text-align:right;"> 0.2480 </td>
   <td style="text-align:right;"> 0.1981 </td>
   <td style="text-align:right;"> 0.2666 </td>
   <td style="text-align:right;"> 0.0940 </td>
   <td style="text-align:right;"> 0.1333 </td>
   <td style="text-align:right;"> 0.4843 </td>
   <td style="text-align:right;"> 0.2623 </td>
   <td style="text-align:right;"> 0.0209 </td>
   <td style="text-align:right;"> 0.0989 </td>
   <td style="text-align:right;"> 6e-04 </td>
   <td style="text-align:right;"> 0.0728 </td>
   <td style="text-align:right;"> 0.5547 </td>
   <td style="text-align:right;"> 0.3691 </td>
   <td style="text-align:right;"> 0.0295 </td>
   <td style="text-align:right;"> 0.0673 </td>
   <td style="text-align:right;"> 0.0208 </td>
   <td style="text-align:right;"> -0.6038 </td>
   <td style="text-align:right;"> -0.2372 </td>
   <td style="text-align:right;"> 0.7445 </td>
   <td style="text-align:right;"> 0.8473 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0320 </td>
   <td style="text-align:right;"> 4.8237 </td>
   <td style="text-align:right;"> 2.1005 </td>
   <td style="text-align:right;"> 0.5322 </td>
   <td style="text-align:right;"> 1.1706 </td>
   <td style="text-align:right;"> 1.6470 </td>
   <td style="text-align:right;"> -0.4610 </td>
   <td style="text-align:right;"> -0.1696 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 40861 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0013 </td>
   <td style="text-align:right;"> 0.4890 </td>
   <td style="text-align:right;"> 0.3123 </td>
   <td style="text-align:right;"> 0.3170 </td>
   <td style="text-align:right;"> 0.1746 </td>
   <td style="text-align:right;"> 0.0742 </td>
   <td style="text-align:right;"> 0.0780 </td>
   <td style="text-align:right;"> 0.3337 </td>
   <td style="text-align:right;"> 0.4832 </td>
   <td style="text-align:right;"> 0.0279 </td>
   <td style="text-align:right;"> 0.0798 </td>
   <td style="text-align:right;"> 3e-04 </td>
   <td style="text-align:right;"> 0.2288 </td>
   <td style="text-align:right;"> 0.3063 </td>
   <td style="text-align:right;"> 0.6032 </td>
   <td style="text-align:right;"> 0.0201 </td>
   <td style="text-align:right;"> 0.0581 </td>
   <td style="text-align:right;"> 0.0220 </td>
   <td style="text-align:right;"> -1.4233 </td>
   <td style="text-align:right;"> -0.1928 </td>
   <td style="text-align:right;"> 0.4775 </td>
   <td style="text-align:right;"> 0.6273 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0752 </td>
   <td style="text-align:right;"> 2.4286 </td>
   <td style="text-align:right;"> 2.9204 </td>
   <td style="text-align:right;"> -0.9204 </td>
   <td style="text-align:right;"> 3.7382 </td>
   <td style="text-align:right;"> 2.2047 </td>
   <td style="text-align:right;"> -0.4918 </td>
   <td style="text-align:right;"> -0.1880 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13201 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 39566 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> 0.5157 </td>
   <td style="text-align:right;"> 0.2513 </td>
   <td style="text-align:right;"> 0.2042 </td>
   <td style="text-align:right;"> 0.2518 </td>
   <td style="text-align:right;"> 0.0765 </td>
   <td style="text-align:right;"> 0.1496 </td>
   <td style="text-align:right;"> 0.4951 </td>
   <td style="text-align:right;"> 0.2124 </td>
   <td style="text-align:right;"> 0.0280 </td>
   <td style="text-align:right;"> 0.1096 </td>
   <td style="text-align:right;"> 4e-04 </td>
   <td style="text-align:right;"> 0.0736 </td>
   <td style="text-align:right;"> 0.6202 </td>
   <td style="text-align:right;"> 0.3179 </td>
   <td style="text-align:right;"> 0.0385 </td>
   <td style="text-align:right;"> 0.0688 </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> -0.8190 </td>
   <td style="text-align:right;"> 0.1107 </td>
   <td style="text-align:right;"> 0.1069 </td>
   <td style="text-align:right;"> 0.1652 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0689 </td>
   <td style="text-align:right;"> 5.1790 </td>
   <td style="text-align:right;"> 2.6378 </td>
   <td style="text-align:right;"> -0.3121 </td>
   <td style="text-align:right;"> 1.8661 </td>
   <td style="text-align:right;"> 1.7482 </td>
   <td style="text-align:right;"> -0.4728 </td>
   <td style="text-align:right;"> -0.1807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13201 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 38791 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> 0.5157 </td>
   <td style="text-align:right;"> 0.2513 </td>
   <td style="text-align:right;"> 0.2042 </td>
   <td style="text-align:right;"> 0.2518 </td>
   <td style="text-align:right;"> 0.0765 </td>
   <td style="text-align:right;"> 0.1496 </td>
   <td style="text-align:right;"> 0.4951 </td>
   <td style="text-align:right;"> 0.2124 </td>
   <td style="text-align:right;"> 0.0280 </td>
   <td style="text-align:right;"> 0.1096 </td>
   <td style="text-align:right;"> 4e-04 </td>
   <td style="text-align:right;"> 0.0736 </td>
   <td style="text-align:right;"> 0.6202 </td>
   <td style="text-align:right;"> 0.3179 </td>
   <td style="text-align:right;"> 0.0385 </td>
   <td style="text-align:right;"> 0.0688 </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> -0.8190 </td>
   <td style="text-align:right;"> 0.1107 </td>
   <td style="text-align:right;"> 0.1069 </td>
   <td style="text-align:right;"> 0.1652 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0689 </td>
   <td style="text-align:right;"> 5.1790 </td>
   <td style="text-align:right;"> 2.6378 </td>
   <td style="text-align:right;"> -0.3121 </td>
   <td style="text-align:right;"> 1.8661 </td>
   <td style="text-align:right;"> 1.7482 </td>
   <td style="text-align:right;"> -0.4728 </td>
   <td style="text-align:right;"> -0.1807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13119 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 36744 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.9934 </td>
   <td style="text-align:right;"> 0.0003 </td>
   <td style="text-align:right;"> 0.5192 </td>
   <td style="text-align:right;"> 0.2480 </td>
   <td style="text-align:right;"> 0.1981 </td>
   <td style="text-align:right;"> 0.2666 </td>
   <td style="text-align:right;"> 0.0940 </td>
   <td style="text-align:right;"> 0.1333 </td>
   <td style="text-align:right;"> 0.4843 </td>
   <td style="text-align:right;"> 0.2623 </td>
   <td style="text-align:right;"> 0.0209 </td>
   <td style="text-align:right;"> 0.0989 </td>
   <td style="text-align:right;"> 6e-04 </td>
   <td style="text-align:right;"> 0.0728 </td>
   <td style="text-align:right;"> 0.5547 </td>
   <td style="text-align:right;"> 0.3691 </td>
   <td style="text-align:right;"> 0.0295 </td>
   <td style="text-align:right;"> 0.0673 </td>
   <td style="text-align:right;"> 0.0208 </td>
   <td style="text-align:right;"> -0.6038 </td>
   <td style="text-align:right;"> -0.2372 </td>
   <td style="text-align:right;"> 0.7445 </td>
   <td style="text-align:right;"> 0.8473 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0320 </td>
   <td style="text-align:right;"> 4.8237 </td>
   <td style="text-align:right;"> 2.1005 </td>
   <td style="text-align:right;"> 0.5322 </td>
   <td style="text-align:right;"> 1.1706 </td>
   <td style="text-align:right;"> 1.6470 </td>
   <td style="text-align:right;"> -0.4610 </td>
   <td style="text-align:right;"> -0.1696 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13201 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 36551 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> 0.5157 </td>
   <td style="text-align:right;"> 0.2513 </td>
   <td style="text-align:right;"> 0.2042 </td>
   <td style="text-align:right;"> 0.2518 </td>
   <td style="text-align:right;"> 0.0765 </td>
   <td style="text-align:right;"> 0.1496 </td>
   <td style="text-align:right;"> 0.4951 </td>
   <td style="text-align:right;"> 0.2124 </td>
   <td style="text-align:right;"> 0.0280 </td>
   <td style="text-align:right;"> 0.1096 </td>
   <td style="text-align:right;"> 4e-04 </td>
   <td style="text-align:right;"> 0.0736 </td>
   <td style="text-align:right;"> 0.6202 </td>
   <td style="text-align:right;"> 0.3179 </td>
   <td style="text-align:right;"> 0.0385 </td>
   <td style="text-align:right;"> 0.0688 </td>
   <td style="text-align:right;"> 0.0202 </td>
   <td style="text-align:right;"> -0.8190 </td>
   <td style="text-align:right;"> 0.1107 </td>
   <td style="text-align:right;"> 0.1069 </td>
   <td style="text-align:right;"> 0.1652 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0689 </td>
   <td style="text-align:right;"> 5.1790 </td>
   <td style="text-align:right;"> 2.6378 </td>
   <td style="text-align:right;"> -0.3121 </td>
   <td style="text-align:right;"> 1.8661 </td>
   <td style="text-align:right;"> 1.7482 </td>
   <td style="text-align:right;"> -0.4728 </td>
   <td style="text-align:right;"> -0.1807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 36161 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0013 </td>
   <td style="text-align:right;"> 0.4890 </td>
   <td style="text-align:right;"> 0.3123 </td>
   <td style="text-align:right;"> 0.3170 </td>
   <td style="text-align:right;"> 0.1746 </td>
   <td style="text-align:right;"> 0.0742 </td>
   <td style="text-align:right;"> 0.0780 </td>
   <td style="text-align:right;"> 0.3337 </td>
   <td style="text-align:right;"> 0.4832 </td>
   <td style="text-align:right;"> 0.0279 </td>
   <td style="text-align:right;"> 0.0798 </td>
   <td style="text-align:right;"> 3e-04 </td>
   <td style="text-align:right;"> 0.2288 </td>
   <td style="text-align:right;"> 0.3063 </td>
   <td style="text-align:right;"> 0.6032 </td>
   <td style="text-align:right;"> 0.0201 </td>
   <td style="text-align:right;"> 0.0581 </td>
   <td style="text-align:right;"> 0.0220 </td>
   <td style="text-align:right;"> -1.4233 </td>
   <td style="text-align:right;"> -0.1928 </td>
   <td style="text-align:right;"> 0.4775 </td>
   <td style="text-align:right;"> 0.6273 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0752 </td>
   <td style="text-align:right;"> 2.4286 </td>
   <td style="text-align:right;"> 2.9204 </td>
   <td style="text-align:right;"> -0.9204 </td>
   <td style="text-align:right;"> 3.7382 </td>
   <td style="text-align:right;"> 2.2047 </td>
   <td style="text-align:right;"> -0.4918 </td>
   <td style="text-align:right;"> -0.1880 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13101 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 34816 </td>
   <td style="text-align:right;"> 0.0000 </td>
   <td style="text-align:right;"> 1.0000 </td>
   <td style="text-align:right;"> 0.0013 </td>
   <td style="text-align:right;"> 0.4890 </td>
   <td style="text-align:right;"> 0.3123 </td>
   <td style="text-align:right;"> 0.3170 </td>
   <td style="text-align:right;"> 0.1746 </td>
   <td style="text-align:right;"> 0.0742 </td>
   <td style="text-align:right;"> 0.0780 </td>
   <td style="text-align:right;"> 0.3337 </td>
   <td style="text-align:right;"> 0.4832 </td>
   <td style="text-align:right;"> 0.0279 </td>
   <td style="text-align:right;"> 0.0798 </td>
   <td style="text-align:right;"> 3e-04 </td>
   <td style="text-align:right;"> 0.2288 </td>
   <td style="text-align:right;"> 0.3063 </td>
   <td style="text-align:right;"> 0.6032 </td>
   <td style="text-align:right;"> 0.0201 </td>
   <td style="text-align:right;"> 0.0581 </td>
   <td style="text-align:right;"> 0.0220 </td>
   <td style="text-align:right;"> -1.4233 </td>
   <td style="text-align:right;"> -0.1928 </td>
   <td style="text-align:right;"> 0.4775 </td>
   <td style="text-align:right;"> 0.6273 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0752 </td>
   <td style="text-align:right;"> 2.4286 </td>
   <td style="text-align:right;"> 2.9204 </td>
   <td style="text-align:right;"> -0.9204 </td>
   <td style="text-align:right;"> 3.7382 </td>
   <td style="text-align:right;"> 2.2047 </td>
   <td style="text-align:right;"> -0.4918 </td>
   <td style="text-align:right;"> -0.1880 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 13 </td>
   <td style="text-align:left;"> 13119 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 32897 </td>
   <td style="text-align:right;"> 0.0066 </td>
   <td style="text-align:right;"> 0.9934 </td>
   <td style="text-align:right;"> 0.0003 </td>
   <td style="text-align:right;"> 0.5192 </td>
   <td style="text-align:right;"> 0.2480 </td>
   <td style="text-align:right;"> 0.1981 </td>
   <td style="text-align:right;"> 0.2666 </td>
   <td style="text-align:right;"> 0.0940 </td>
   <td style="text-align:right;"> 0.1333 </td>
   <td style="text-align:right;"> 0.4843 </td>
   <td style="text-align:right;"> 0.2623 </td>
   <td style="text-align:right;"> 0.0209 </td>
   <td style="text-align:right;"> 0.0989 </td>
   <td style="text-align:right;"> 6e-04 </td>
   <td style="text-align:right;"> 0.0728 </td>
   <td style="text-align:right;"> 0.5547 </td>
   <td style="text-align:right;"> 0.3691 </td>
   <td style="text-align:right;"> 0.0295 </td>
   <td style="text-align:right;"> 0.0673 </td>
   <td style="text-align:right;"> 0.0208 </td>
   <td style="text-align:right;"> -0.6038 </td>
   <td style="text-align:right;"> -0.2372 </td>
   <td style="text-align:right;"> 0.7445 </td>
   <td style="text-align:right;"> 0.8473 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0320 </td>
   <td style="text-align:right;"> 4.8237 </td>
   <td style="text-align:right;"> 2.1005 </td>
   <td style="text-align:right;"> 0.5322 </td>
   <td style="text-align:right;"> 1.1706 </td>
   <td style="text-align:right;"> 1.6470 </td>
   <td style="text-align:right;"> -0.4610 </td>
   <td style="text-align:right;"> -0.1696 </td>
  </tr>
</tbody>
</table>
Note que la información del censo esta agregada.

### Distribución posterior.

Para obtener una distribución posterior de cada observación se hace uso de la función *posterior_epred* de la siguiente forma.


```r
epred_mat <- posterior_epred(fit, newdata = poststrat_df, type = "response")
dim(epred_mat)
dim(poststrat_df)
```


### Estimación de la tasa de pobreza





```r
n_filtered <- poststrat_df$n
mrp_estimates <- epred_mat %*% n_filtered / sum(n_filtered)

(temp_ing <- data.frame(
  mrp_estimate = mean(mrp_estimates),
  mrp_estimate_se = sd(mrp_estimates)
) ) %>% tba()
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.1094 </td>
   <td style="text-align:right;"> 8e-04 </td>
  </tr>
</tbody>
</table>

El resultado nos indica que el ingreso medio nacional es 0.11 lineas de pobreza

### Estimación para el dam == "05".

Es importante siempre conservar el orden de la base, dado que relación entre la predicción y el censo en uno a uno.


```r
temp <- poststrat_df %>%  mutate( Posi = 1:n())
temp <- filter(temp, dam == "05") %>% select(n, Posi)
n_filtered <- temp$n
temp_epred_mat <- epred_mat[, temp$Posi]

## Estimando el CME
mrp_estimates <- temp_epred_mat %*% n_filtered / sum(n_filtered)

(temp_dam05 <- data.frame(
  mrp_estimate = mean(mrp_estimates),
  mrp_estimate_se = sd(mrp_estimates)
) ) %>% tba()
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0956 </td>
   <td style="text-align:right;"> 0.0022 </td>
  </tr>
</tbody>
</table>

El resultado nos indica que la tasa de pobreza en la dam 44 es 0.1

### Estimación para la dam2 == "05201"


```r
temp <- poststrat_df %>%  mutate(Posi = 1:n())
temp <-
  filter(temp, dam2 == "05201") %>% select(n, Posi)
n_filtered <- temp$n
temp_epred_mat <- epred_mat[, temp$Posi]
## Estimando el CME
mrp_estimates <- temp_epred_mat %*% n_filtered / sum(n_filtered)

(temp_dam2_05201 <- data.frame(
  mrp_estimate = mean(mrp_estimates),
  mrp_estimate_se = sd(mrp_estimates)
) ) %>% tba()
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.0809 </td>
   <td style="text-align:right;"> 0.0408 </td>
  </tr>
</tbody>
</table>

El resultado nos indica que la tasa de pobreza en la dam2  05201 es 0.08

Después de comprender la forma en que se realiza la estimación de los dominios no observados procedemos el uso de la función *Aux_Agregado* que es desarrollada para este fin.


```r
(mrp_estimate_Ingresolp <-
  Aux_Agregado(poststrat = poststrat_df,
             epredmat = epred_mat,
             byMap = NULL)
) %>% tba()
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Nacional </th>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Nacional </td>
   <td style="text-align:right;"> 0.1094 </td>
   <td style="text-align:right;"> 8e-04 </td>
  </tr>
</tbody>
</table>

De forma similar es posible obtener los resultados para las divisiones administrativas del país.  


```r
mrp_estimate_dam <-
  Aux_Agregado(poststrat = poststrat_df,
             epredmat = epred_mat,
             byMap = "dam")
tba(mrp_estimate_dam %>% head(10))
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam </th>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:right;"> 0.1055 </td>
   <td style="text-align:right;"> 0.0031 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02 </td>
   <td style="text-align:right;"> 0.0829 </td>
   <td style="text-align:right;"> 0.0029 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:right;"> 0.1183 </td>
   <td style="text-align:right;"> 0.0039 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:right;"> 0.1661 </td>
   <td style="text-align:right;"> 0.0037 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 05 </td>
   <td style="text-align:right;"> 0.0956 </td>
   <td style="text-align:right;"> 0.0022 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 06 </td>
   <td style="text-align:right;"> 0.1159 </td>
   <td style="text-align:right;"> 0.0027 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 07 </td>
   <td style="text-align:right;"> 0.1360 </td>
   <td style="text-align:right;"> 0.0031 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 08 </td>
   <td style="text-align:right;"> 0.1446 </td>
   <td style="text-align:right;"> 0.0025 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 09 </td>
   <td style="text-align:right;"> 0.1745 </td>
   <td style="text-align:right;"> 0.0030 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10 </td>
   <td style="text-align:right;"> 0.1236 </td>
   <td style="text-align:right;"> 0.0031 </td>
  </tr>
</tbody>
</table>


```r
mrp_estimate_dam2 <-
  Aux_Agregado(poststrat = poststrat_df,
             epredmat = epred_mat,
             byMap = "dam2")

tba(mrp_estimate_dam2 %>% head(10) )
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> mrp_estimate </th>
   <th style="text-align:right;"> mrp_estimate_se </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 0.0728 </td>
   <td style="text-align:right;"> 0.0032 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:right;"> 0.1613 </td>
   <td style="text-align:right;"> 0.0065 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01401 </td>
   <td style="text-align:right;"> 0.1098 </td>
   <td style="text-align:right;"> 0.0177 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01402 </td>
   <td style="text-align:right;"> 0.0325 </td>
   <td style="text-align:right;"> 0.0132 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01403 </td>
   <td style="text-align:right;"> 0.0918 </td>
   <td style="text-align:right;"> 0.0452 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01404 </td>
   <td style="text-align:right;"> 0.1136 </td>
   <td style="text-align:right;"> 0.0225 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01405 </td>
   <td style="text-align:right;"> 0.1321 </td>
   <td style="text-align:right;"> 0.0239 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:right;"> 0.0889 </td>
   <td style="text-align:right;"> 0.0038 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02102 </td>
   <td style="text-align:right;"> 0.0848 </td>
   <td style="text-align:right;"> 0.0189 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02103 </td>
   <td style="text-align:right;"> 0.0215 </td>
   <td style="text-align:right;"> 0.0090 </td>
  </tr>
</tbody>
</table>


El mapa resultante es el siguiente 




<div class="figure" style="text-align: center">
<img src="Recursos/Día3/Sesion3/0Recursos/Map_CHL.PNG" alt="Tasa de pobreza por dam2" width="400%" />
<p class="caption">(\#fig:unnamed-chunk-35)Tasa de pobreza por dam2</p>
</div>

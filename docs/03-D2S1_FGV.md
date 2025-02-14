
# Día 2 - Sesión 1- Estimaciones CASEN y Función Generalizada de Varianza



Uno de los insumos más importantes en el modelo de áreas es la 
varianza del estimador directo, a nivel de dominio, la cual no puede calcularse de ningún modo. En correspondencia, este valor debe estimarse desde los datos recolectados en cada dominio. Sin embargo, 
en dominios en las que se cuenta con un tamaño de muestra muy pequeño, estas estimaciones no tendrán un buen comportamiento. Por ende, es muy útil utilizar un modelo de **suavizamiento** de las varianzas para 
eliminar el ruido y la volatilidad de estas estimaciones y extraer la verdadera señal del proceso

Hidiroglou (2019) afirma que $E_{\mathscr{MP}}\left(\hat{\theta}^{dir}_d\right)=\boldsymbol{x}^{T}_{d}\boldsymbol{\beta}$ y $V_{\mathscr{MP}}\left(\hat{\theta}^{dir}_d\right)=\sigma_{u}^2+\tilde{\sigma}^2_{d}$, en donde el subíndice  $\mathscr{MP}$ hace referencia a la inferencia doble que se debe tener en cuenta en este tipo de ajustes y define la medida de probabilidad conjunta entre el modelo y el diseño de muestreo.  

-   $\mathscr{M}$ hace referencia a la medida de probabilidad inducida por el modelamiento y la inclusión de las covariables auxiliares ($\boldsymbol{x}_{d}$).

-   $\mathscr{MP}$ hace referencia a la medida de probabilidad inducida por el diseño de muestreo complejo que 
induce las estimaciones directas. 

La solución que acá se plantea se conoce con el nombre de Función Generalizada de Varianza, la cual consiste en ajustar un modelo log-lineal a la varianza directa estimada. Partiendo del hecho de que
se tiene acceso a un estimador insesgado de $\sigma^2$, denotado por $\hat{\sigma}^2$ se tiene que:
$$
E_{\mathscr{MP}}\left(\hat{\sigma}_{d}^{2}\right)=E_{\mathscr{M}}\left(E_{\mathscr{P}}\left(\hat{\sigma}_{d}^{2}\right)\right)=E_{\mathscr{M}}\left(\sigma_{d}^{2}\right)=\tilde{\sigma}_{d}^{2}
$$

La anterior igualdad puede interpretarse como que un estimador insesgado y simple de $\tilde{\sigma}_{d}^{2}$ puede ser $\hat{\sigma}_{d}^{2}$. Sin embargo, este estimador de muestreo es inestable cuando el tamaño de muestra es pequeño, que es justo el paradigma dominante en la estimación de áreas pequeñas. Rivest and Belmonte (2000) consideran modelos de suavizamiento para la estimación de las varianzas directas definidos de la siguiente manera:

$$
\log\left(\hat{\sigma}_{d}^{2}\right)=\boldsymbol{z}_{d}^{T}\boldsymbol{\alpha}+\boldsymbol{\varepsilon}_{d}
$$

En donde $\boldsymbol{z}_{d}$ es un vector de covariables explicativas que son funciones de $\boldsymbol{x}_{d}$, $\boldsymbol{\alpha}$ es un vector de parámetros que deben ser estimados, $\boldsymbol{\varepsilon}_{d}$ son errores aleatorios con media cero y varianza constante, que se asumen idénticamente distribuidos condicionalmente sobre $\boldsymbol{z}_{d}$. Del anterior modelo, la
estimación suavizada de la varianza de muestreo está dada por:
$$
\tilde{\sigma}_{d}^{2}=E_{\mathscr{MP}}\left(\sigma_{d}^{2}\right)=\exp\left(\boldsymbol{z}_{d}^{T}\boldsymbol{\alpha}\right)\times\Delta
$$

En donde, $E_{\mathscr{MP}}\left(\varepsilon_{d}\right)=\Delta$. No hay necesidad de especificar una distribución paramétrica para los
errores de este modelo. Al utilizar el método de los momentos, se tiene el siguiente estimador insesgado para $\Delta$: 
$$
\hat{\Delta}=\frac{\sum_{d=1}^{D}\hat{\sigma}_{d}^{2}}{\sum_{d=1}^{D}\exp\left(\boldsymbol{z}_{d}^{T}\boldsymbol{\alpha}\right)}
$$

De la misma forma, al utilizar los procedimientos estándar en una regresión lineal, la estimación del coeficiente de parámetros de regresión está dada por la siguiente expresión:

$$
\hat{\boldsymbol{\alpha}}=\left(\sum_{d=1}^{D}\boldsymbol{z}_{d}\boldsymbol{z}_{d}^{T}\right)^{-1}\sum_{d=1}^{D}\boldsymbol{z}_{d}\log\left(\hat{\sigma}_{d}^{2}\right)
$$

Por último, el estimador suavizado de la varianza muestral está definido por:

$$
\hat{\tilde{\sigma}}_{d}^{2}=\exp\left(\boldsymbol{z}_{d}^{T}\hat{\boldsymbol{\alpha}}\right)\hat{\Delta}
$$

## Datos de la encuesta

El siguiente bloque de código utiliza varias librerías en R (`tidyverse` y `magrittr`), así como también utiliza una función definida en otro archivo (source("Recursos/Día2/Sesion1/0Recursos/0Source_FH.R")).

Luego, el código carga la encuesta que esta almacenada en un archivo de datos en formato RDS y utiliza la función `%>%` para encadenar una serie de transformaciones en los datos:

  -   `transmute()` se utiliza para seleccionar y renombrar columnas. 
  
  -   Se crea una nueva variable llamada `pobreza` que se establece en 1 si la variable `ingcorte`(ingreso percapital) es menor que la variable `lp`, y en 0 en caso contrario. La función `ifelse()` se utiliza para asignar valores a la variable "pobreza" en función de si el ingreso de un individuo es menor o mayor que el umbral de pobreza.


```r
library(tidyverse)
library(magrittr)
source("Recursos/Día2/Sesion1/0Recursos/0Source_FH.R")

encuesta <- readRDS("Recursos/Día2/Sesion1/Data/encuesta2017CHL.Rds") %>% 
  transmute(
    dam =  haven::as_factor(dam_ee ,levels = "values"),
    dam2 =  haven::as_factor(comuna,levels = "values"),
    dam = str_pad(dam, width = 2, pad = "0"),
    dam2 = str_pad(dam2, width = 5, pad = "0"),
    wkx = `_fep`, 
    upm = `_upm`,
    estrato = `_estrato`,
    pobreza = ifelse(ingcorte < lp, 1 , 0))
```

-   *dam*: Corresponde al código asignado a la división administrativa mayor del país.

-   *dam2*: Corresponde al código asignado a la segunda división administrativa del país.

-   *lp* Linea de pobreza definida por CEPAL. 

-   *wkx* Factor de expansión por persona


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam </th>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> wkx </th>
   <th style="text-align:right;"> upm </th>
   <th style="text-align:right;"> estrato </th>
   <th style="text-align:right;"> pobreza </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:right;"> 1100100001 </td>
   <td style="text-align:right;"> 11001 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>

En el siguiente bloque de código  utiliza las librerías `survey` y `srvyr` para crear un diseño de muestreo a partir de una base de datos de encuestas. El diseño de muestreo incluye información sobre las unidades primarias de muestreo (UPM), los pesos de muestreo (wkx), y las estratas (estrato) utilizadas en el muestreo. Además, se utiliza la opción "survey.lonely.psu" para ajustar los tamaños de muestra en los grupos de unidades primarias de muestreo que no tienen otras unidades primarias de muestreo en el mismo grupo.


```r
library(survey)
library(srvyr)
options(survey.lonely.psu = "adjust")

diseno <-
  as_survey_design(
    ids = upm,
    weights = wkx,
    strata = estrato,
    nest = TRUE,
    .data = encuesta
  )
#summary(diseno)
```

Para la estimación directa de la proporción se emplea la función `direct.supr`, disponible en el archivo `0Source_FH.R`. Está función realiza las estimaciones y criterios de calidad en una encuesta de muestreo complejo con diseño estratificado y por conglomerados. Toma cinco argumentos: `design.base`, `variable`, `group`, `upm` y `estrato`.

La función comienza cargando varios paquetes, como `rlang`, `tidyverse`, `dplyr`, `survey` y `srvyr.` Luego, los argumentos `group`, `variable`, `upm` y `estrato` se convierten en argumentos utilizando la función enquo.

La función utiliza la encuesta de muestreo complejo `design.base` para calcular las estimaciones de los parámetros y los criterios de calidad. Utiliza la función `survey_mean()` de la librería `survey` para calcular la media y los intervalos de confianza de la variable de interés. La función también calcula otros indicadores de calidad, como el coeficiente de variación, el tamaño de muestra efectivo y el efecto del diseño. Luego, utiliza la función `as.data.frame()` para convertir los resultados en un objeto de marco de datos.

Además, la función calcula otros criterios de calidad para determinar si las estimaciones son confiables. En particular, evalúa si se cumple un umbral mínimo para el número de grados de libertad, si la muestra es suficientemente grande y si el efecto del diseño es razonable. La función también tiene la opción de incluir o excluir ciertos grupos de muestreo basados en sus características.


```r
directodam2 <- direct.supr(design.base = diseno,
                             variable = pobreza, 
                             group = dam2,
                             upm = upm,
                             estrato = estrato)



directodam2 %>%
  group_by(Flag) %>%
  summarise(n = n()) %>% 
  arrange(n) %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Flag </th>
   <th style="text-align:right;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Incluir </td>
   <td style="text-align:right;"> 102 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Excluir </td>
   <td style="text-align:right;"> 222 </td>
  </tr>
</tbody>
</table>


Para los dominios que no son excluidos se hace la transformación arcoseno, calculo del *DEFF* y varianza 


```r
base_sae <- directodam2 %>% 
  filter(Flag != "Excluir") %>%
  transmute(
    dam2 = dam2,             # Id para los dominios
    nd = n,                    # Número de observaciones por dominios
    n_effec = n.eff,           # n efectivo. 
    pobreza = p,               # Estimación de la variable
    vardir = ee ^ 2,                 # Estimación de la varianza directa 
    cv = CV,                       
    deff_dam2 = deff                # Deff por dominio
  )

# View(base_sae)
tba(head(base_sae))
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> nd </th>
   <th style="text-align:right;"> n_effec </th>
   <th style="text-align:right;"> pobreza </th>
   <th style="text-align:right;"> vardir </th>
   <th style="text-align:right;"> cv </th>
   <th style="text-align:right;"> deff_dam2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 6447 </td>
   <td style="text-align:right;"> 1540.5327 </td>
   <td style="text-align:right;"> 0.0764 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 13.7671 </td>
   <td style="text-align:right;"> 4.1849 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:right;"> 3015 </td>
   <td style="text-align:right;"> 874.1965 </td>
   <td style="text-align:right;"> 0.1624 </td>
   <td style="text-align:right;"> 4e-04 </td>
   <td style="text-align:right;"> 11.7319 </td>
   <td style="text-align:right;"> 3.4489 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:right;"> 5473 </td>
   <td style="text-align:right;"> 729.6790 </td>
   <td style="text-align:right;"> 0.0905 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 13.0383 </td>
   <td style="text-align:right;"> 7.5006 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02201 </td>
   <td style="text-align:right;"> 1759 </td>
   <td style="text-align:right;"> 129.0530 </td>
   <td style="text-align:right;"> 0.0772 </td>
   <td style="text-align:right;"> 5e-04 </td>
   <td style="text-align:right;"> 28.2624 </td>
   <td style="text-align:right;"> 13.6301 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 03101 </td>
   <td style="text-align:right;"> 3757 </td>
   <td style="text-align:right;"> 717.2133 </td>
   <td style="text-align:right;"> 0.1011 </td>
   <td style="text-align:right;"> 3e-04 </td>
   <td style="text-align:right;"> 16.0821 </td>
   <td style="text-align:right;"> 5.2383 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 03301 </td>
   <td style="text-align:right;"> 1221 </td>
   <td style="text-align:right;"> 1165.6410 </td>
   <td style="text-align:right;"> 0.1106 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 10.4785 </td>
   <td style="text-align:right;"> 1.0475 </td>
  </tr>
</tbody>
</table>

seguidamente se realiza la transformación $\log(\hat{\sigma}^2_d)$, además se realiza la selección de las columnas identificador del municipio (`dam2`), la estimación directa  (`pobreza`), El número de personas en el dominio (`nd`) y la varianza estimada del para la estimación directa `vardir`,siendo esta la que transforma mediante la función `log()`. 


```r
baseFGV <-  base_sae %>% 
  select(dam2, pobreza, nd, vardir) %>%
  mutate(ln_sigma2 = log(vardir))
```

## Análisis gráfico

El primer gráfico, `p1`, muestra una gráfica de dispersión de la variable `ln_sigma2` en función de la variable `pobreza`, con una línea suave que representa una estimación de la tendencia. El eje x está etiquetado como _pobreza_.

El segundo gráfico, `p2`, muestra una gráfica de dispersión de la variable `ln_sigma2` en función de la variable `nd`, con una línea suave que representa una estimación de la tendencia. El eje x está etiquetado como _Tamaño de muestra_.

El tercer gráfico, `p3`, muestra una gráfica de dispersión de la variable `ln_sigma2` en función del producto de `pobreza` y `nd`, con una línea suave que representa una estimación de la tendencia. El eje x está etiquetado como _Número de pobres_.

El cuarto gráfico, `p4`, muestra una gráfica de dispersión de la variable `ln_sigma2` en función de la raíz cuadrada de la variable `pobreza`, con una línea suave que representa una estimación de la tendencia. El eje x está etiquetado como _Raiz cuadrada de pobreza_.


En general, los gráficos estan diseñados para explorar la relación entre `ln_sigma2` y diferentes variables independientes, como `pobreza`, `nd`, y la raíz cuadrada de la pobreza. La elección de utilizar la función "loess" para suavizar las líneas en lugar de una línea recta puede ayudar a visualizar mejor las tendencias generales en los datos.


```r
theme_set(theme_bw())

# pobreza vs Ln_sigma2 #

p1 <- ggplot(baseFGV, aes(x = pobreza, y = ln_sigma2)) +
  geom_point() +
  geom_smooth(method = "loess") +
  xlab("pobreza")

# Tamaño de muestra vs Ln_sigma2 #

p2 <- ggplot(baseFGV, aes(x = nd, y = ln_sigma2)) + 
  geom_point() +
  geom_smooth(method = "loess") + 
  xlab("Tamaño de muestra")

# Número de pobres vs Ln_sigma2 #

p3 <- ggplot(baseFGV, 
             aes(x = pobreza * nd, y = ln_sigma2)) + 
  geom_point() +
  geom_smooth(method = "loess") + 
  xlab("Número de pobres")

# Raiz_pobreza vs Ln_sigma2 #

p4 <- ggplot(baseFGV, 
             aes(x = sqrt(pobreza), y = ln_sigma2)) + 
  geom_point() +
  geom_smooth(method = "loess") + 
  xlab("Raiz cuadrada de pobreza")

library(patchwork)
(p1 | p2) / (p3 | p4)
```

<img src="03-D2S1_FGV_files/figure-html/unnamed-chunk-8-1.svg" width="672" />

## Modelo para la varianza

El código ajusta un modelo de regresión lineal múltiple (utilizando la función `lm()`), donde `ln_sigma2` es la variable respuesta y las variables predictoras son `pobreza`, `nd`, y varias transformaciones de éstas. El objetivo de este modelo es estimar la función generalizada de varianza (FGV) para los dominios observados.


```r
library(gtsummary)
FGV1 <- lm(ln_sigma2 ~ 1+  I(nd^2) + I(sqrt(pobreza)) +
             I(log(nd^pobreza)),
     data = baseFGV)

tbl_regression(FGV1) %>% 
  add_glance_table(include = c(r.squared, adj.r.squared))
```

```{=html}
<div id="daobdskdev" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#daobdskdev table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#daobdskdev thead, #daobdskdev tbody, #daobdskdev tfoot, #daobdskdev tr, #daobdskdev td, #daobdskdev th {
  border-style: none;
}

#daobdskdev p {
  margin: 0;
  padding: 0;
}

#daobdskdev .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#daobdskdev .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#daobdskdev .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#daobdskdev .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#daobdskdev .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#daobdskdev .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#daobdskdev .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#daobdskdev .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#daobdskdev .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#daobdskdev .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#daobdskdev .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#daobdskdev .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#daobdskdev .gt_spanner_row {
  border-bottom-style: hidden;
}

#daobdskdev .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#daobdskdev .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#daobdskdev .gt_from_md > :first-child {
  margin-top: 0;
}

#daobdskdev .gt_from_md > :last-child {
  margin-bottom: 0;
}

#daobdskdev .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#daobdskdev .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#daobdskdev .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#daobdskdev .gt_row_group_first td {
  border-top-width: 2px;
}

#daobdskdev .gt_row_group_first th {
  border-top-width: 2px;
}

#daobdskdev .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#daobdskdev .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#daobdskdev .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#daobdskdev .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#daobdskdev .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#daobdskdev .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#daobdskdev .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#daobdskdev .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#daobdskdev .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#daobdskdev .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#daobdskdev .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#daobdskdev .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#daobdskdev .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#daobdskdev .gt_left {
  text-align: left;
}

#daobdskdev .gt_center {
  text-align: center;
}

#daobdskdev .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#daobdskdev .gt_font_normal {
  font-weight: normal;
}

#daobdskdev .gt_font_bold {
  font-weight: bold;
}

#daobdskdev .gt_font_italic {
  font-style: italic;
}

#daobdskdev .gt_super {
  font-size: 65%;
}

#daobdskdev .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#daobdskdev .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#daobdskdev .gt_indent_1 {
  text-indent: 5px;
}

#daobdskdev .gt_indent_2 {
  text-indent: 10px;
}

#daobdskdev .gt_indent_3 {
  text-indent: 15px;
}

#daobdskdev .gt_indent_4 {
  text-indent: 20px;
}

#daobdskdev .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Characteristic&lt;/strong&gt;"><strong>Characteristic</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;Beta&lt;/strong&gt;"><strong>Beta</strong></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;95% CI&lt;/strong&gt;&lt;span class=&quot;gt_footnote_marks&quot; style=&quot;white-space:nowrap;font-style:italic;font-weight:normal;&quot;&gt;&lt;sup&gt;1&lt;/sup&gt;&lt;/span&gt;"><strong>95% CI</strong><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span></th>
      <th class="gt_col_heading gt_columns_bottom_border gt_center" rowspan="1" colspan="1" scope="col" id="&lt;strong&gt;p-value&lt;/strong&gt;"><strong>p-value</strong></th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="label" class="gt_row gt_left">I(nd^2)</td>
<td headers="estimate" class="gt_row gt_center">0.00</td>
<td headers="ci" class="gt_row gt_center">0.00, 0.00</td>
<td headers="p.value" class="gt_row gt_center">0.017</td></tr>
    <tr><td headers="label" class="gt_row gt_left">I(sqrt(pobreza))</td>
<td headers="estimate" class="gt_row gt_center">26</td>
<td headers="ci" class="gt_row gt_center">20, 33</td>
<td headers="p.value" class="gt_row gt_center"><0.001</td></tr>
    <tr><td headers="label" class="gt_row gt_left">I(log(nd^pobreza))</td>
<td headers="estimate" class="gt_row gt_center">-4.2</td>
<td headers="ci" class="gt_row gt_center">-5.8, -2.6</td>
<td headers="p.value" class="gt_row gt_center"><0.001</td></tr>
    <tr><td headers="label" class="gt_row gt_left" style="border-top-width: 2px; border-top-style: solid; border-top-color: #D3D3D3;">R²</td>
<td headers="estimate" class="gt_row gt_center" style="border-top-width: 2px; border-top-style: solid; border-top-color: #D3D3D3;">0.659</td>
<td headers="ci" class="gt_row gt_center" style="border-top-width: 2px; border-top-style: solid; border-top-color: #D3D3D3;"></td>
<td headers="p.value" class="gt_row gt_center" style="border-top-width: 2px; border-top-style: solid; border-top-color: #D3D3D3;"></td></tr>
    <tr><td headers="label" class="gt_row gt_left">Adjusted R²</td>
<td headers="estimate" class="gt_row gt_center">0.648</td>
<td headers="ci" class="gt_row gt_center"></td>
<td headers="p.value" class="gt_row gt_center"></td></tr>
  </tbody>
  
  <tfoot class="gt_footnotes">
    <tr>
      <td class="gt_footnote" colspan="4"><span class="gt_footnote_marks" style="white-space:nowrap;font-style:italic;font-weight:normal;"><sup>1</sup></span> CI = Confidence Interval</td>
    </tr>
  </tfoot>
</table>
</div>
```

Después de tener la estimación del modelo se debe obtener el  valor de la constante $\Delta$ para lo cual se usa el siguiente código. 


```r
delta.hat = sum(baseFGV$vardir) / 
  sum(exp(fitted.values(FGV1)))
```

De donde se obtiene que $\Delta = 1.27249$. Final es posible obtener la varianza suavizada  ejecutando el siguiente comando.  


```r
hat.sigma <- 
  data.frame(dam2 = baseFGV$dam2,
             hat_var = delta.hat * exp(fitted.values(FGV1)))

baseFGV <- left_join(baseFGV, hat.sigma)
tba(head(baseFGV, 10))
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> dam2 </th>
   <th style="text-align:right;"> pobreza </th>
   <th style="text-align:right;"> nd </th>
   <th style="text-align:right;"> vardir </th>
   <th style="text-align:right;"> ln_sigma2 </th>
   <th style="text-align:right;"> hat_var </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 01101 </td>
   <td style="text-align:right;"> 0.0764 </td>
   <td style="text-align:right;"> 6447 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> -9.1085 </td>
   <td style="text-align:right;"> 1e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 01107 </td>
   <td style="text-align:right;"> 0.1624 </td>
   <td style="text-align:right;"> 3015 </td>
   <td style="text-align:right;"> 0.0004 </td>
   <td style="text-align:right;"> -7.9210 </td>
   <td style="text-align:right;"> 5e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02101 </td>
   <td style="text-align:right;"> 0.0905 </td>
   <td style="text-align:right;"> 5473 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> -8.8804 </td>
   <td style="text-align:right;"> 2e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02201 </td>
   <td style="text-align:right;"> 0.0772 </td>
   <td style="text-align:right;"> 1759 </td>
   <td style="text-align:right;"> 0.0005 </td>
   <td style="text-align:right;"> -7.6500 </td>
   <td style="text-align:right;"> 4e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 03101 </td>
   <td style="text-align:right;"> 0.1011 </td>
   <td style="text-align:right;"> 3757 </td>
   <td style="text-align:right;"> 0.0003 </td>
   <td style="text-align:right;"> -8.2383 </td>
   <td style="text-align:right;"> 3e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 03301 </td>
   <td style="text-align:right;"> 0.1106 </td>
   <td style="text-align:right;"> 1221 </td>
   <td style="text-align:right;"> 0.0001 </td>
   <td style="text-align:right;"> -8.9152 </td>
   <td style="text-align:right;"> 7e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04101 </td>
   <td style="text-align:right;"> 0.1710 </td>
   <td style="text-align:right;"> 2719 </td>
   <td style="text-align:right;"> 0.0002 </td>
   <td style="text-align:right;"> -8.4038 </td>
   <td style="text-align:right;"> 5e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04102 </td>
   <td style="text-align:right;"> 0.1930 </td>
   <td style="text-align:right;"> 2498 </td>
   <td style="text-align:right;"> 0.0005 </td>
   <td style="text-align:right;"> -7.6308 </td>
   <td style="text-align:right;"> 5e-04 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04203 </td>
   <td style="text-align:right;"> 0.1004 </td>
   <td style="text-align:right;"> 482 </td>
   <td style="text-align:right;"> 0.0011 </td>
   <td style="text-align:right;"> -6.8172 </td>
   <td style="text-align:right;"> 1e-03 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 04301 </td>
   <td style="text-align:right;"> 0.0902 </td>
   <td style="text-align:right;"> 1323 </td>
   <td style="text-align:right;"> 0.0005 </td>
   <td style="text-align:right;"> -7.6734 </td>
   <td style="text-align:right;"> 6e-04 </td>
  </tr>
</tbody>
</table>

 Validación del modelo para la FGV


```r
par(mfrow = c(2, 2))
plot(FGV1)
```

<img src="03-D2S1_FGV_files/figure-html/unnamed-chunk-12-1.svg" width="672" />

 Comparación entre la varianza estimada versus la pronosticada por la FGV


```r
ggplot(baseFGV , 
       aes(y = vardir, x = hat_var)) + 
  geom_point() +
  geom_smooth(method = "loess") + 
    labs(x = "FGV", y = "VarDirEst") +
  ylab("Varianza del Estimador Directo")
```

<img src="03-D2S1_FGV_files/figure-html/unnamed-chunk-13-1.svg" width="672" />

Predicción de la varianza suavizada


```r
base_sae <- base_sae %>%  left_join(hat.sigma, by = "dam2")
```

Ahora, realizamos un gráfico de linea para ver la volatilidad es la estimaciones de las varianzas. 

```{.r .fold-hide}
ggplot(base_sae %>%
         arrange(nd), aes(x = 1:nrow(base_sae))) +
  geom_line(aes(y = vardir, color = "VarDirEst")) +
  geom_line(aes(y = hat_var, color = "FGV")) +
  labs(y = "Varianzas", x = "Tamaño muestral", color = " ") +
  scale_x_continuous(breaks = seq(1, nrow(base_sae), by = 10),
                     labels = base_sae$nd[order(base_sae$nd)][seq(1, nrow(base_sae), by = 10)]) +
  scale_color_manual(values = c("FGV" = "Blue", "VarDirEst" = "Red"))
```

<img src="03-D2S1_FGV_files/figure-html/unnamed-chunk-15-1.svg" width="672" />


El siguiente código utiliza la función `mutate()` del paquete `dplyr` para crear nuevas variables de la base de datos `base_sae` y luego guarda el resultado en un archivo RDS llamado `base_FH_2017.rds.`

En concreto, el código realiza las siguientes operaciones:

  -   La variable `deff_dam2` se ajusta a 1 cuando es NaN.
  
  -   La variable `deff_FGV` se calcula a partir de otras dos variables `hat_var` y `vardir.` Si `vardir` es 0, entonces `deff_FGV` se ajusta a 1. En caso contrario, se divide `hat_var` por v`ardir / deff_dam2` para obtener `deff_FGV.`

  -   La variable `deff_FGV` se regulariza utilizando el criterio MDS: si `deff_FGV` es menor que 1, se ajusta a 1.
  
  -   Finalmente, se calcula la variable `n_eff_FGV` dividiendo `nd` (el tamaño de la muestra) por `deff_FGV.`




```r
base_FH <- base_sae %>%
  mutate(
    deff_dam2 = ifelse(is.nan(deff_dam2), 1,
                         deff_dam2),
    deff_FGV = ifelse(
      vardir == 0 ,
      1,
      hat_var / (vardir / deff_dam2)
    ),
    # Criterio MDS para regularizar el DeffFGV
    deff_FGV = ifelse(deff_FGV < 1, 1, deff_FGV),
    n_eff_FGV = nd / deff_FGV
  )

saveRDS(object = base_FH, "Recursos/Día2/Sesion1/Data/base_FH_2017.rds")
```



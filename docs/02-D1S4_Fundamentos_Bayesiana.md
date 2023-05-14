
# Día 1 - Sesión 3- Fundamentos de la inferencia Bayesiana en R y STAN




[El proyecto Manhattan y la estimación desagregada con encuestas de hogares ](https://github.com/psirusteam/2023CHLsae/blob/main/Recursos/Docs/Slides/slides_SAEbayesiano.pdf)

# Día 1 - Sesión 4- Modelos sintéticos simples 


## Regla de Bayes

En términos de inferencia para $\boldsymbol{\theta}$, es necesario encontrar la distribución de los parámetros condicionada a la observación de los datos. Para este fin, es necesario definir la distribución conjunta de la variable de interés con el vector de parámetros.

$$
p(\boldsymbol{\theta},\mathbf{Y})=p(\boldsymbol{\theta})p(\mathbf{Y} \mid \boldsymbol{\theta})
$$

-   La distribución $p(\boldsymbol{\theta})$ se le conoce con el nombre de distribución previa.

-   El término $p(\mathbf{Y} \mid \boldsymbol{\theta})$ es la distribución de muestreo, verosimilitud o distribución de los datos.

-   La distribución del vector de parámetros condicionada a los datos observados está dada por

    $$
    p(\boldsymbol{\theta} \mid \mathbf{Y})=\frac{p(\boldsymbol{\theta},\mathbf{Y})}{p(\mathbf{Y})}=\frac{p(\boldsymbol{\theta})p(\mathbf{Y} \mid \boldsymbol{\theta})}{p(\mathbf{Y})}
    $$

-   A la distribución $p(\boldsymbol{\theta} \mid \mathbf{Y})$ se le conoce con el nombre de distribución ***posterior***. Nótese que el denominador no depende del vector de parámetros y considerando a los datos observados como fijos, corresponde a una constante y puede ser obviada. Por lo tanto, otra representación de la regla de Bayes está dada por

    $$
    p(\boldsymbol{\theta} \mid \mathbf{Y})\propto p(\mathbf{Y} \mid \boldsymbol{\theta})p(\boldsymbol{\theta})
    $$

## Inferencia Bayesiana.

En términos de estimación, inferencia y predicción, el enfoque Bayesiano supone dos momentos o etapas:

1.  **Antes de la recolección de las datos**, en donde el investigador propone, basado en su conocimiento, experiencia o fuentes externas, una distribución de probabilidad previa para el parámetro de interés.
2.  **Después de la recolección de los datos.** Siguiendo el teorema de Bayes, el investigador actualiza su conocimiento acerca del comportamiento probabilístico del parámetro de interés mediante la distribución posterior de este.

## Modelos uniparamétricos

Los modelos que están definidos en términos de un solo parámetro que pertenece al conjunto de los números reales se definen como modelos *uniparamétricos*.

### Modelo de unidad: Bernoulli

Suponga que $Y$ es una variable aleatoria con distribución Bernoulli dada por:

$$
p(Y \mid \theta)=\theta^y(1-\theta)^{1-y}I_{\{0,1\}}(y)
$$

Como el parámetro $\theta$ está restringido al espacio $\Theta=[0,1]$, entonces es posible formular varias opciones para la distribución previa del parámetro. En particular, la distribución uniforme restringida al intervalo $[0,1]$ o la distribución Beta parecen ser buenas opciones. Puesto que la distribución uniforme es un caso particular de la distribución Beta. Por lo tanto la distribución previa del parámetro $\theta$ estará dada por

$$
\begin{equation}
p(\theta \mid \alpha,\beta)=
\frac{1}{Beta(\alpha,\beta)}\theta^{\alpha-1}(1-\theta)^{\beta-1}I_{[0,1]}(\theta).
\end{equation}
$$

y la distribución posterior del parámetro $\theta$ sigue una distribución

$$
\begin{equation*}
\theta \mid Y \sim Beta(y+\alpha,\beta-y+1)
\end{equation*}
$$

Cuando se tiene una muestra aleatoria $Y_1,\ldots,Y_n$ de variables con distribución Bernoulli de parámetro $\theta$, entonces la distribución posterior del parámetro de interés es

$$
\begin{equation*}
\theta \mid Y_1,\ldots,Y_n \sim Beta\left(\sum_{i=1}^ny_i+\alpha,\beta-\sum_{i=1}^ny_i+n\right)
\end{equation*}
$$

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

#### Práctica en **R**



```r
library(tidyverse)
encuesta <- readRDS("Recursos/Día1/Sesion4/Data/encuesta2017CHL.Rds") 
```

Sea $Y$ la variable aleatoria

$$
Y_{i}=\begin{cases}
1 & ingreso<lp\\
0 & ingreso\geq lp
\end{cases}
$$



El tamaño de la muestra es de 26434 Indígena


```r
datay <- encuesta %>% filter(etnia_ee == 1) %>% 
  transmute(y = ifelse(ingcorte < lp, 1,0))
addmargins(table(datay$y)) %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Var1 </th>
   <th style="text-align:right;"> Freq </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 0 </td>
   <td style="text-align:right;"> 22448 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:right;"> 3986 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sum </td>
   <td style="text-align:right;"> 26434 </td>
  </tr>
</tbody>
</table>



Un grupo de estadístico experto decide utilizar una distribución previa Beta, definiendo los parámetros de la distribución previa como $Beta(\alpha=1, \beta=1)$. La distribución posterior del parámetro de interés, que representa la probabilidad de estar por debajo de la linea de pobreza, es $Beta(3986 + 1, 1 - 3986 + 26434)=Beta(3987, 2.2449\times 10^{4})$



<div class="figure" style="text-align: center">
<img src="Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli1.png" alt="Distribución previa (línea roja) y distribución posterior (línea negra)" width="500px" height="250px" />
<p class="caption">(\#fig:unnamed-chunk-5)Distribución previa (línea roja) y distribución posterior (línea negra)</p>
</div>

La estimación del parámetro estaría dado por:

$$
E(X) = \frac{\alpha}{\alpha + \beta} = \frac{3987}{3987+ 2.2449\times 10^{4}} = 0.1508171
$$

luego, el intervalo de credibilidad para la distribución posterior es.


```r
n = length(datay$y)
n1 = sum(datay$y)
qbeta(c(0.025, 0.975),
      shape1 = 1 + n1,
      shape2 = 1 - n1 + n)
```

```
## [1] 0.1465283 0.1551559
```

#### Práctica en **STAN**

En `STAN` es posible obtener el mismo tipo de inferencia creando cuatro cadenas cuya distribución de probabilidad coincide con la distribución posterior del ejemplo.


```r
data {                         // Entrada el modelo 
  int<lower=0> n;              // Numero de observaciones  
  int y[n];                    // Vector de longitud n
  real a;
  real b;
}
parameters {                   // Definir parámetro
  real<lower=0, upper=1> theta;
}
model {                        // Definir modelo
  y ~ bernoulli(theta);
  theta ~ beta(a, b);      // Distribución previa 
}
generated quantities {
    real ypred[n];                    // vector de longitud n
    for (ii in 1:n){
    ypred[ii] = bernoulli_rng(theta);
    }
}
```

Para compilar *STAN* debemos definir los parámetros de entrada


```r
    sample_data <- list(n = nrow(datay),
                        y = datay$y,
                        a = 1,
                        b = 1)
```

Para ejecutar `STAN` en R tenemos la librería *rstan*


```r
library(rstan)
Bernoulli <- "Recursos/Día1/Sesion4/Data/modelosStan/1Bernoulli.stan"
```


```r
options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE) # speed up running time 
model_Bernoulli <- stan(
  file = Bernoulli,  # Stan program
  data = sample_data,    # named list of data
  verbose = FALSE,
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4,              # number of cores (could use one per chain)
)

saveRDS(model_Bernoulli,
        file = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/model_Bernoulli.rds")

model_Bernoulli <- readRDS("Recursos/Día1/Sesion4/0Recursos/Bernoulli/model_Bernoulli.rds")
```

La estimación del parámetro $\theta$ es:


```r
tabla_Ber1 <- summary(model_Bernoulli, pars = "theta")$summary
tabla_Ber1 %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> se_mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> 2.5% </th>
   <th style="text-align:right;"> 25% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 75% </th>
   <th style="text-align:right;"> 97.5% </th>
   <th style="text-align:right;"> n_eff </th>
   <th style="text-align:right;"> Rhat </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> theta </td>
   <td style="text-align:right;"> 0.1508 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0022 </td>
   <td style="text-align:right;"> 0.1466 </td>
   <td style="text-align:right;"> 0.1493 </td>
   <td style="text-align:right;"> 0.1508 </td>
   <td style="text-align:right;"> 0.1522 </td>
   <td style="text-align:right;"> 0.1552 </td>
   <td style="text-align:right;"> 716.553 </td>
   <td style="text-align:right;"> 1.0039 </td>
  </tr>
</tbody>
</table>

Para observar las cadenas compilamos las lineas de código


```r
library(posterior) 
library(ggplot2)
temp <- as_draws_df(as.array(model_Bernoulli,pars = "theta"))

p1 <- ggplot(data = temp, aes(x = theta))+ 
  geom_density(color = "blue", size = 2) +
  stat_function(fun = posterior1,
                args = list(y = datay$y),
                size = 2) + 
  theme_bw(base_size = 20) + 
  labs(x = latex2exp::TeX("\\theta"),
       y = latex2exp::TeX("f(\\theta)"))
# ggsave(plot = p1, filename = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli2.png", scale = 2)
p1 
```

<div class="figure" style="text-align: center">
<img src="Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli2.png" alt="Resultado con STAN (línea azul) y posterior teórica (línea negra)" width="500px" height="250px" />
<p class="caption">(\#fig:unnamed-chunk-14)Resultado con STAN (línea azul) y posterior teórica (línea negra)</p>
</div>

Para validar las cadenas


```r
library(bayesplot)
library(patchwork)
posterior_theta <- as.array(model_Bernoulli, pars = "theta")
p1 <- (mcmc_dens_chains(posterior_theta) +
    mcmc_areas(posterior_theta) ) / 
traceplot(model_Bernoulli,pars = "theta", inc_warmup = TRUE) 

# ggsave(plot = p1, 
#        filename = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli3.png", scale = 2)
p1  
```


<img src="Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli3.png" width="200%" style="display: block; margin: auto;" />


Predicción de $Y$ en cada una de las iteraciones de las cadenas.


```r
y_pred_B <- as.array(model_Bernoulli, pars = "ypred") %>% 
  as_draws_matrix()

rowsrandom <- sample(nrow(y_pred_B), 100)
y_pred2 <- y_pred_B[rowsrandom, 1:n]
p1 <- ppc_dens_overlay(y = datay$y, y_pred2)
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli4.png", scale = 2)
p1 
```

<img src="Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli4.png" width="200%" style="display: block; margin: auto;" />

### Modelo de área: Binomial

Cuando se dispone de una muestra aleatoria de variables con distribución Bernoulli $Y_1,\ldots,Y_n$, la inferencia Bayesiana se puede llevar a cabo usando la distribución Binomial, puesto que es bien sabido que la suma de variables aleatorias Bernoulli

$$
\begin{equation*}
S=\sum_{i=1}^nY_i
\end{equation*}
$$

sigue una distribución Binomial. Es decir:

$$
\begin{equation}
p(S \mid \theta)=\binom{n}{s}\theta^s(1-\theta)^{n-s}I_{\{0,1,\ldots,n\}}(s),
\end{equation}
$$

Nótese que, cuando $n=1$ la distribución Binomial se convierte en una  distribución Bernoulli. Puesto que, el parámetro $\theta$ es una proporción la distribución natural que modela este tipo de parámetros es la distribución beta la cual se define como: 

$$
\begin{equation}
p(\theta \mid \alpha,\beta)=
\frac{1}{Beta(\alpha,\beta)}\theta^{\alpha-1}(1-\theta)^{\beta-1}I_{[0,1]}(\theta).
\end{equation}
$$

La distribución posterior del parámetro $\theta$ sigue una distribución

$$
\begin{equation*}
\theta \mid S \sim Beta(s+\alpha,\beta-s+n)
\end{equation*}
$$

Ahora, cuando se tiene una sucesión de variables aleatorias $S_1,\ldots,S_d, \ldots,S_D$ independientes y con distribución $Binomial(n_d,\theta_d)$ para $d=1,\ldots,D$. La distribución posterior del parámetro de interés $\theta_d$ es

$$
\begin{equation*}
\theta_d \mid s_d \sim Beta\left(s_d+\alpha,\ \beta+ n_d- s_d\right)
\end{equation*}
$$

#### Obejtivo {-}


Estimar la proporción de personas que están por debajo de la linea pobreza, es decir, 

$$P_{d}=\frac{\sum_{U}y_{di}}{N_{d}}$$.

Un estimador aproximadamente insesgado para $P_{d}$ basado en el diseño muestral es 
$$
\hat{P}^{DIR}_{d} = \frac{\sum_{s_{d}}w_{di}y_{di}}{\sum_{s_{d}}w_{di}}
$$

donde $w_{di}$ es el factor de expansión de $i-$ésimo individuo
en el $d-$ésimo dominio y $y_{di}$ toma los valores de uno o cero. 

Ahora, dada la naturaleza de $P_d$, es posible asumir que $P_{d}\mid\hat{P}^{DIR}_{d} \sim Beta(\alpha,\beta)$. Luego, el estimador bayesiano para $P_{d}$ esta dado por $\tilde{P}_{d}=E\left(P_{d}\mid\hat{P}^{DIR}_{d}\right)$
 y la varianza del estimador se obtiene como: 

$$
Var\left(\tilde{P}_{d}\right) =  Var\left(P_{d}\mid\hat{P}_{d}\right)=E_{\mathscr{M}}\left(Var_{\mathscr{P}}\left(P_{d}\mid\hat{P}_{d}\right)\right)+Var_{\mathscr{M}}\left(E_{\mathscr{P}}\left(P_{d}\mid\hat{P}_{d}\right)\right)
$$



#### Práctica en **STAN**

Sea $S_k$ el conteo de personas en condición de pobreza en el $k-ésimo$ departamento en la muestra.


```r
dataS <- encuesta %>% 
  transmute(
    dam = dam_ee,
    y = ifelse(ingcorte < lp, 1,0)
  ) %>% group_by(dam) %>% 
  summarise(nd = n(),   #Número de ensayos 
            Sd = sum(y) #Número de éxito 
            )
tba(dataS)
```


<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> dam </th>
   <th style="text-align:right;"> nd </th>
   <th style="text-align:right;"> Sd </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 10150 </td>
   <td style="text-align:right;"> 1024 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 8510 </td>
   <td style="text-align:right;"> 696 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 6961 </td>
   <td style="text-align:right;"> 787 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 9952 </td>
   <td style="text-align:right;"> 1634 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 19625 </td>
   <td style="text-align:right;"> 1794 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 15862 </td>
   <td style="text-align:right;"> 1734 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 15208 </td>
   <td style="text-align:right;"> 2063 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 21532 </td>
   <td style="text-align:right;"> 3090 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 15481 </td>
   <td style="text-align:right;"> 2754 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 12442 </td>
   <td style="text-align:right;"> 1551 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 5045 </td>
   <td style="text-align:right;"> 251 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 6637 </td>
   <td style="text-align:right;"> 249 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 42601 </td>
   <td style="text-align:right;"> 3327 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:right;"> 10175 </td>
   <td style="text-align:right;"> 1143 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 7888 </td>
   <td style="text-align:right;"> 831 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 16 </td>
   <td style="text-align:right;"> 8370 </td>
   <td style="text-align:right;"> 1289 </td>
  </tr>
</tbody>
</table>

Creando código de `STAN`


```r
data {
  int<lower=0> K;                 // Número de provincia  
  int<lower=0> n[K];              // Número de ensayos 
  int<lower=0> s[K];              // Número de éxitos
  real a;
  real b;
}
parameters {
  real<lower=0, upper=1> theta[K]; // theta_d|s_d
}
model {
  for(kk in 1:K) {
  s[kk] ~ binomial(n[kk], theta[kk]);
  }
  to_vector(theta) ~ beta(a, b);
}

generated quantities {
    real spred[K];                    // vector de longitud K
    for(kk in 1:K){
    spred[kk] = binomial_rng(n[kk],theta[kk]);
}
}
```

Preparando el código de `STAN`


```r
Binomial2 <- "Recursos/Día1/Sesion4/Data/modelosStan/3Binomial.stan"
```

Organizando datos para `STAN`


```r
sample_data <- list(K = nrow(dataS),
                    s = dataS$Sd,
                    n = dataS$nd,
                    a = 1,
                    b = 1)
```

Para ejecutar `STAN` en R tenemos la librería *rstan*


```r
options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE) # speed up running time 
model_Binomial2 <- stan(
  file = Binomial2,  # Stan program
  data = sample_data,    # named list of data
  verbose = FALSE,
  warmup = 500,          # number of warmup iterations per chain
  iter = 1000,            # total number of iterations per chain
  cores = 4,              # number of cores (could use one per chain)
)

saveRDS(model_Binomial2, "Recursos/Día1/Sesion4/0Recursos/Binomial/model_Binomial2.rds")
model_Binomial2 <- readRDS("Recursos/Día1/Sesion4/0Recursos/Binomial/model_Binomial2.rds")
```

La estimación del parámetro $\theta$ es:


```r
tabla_Bin1 <-summary(model_Binomial2, pars = "theta")$summary 
tabla_Bin1 %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> se_mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> 2.5% </th>
   <th style="text-align:right;"> 25% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 75% </th>
   <th style="text-align:right;"> 97.5% </th>
   <th style="text-align:right;"> n_eff </th>
   <th style="text-align:right;"> Rhat </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> theta[1] </td>
   <td style="text-align:right;"> 0.1009 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0031 </td>
   <td style="text-align:right;"> 0.0949 </td>
   <td style="text-align:right;"> 0.0989 </td>
   <td style="text-align:right;"> 0.1009 </td>
   <td style="text-align:right;"> 0.1029 </td>
   <td style="text-align:right;"> 0.1072 </td>
   <td style="text-align:right;"> 4681.139 </td>
   <td style="text-align:right;"> 0.9987 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[2] </td>
   <td style="text-align:right;"> 0.0819 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0029 </td>
   <td style="text-align:right;"> 0.0764 </td>
   <td style="text-align:right;"> 0.0800 </td>
   <td style="text-align:right;"> 0.0818 </td>
   <td style="text-align:right;"> 0.0838 </td>
   <td style="text-align:right;"> 0.0878 </td>
   <td style="text-align:right;"> 5441.234 </td>
   <td style="text-align:right;"> 0.9983 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[3] </td>
   <td style="text-align:right;"> 0.1131 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0038 </td>
   <td style="text-align:right;"> 0.1059 </td>
   <td style="text-align:right;"> 0.1105 </td>
   <td style="text-align:right;"> 0.1130 </td>
   <td style="text-align:right;"> 0.1157 </td>
   <td style="text-align:right;"> 0.1212 </td>
   <td style="text-align:right;"> 5921.113 </td>
   <td style="text-align:right;"> 0.9983 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[4] </td>
   <td style="text-align:right;"> 0.1641 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0036 </td>
   <td style="text-align:right;"> 0.1572 </td>
   <td style="text-align:right;"> 0.1615 </td>
   <td style="text-align:right;"> 0.1641 </td>
   <td style="text-align:right;"> 0.1666 </td>
   <td style="text-align:right;"> 0.1714 </td>
   <td style="text-align:right;"> 5313.573 </td>
   <td style="text-align:right;"> 0.9989 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[5] </td>
   <td style="text-align:right;"> 0.0915 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0022 </td>
   <td style="text-align:right;"> 0.0873 </td>
   <td style="text-align:right;"> 0.0901 </td>
   <td style="text-align:right;"> 0.0914 </td>
   <td style="text-align:right;"> 0.0929 </td>
   <td style="text-align:right;"> 0.0958 </td>
   <td style="text-align:right;"> 5352.055 </td>
   <td style="text-align:right;"> 0.9983 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[6] </td>
   <td style="text-align:right;"> 0.1094 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0025 </td>
   <td style="text-align:right;"> 0.1046 </td>
   <td style="text-align:right;"> 0.1077 </td>
   <td style="text-align:right;"> 0.1093 </td>
   <td style="text-align:right;"> 0.1110 </td>
   <td style="text-align:right;"> 0.1144 </td>
   <td style="text-align:right;"> 4510.355 </td>
   <td style="text-align:right;"> 0.9993 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[7] </td>
   <td style="text-align:right;"> 0.1357 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0028 </td>
   <td style="text-align:right;"> 0.1302 </td>
   <td style="text-align:right;"> 0.1337 </td>
   <td style="text-align:right;"> 0.1356 </td>
   <td style="text-align:right;"> 0.1377 </td>
   <td style="text-align:right;"> 0.1411 </td>
   <td style="text-align:right;"> 6121.042 </td>
   <td style="text-align:right;"> 0.9992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[8] </td>
   <td style="text-align:right;"> 0.1435 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0024 </td>
   <td style="text-align:right;"> 0.1388 </td>
   <td style="text-align:right;"> 0.1418 </td>
   <td style="text-align:right;"> 0.1436 </td>
   <td style="text-align:right;"> 0.1452 </td>
   <td style="text-align:right;"> 0.1483 </td>
   <td style="text-align:right;"> 6092.897 </td>
   <td style="text-align:right;"> 0.9988 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[9] </td>
   <td style="text-align:right;"> 0.1779 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0030 </td>
   <td style="text-align:right;"> 0.1722 </td>
   <td style="text-align:right;"> 0.1758 </td>
   <td style="text-align:right;"> 0.1779 </td>
   <td style="text-align:right;"> 0.1800 </td>
   <td style="text-align:right;"> 0.1840 </td>
   <td style="text-align:right;"> 6518.933 </td>
   <td style="text-align:right;"> 0.9988 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[10] </td>
   <td style="text-align:right;"> 0.1247 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0028 </td>
   <td style="text-align:right;"> 0.1191 </td>
   <td style="text-align:right;"> 0.1229 </td>
   <td style="text-align:right;"> 0.1247 </td>
   <td style="text-align:right;"> 0.1265 </td>
   <td style="text-align:right;"> 0.1304 </td>
   <td style="text-align:right;"> 6120.245 </td>
   <td style="text-align:right;"> 0.9992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[11] </td>
   <td style="text-align:right;"> 0.0499 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0031 </td>
   <td style="text-align:right;"> 0.0442 </td>
   <td style="text-align:right;"> 0.0478 </td>
   <td style="text-align:right;"> 0.0498 </td>
   <td style="text-align:right;"> 0.0519 </td>
   <td style="text-align:right;"> 0.0561 </td>
   <td style="text-align:right;"> 5876.615 </td>
   <td style="text-align:right;"> 0.9984 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[12] </td>
   <td style="text-align:right;"> 0.0377 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0022 </td>
   <td style="text-align:right;"> 0.0333 </td>
   <td style="text-align:right;"> 0.0361 </td>
   <td style="text-align:right;"> 0.0376 </td>
   <td style="text-align:right;"> 0.0391 </td>
   <td style="text-align:right;"> 0.0421 </td>
   <td style="text-align:right;"> 3952.893 </td>
   <td style="text-align:right;"> 0.9986 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[13] </td>
   <td style="text-align:right;"> 0.0781 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0013 </td>
   <td style="text-align:right;"> 0.0756 </td>
   <td style="text-align:right;"> 0.0772 </td>
   <td style="text-align:right;"> 0.0781 </td>
   <td style="text-align:right;"> 0.0790 </td>
   <td style="text-align:right;"> 0.0807 </td>
   <td style="text-align:right;"> 5087.305 </td>
   <td style="text-align:right;"> 0.9991 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[14] </td>
   <td style="text-align:right;"> 0.1124 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0033 </td>
   <td style="text-align:right;"> 0.1059 </td>
   <td style="text-align:right;"> 0.1101 </td>
   <td style="text-align:right;"> 0.1124 </td>
   <td style="text-align:right;"> 0.1146 </td>
   <td style="text-align:right;"> 0.1187 </td>
   <td style="text-align:right;"> 4325.590 </td>
   <td style="text-align:right;"> 0.9991 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[15] </td>
   <td style="text-align:right;"> 0.1055 </td>
   <td style="text-align:right;"> 0e+00 </td>
   <td style="text-align:right;"> 0.0034 </td>
   <td style="text-align:right;"> 0.0991 </td>
   <td style="text-align:right;"> 0.1031 </td>
   <td style="text-align:right;"> 0.1054 </td>
   <td style="text-align:right;"> 0.1078 </td>
   <td style="text-align:right;"> 0.1121 </td>
   <td style="text-align:right;"> 5474.135 </td>
   <td style="text-align:right;"> 0.9983 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[16] </td>
   <td style="text-align:right;"> 0.1541 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0038 </td>
   <td style="text-align:right;"> 0.1464 </td>
   <td style="text-align:right;"> 0.1516 </td>
   <td style="text-align:right;"> 0.1540 </td>
   <td style="text-align:right;"> 0.1565 </td>
   <td style="text-align:right;"> 0.1617 </td>
   <td style="text-align:right;"> 4927.834 </td>
   <td style="text-align:right;"> 0.9987 </td>
  </tr>
</tbody>
</table>


Para validar las cadenas


```r
p1 <- mcmc_areas(as.array(model_Binomial2, pars = "theta"))
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Binomial/Binomial1.png", scale = 2)
p1
```

<img src="Recursos/Día1/Sesion4/0Recursos/Binomial/Binomial1.png" width="200%" />


```r
p1 <- mcmc_trace(as.array(model_Binomial2, pars = "theta"))
# traceplot(model_Binomial2, pars = "theta",inc_warmup = TRUE)
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/Bernoulli2.png",
#        scale = 2)
p1
```


<img src="Recursos/Día1/Sesion4/0Recursos/Binomial/Binomial2.png" width="200%" />


```r
y_pred_B <- as.array(model_Binomial2, pars = "spred") %>% 
  as_draws_matrix()

rowsrandom <- sample(nrow(y_pred_B), 200)
y_pred2 <- y_pred_B[rowsrandom, ]
g1 <- ggplot(data = dataS, aes(x = Sd))+
  geom_histogram(aes(y = ..density..)) +
  geom_density(size = 2, color = "blue") +
  labs(y = "")+
  theme_bw(20) 
g2 <- ppc_dens_overlay(y = dataS$Sd, y_pred2) 
p1 <- g1/g2
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Bernoulli/Binomial3.png",
#        scale = 2)
p1
```


<img src="Recursos/Día1/Sesion4/0Recursos/Binomial/Binomial3.png" width="200%" />

### Modelo de unidad: Normal con media desconocida

Suponga que $Y_1,\cdots,Y_n$ son variables independientes e idénticamente distribuidos con distribución $Normal(\theta,\sigma^2)$ con $\theta$ desconocido pero $\sigma^2$ conocido. De esta forma, la función de verosimilitud de los datos está dada por

$$
\begin{align*}
p(\mathbf{Y} \mid \theta)
&=\prod_{i=1}^n\frac{1}{\sqrt{2\pi\sigma^2}}\exp\left\{-\frac{1}{2\sigma^2}(y_i-\theta)^2\right\}I_\mathbb{R}(y) \\
&=(2\pi\sigma^2)^{-n/2}\exp\left\{-\frac{1}{2\sigma^2}\sum_{i=1}^n(y_i-\theta)^2\right\}
\end{align*}
$$

Como el parámetro $\theta$ puede tomar cualquier valor en los reales, es posible asignarle una distribución previa $\theta \sim Normal(\mu,\tau^2)$. Bajo este marco de referencia se tienen los siguientes resultados

La distribución posterior del parámetro de interés $\theta$ sigue una distribución

$$
\begin{equation*}
\theta|\mathbf{Y} \sim Normal(\mu_n,\tau^2_n)
\end{equation*}
$$

En donde

$$
\begin{equation}
\mu_n=\frac{\frac{n}{\sigma^2}\bar{Y}+\frac{1}{\tau^2}\mu}{\frac{n}{\sigma^2}+\frac{1}{\tau^2}}
\ \ \ \ \ \ \ \text{y} \ \ \ \ \ \ \
\tau_n^2=\left(\frac{n}{\sigma^2}+\frac{1}{\tau^2}\right)^{-1}
\end{equation}
$$

#### Obejtivo {-}

Estimar el ingreso medio de las personas, es decir, 
$$
\bar{Y}_d = \frac{\sum_{U_d}y_{di}}{N_d}
$$
donde $y_{di}$ es el ingreso de cada personas

Note que, 

$$
\begin{equation*}
\bar{Y}_d =  \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}y_{di}}{N_d} 
\end{equation*}
$$

Ahora, el estimador de $\bar{Y}$ esta dado por: 

$$
\hat{\bar{Y}}_d = \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}\hat{y}_{di}}{N_d}
$$

donde

$$\hat{y}_{di}=E_{\mathscr{M}}\left(y_{di}\mid\boldsymbol{x}_{d},\boldsymbol{\beta}\right)$$,

donde $\mathscr{M}$ hace referencia a la medida de probabilidad inducida por el modelamiento. 
De esta forma se tiene que, 

$$
\hat{\bar{Y}}_d = \frac{\sum_{U_{d}}\hat{y}_{di}}{N_d}
$$

#### Práctica en **STAN**

Sea $Y$ el logaritmo del ingreso


```r
dataNormal <- encuesta %>%
   filter(dam_ee == 1, ingcorte>0) %>% 
    transmute(
     dam_ee ,
  logIngreso = log(ingcorte +1)) 
#3
media <- mean(dataNormal$logIngreso)
Sd <- sd(dataNormal$logIngreso)

g1 <- ggplot(dataNormal,aes(x = logIngreso))+ 
  geom_density(size =2, color = "blue") +
  stat_function(fun =dnorm, 
                args = list(mean = media, sd = Sd),
                size =2) +
  theme_bw(base_size = 20) + 
  labs(y = "", x = ("Log(Ingreso)"))

g2 <- ggplot(dataNormal, aes(sample = logIngreso)) +
     stat_qq() + stat_qq_line() +
  theme_bw(base_size = 20) 
p1 <- g1|g2
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Normal/Normal1.png",
#        scale = 2)
p1
```


<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal1.png" width="200%" />

Creando código de `STAN`


```r
data {
  int<lower=0> n;     // Número de observaciones
  real y[n];          // LogIngreso 
  real <lower=0> Sigma;  // Desviación estándar   
}
parameters {
  real theta;
}
model {
  y ~ normal(theta, Sigma);
  theta ~ normal(0, 1000); // Distribución previa
}
generated quantities {
    real ypred[n];                    // Vector de longitud n
    for(kk in 1:n){
    ypred[kk] = normal_rng(theta,Sigma);
}
}
```

Preparando el código de `STAN`


```r
NormalMedia <- "Recursos/Día1/Sesion4/Data/modelosStan/4NormalMedia.stan" 
```

Organizando datos para `STAN`


```r
sample_data <- list(n = nrow(dataNormal),
                    Sigma = sd(dataNormal$logIngreso),
                    y = dataNormal$logIngreso)
```

Para ejecutar `STAN` en R tenemos la librería *rstan*


```r
options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE) # speed up running time 
model_NormalMedia <- stan(
  file = NormalMedia,  
  data = sample_data,   
  verbose = FALSE,
  warmup = 500,         
  iter = 1000,            
  cores = 4              
)
saveRDS(model_NormalMedia, "Recursos/Día1/Sesion4/0Recursos/Normal/model_NormalMedia.rds")
model_NormalMedia <- 
  readRDS("Recursos/Día1/Sesion4/0Recursos/Normal/model_NormalMedia.rds")
```

La estimación del parámetro $\theta$ es:


```r
tabla_Nor1 <- summary(model_NormalMedia, pars = "theta")$summary
tabla_Nor1 %>% tba()  
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> se_mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> 2.5% </th>
   <th style="text-align:right;"> 25% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 75% </th>
   <th style="text-align:right;"> 97.5% </th>
   <th style="text-align:right;"> n_eff </th>
   <th style="text-align:right;"> Rhat </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> theta </td>
   <td style="text-align:right;"> 12.456 </td>
   <td style="text-align:right;"> 3e-04 </td>
   <td style="text-align:right;"> 0.0071 </td>
   <td style="text-align:right;"> 12.4415 </td>
   <td style="text-align:right;"> 12.4515 </td>
   <td style="text-align:right;"> 12.456 </td>
   <td style="text-align:right;"> 12.4608 </td>
   <td style="text-align:right;"> 12.4704 </td>
   <td style="text-align:right;"> 773.9375 </td>
   <td style="text-align:right;"> 1.0024 </td>
  </tr>
</tbody>
</table>



```r
posterior_theta <- as.array(model_NormalMedia, pars = "theta")
p1 <- (mcmc_dens_chains(posterior_theta) +
    mcmc_areas(posterior_theta) ) / 
  mcmc_trace(posterior_theta)
# ggsave(plot = p1,
#        filename ="Recursos/Día1/Sesion4/0Recursos/Normal/Normal2.png",
#        scale = 2)

p1
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal2.png" width="200%" />



```r
y_pred_B <- as.array(model_NormalMedia, pars = "ypred") %>% 
  as_draws_matrix()

rowsrandom <- sample(nrow(y_pred_B), 100)
y_pred2 <- y_pred_B[rowsrandom, ]
ppc_dens_overlay(y = as.numeric(dataNormal$logIngreso), y_pred2)/
ppc_dens_overlay(y = exp(as.numeric(dataNormal$logIngreso))-1, exp(y_pred2)-1) + xlim(0,2000000)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal3.png" width="200%" />


## Modelos multiparamétricos

-   La distribución normal univariada que tiene dos parámetros: la media $\theta$ y la varianza $\sigma^2$.
-   La distribución multinomial cuyo parámetro es un vector de probabilidades $\boldsymbol{\theta}$.

### Modelo de unidad: Normal con media y varianza desconocida

Supongamos que se dispone de realizaciones de un conjunto de variables independientes e idénticamente distribuidas $Y_1,\cdots,Y_n\sim N(\theta,\sigma^2)$. Cuando se desconoce tanto la media como la varianza de la distribución es necesario plantear diversos enfoques y situarse en el más conveniente, según el contexto del problema. En términos de la asignación de las distribuciones previas para $\theta$ y $\sigma^2$ es posible:

-   Suponer que la distribución previa $p(\theta)$ es independiente de la distribución previa $p(\sigma^2)$ y que ambas distribuciones son informativas.
-   Suponer que la distribución previa $p(\theta)$ es independiente de la distribución previa $p(\sigma^2)$ y que ambas distribuciones son no informativas.
-   Suponer que la distribución previa para $\theta$ depende de $\sigma^2$ y escribirla como $p(\theta \mid \sigma^2)$, mientras que la distribución previa de $\sigma^2$ no depende de $\theta$ y se puede escribir como $p(\sigma^2)$.


La distribución previa para el parámetro $\theta$ será

$$
\begin{equation*}
\theta \sim Normal(0,10000)
\end{equation*}
$$

Y la distribución previa para el parámetro $\sigma^2$ será

$$
\begin{equation*}
\sigma^2 \sim IG(0.0001,0.0001)
\end{equation*}
$$

La distribución posterior condicional de $\theta$ es

$$
\begin{equation}
\theta  \mid  \sigma^2,\mathbf{Y} \sim Normal(\mu_n,\tau_n^2)
\end{equation}
$$

En donde las expresiones para $\mu_n$ y $\tau_n^2$ están dados previamente. 

En el siguiente enlace enconará el libro:  [Modelos Bayesianos con R y STAN](https://psirusteam.github.io/bookdownBayesiano/) donde puede profundizar en el desarrollo matemático de los resultados anteriores. 

#### Obejtivo {-}

Estimar el ingreso medio de las personas, es decir, 
$$
\bar{Y}_d = \frac{\sum_{U_d}y_{di}}{N_d}
$$
donde $y_{di}$ es el ingreso de cada personas

Note que, 

$$
\begin{equation*}
\bar{Y}_d =  \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}y_{di}}{N_d} 
\end{equation*}
$$

Ahora, el estimador de $\bar{Y}$ esta dado por: 

$$
\hat{\bar{Y}}_d = \frac{\sum_{s_d}y_{di} + \sum_{s^c_d}\hat{y}_{di}}{N_d}
$$

donde

$$\hat{y}_{di}=E_{\mathscr{M}}\left(y_{di}\mid\boldsymbol{x}_{d},\boldsymbol{\beta}\right)$$,

donde $\mathscr{M}$ hace referencia a la medida de probabilidad inducida por el modelamiento. 
De esta forma se tiene que, 

$$
\hat{\bar{Y}}_d = \frac{\sum_{U_{d}}\hat{y}_{di}}{N_d}
$$


#### Práctica en **STAN**

Sea $Y$ el logaritmo del ingreso


```r
dataNormal <- encuesta %>%
  filter(dam_ee == 1, ingcorte>0) %>% 
    transmute(dam_ee,
      logIngreso = log(ingcorte +1)) 
```


Creando código de `STAN`


```r
data {
  int<lower=0> n;
  real y[n];
}
parameters {
  real sigma;
  real theta;
}
transformed parameters {
  real sigma2;
  sigma2 = pow(sigma, 2);
}
model {
  y ~ normal(theta, sigma);
  theta ~ normal(0, 1000);
  sigma2 ~ inv_gamma(0.001, 0.001);
}
generated quantities {
    real ypred[n];                    // vector de longitud n
    for(kk in 1:n){
    ypred[kk] = normal_rng(theta,sigma);
}
}
```

Preparando el código de `STAN`


```r
NormalMeanVar  <- "Recursos/Día1/Sesion4/Data/modelosStan/5NormalMeanVar.stan" 
```

Organizando datos para `STAN`


```r
sample_data <- list(n = nrow(dataNormal),
                    y = dataNormal$logIngreso)
```

Para ejecutar `STAN` en R tenemos la librería *rstan*


```r
options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE) # speed up running time 

model_NormalMedia <- stan(
  file = NormalMeanVar,  
  data = sample_data,   
  verbose = FALSE,
  warmup = 500,         
  iter = 1000,            
  cores = 4              
)

saveRDS(model_NormalMedia,"Recursos/Día1/Sesion4/0Recursos/Normal/model_NormalMedia2.rds")
model_NormalMedia <- 
  readRDS("Recursos/Día1/Sesion4/0Recursos/Normal/model_NormalMedia2.rds")
```

La estimación del parámetro $\theta$ y $\sigma^2$ es:


```r
tabla_Nor2 <- summary(model_NormalMedia, 
        pars = c("theta", "sigma2", "sigma"))$summary

tabla_Nor2 %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> se_mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> 2.5% </th>
   <th style="text-align:right;"> 25% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 75% </th>
   <th style="text-align:right;"> 97.5% </th>
   <th style="text-align:right;"> n_eff </th>
   <th style="text-align:right;"> Rhat </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> theta </td>
   <td style="text-align:right;"> 12.4558 </td>
   <td style="text-align:right;"> 2e-04 </td>
   <td style="text-align:right;"> 0.0074 </td>
   <td style="text-align:right;"> 12.4417 </td>
   <td style="text-align:right;"> 12.4507 </td>
   <td style="text-align:right;"> 12.4558 </td>
   <td style="text-align:right;"> 12.4607 </td>
   <td style="text-align:right;"> 12.4708 </td>
   <td style="text-align:right;"> 1634.562 </td>
   <td style="text-align:right;"> 1.0003 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sigma2 </td>
   <td style="text-align:right;"> 0.5069 </td>
   <td style="text-align:right;"> 2e-04 </td>
   <td style="text-align:right;"> 0.0070 </td>
   <td style="text-align:right;"> 0.4932 </td>
   <td style="text-align:right;"> 0.5021 </td>
   <td style="text-align:right;"> 0.5068 </td>
   <td style="text-align:right;"> 0.5117 </td>
   <td style="text-align:right;"> 0.5209 </td>
   <td style="text-align:right;"> 1828.967 </td>
   <td style="text-align:right;"> 0.9995 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sigma </td>
   <td style="text-align:right;"> 0.7119 </td>
   <td style="text-align:right;"> 1e-04 </td>
   <td style="text-align:right;"> 0.0049 </td>
   <td style="text-align:right;"> 0.7023 </td>
   <td style="text-align:right;"> 0.7086 </td>
   <td style="text-align:right;"> 0.7119 </td>
   <td style="text-align:right;"> 0.7153 </td>
   <td style="text-align:right;"> 0.7218 </td>
   <td style="text-align:right;"> 1831.561 </td>
   <td style="text-align:right;"> 0.9995 </td>
  </tr>
</tbody>
</table>



```r
posterior_theta <- as.array(model_NormalMedia, pars = "theta")
p1 <- (mcmc_dens_chains(posterior_theta) +
    mcmc_areas(posterior_theta) ) / 
  mcmc_trace(posterior_theta)
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Normal/Normal4.png",
#        scale = 2)
p1 
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal4.png" width="200%" />



```r
posterior_sigma2 <- as.array(model_NormalMedia, pars = "sigma2")
p1 <- (mcmc_dens_chains(posterior_sigma2) +
    mcmc_areas(posterior_sigma2) ) / 
  mcmc_trace(posterior_sigma2)
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Normal/Normal5.png",
#        scale = 2)
p1
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal5.png" width="200%" />



```r
posterior_sigma <- as.array(model_NormalMedia, pars = "sigma")
p1 <- (mcmc_dens_chains(posterior_sigma) +
    mcmc_areas(posterior_sigma) ) / 
  mcmc_trace(posterior_sigma)
# ggsave(plot = p1,
#        filename = "Recursos/Día1/Sesion4/0Recursos/Normal/Normal6.png",
#        scale = 2)
p1
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal6.png" width="200%" />



```r
y_pred_B <- as.array(model_NormalMedia, pars = "ypred") %>% 
  as_draws_matrix()
rowsrandom <- sample(nrow(y_pred_B), 100)
y_pred2 <- y_pred_B[rowsrandom, ]
ppc_dens_overlay(y = as.numeric(exp(dataNormal$logIngreso)-1), y_pred2) +   xlim(0,2000000)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Normal/Normal7.png" width="200%" />


### Modelo de área:  Multinomial

En esta sección discutimos el modelamiento bayesiano de datos provenientes de una distribución multinomial que corresponde a una extensión multivariada de la distribución binomial. Suponga que $\textbf{Y}=(Y_1,\ldots,Y_K)^{T}$ es un vector aleatorio con distribución multinomial, así, su distribución está parametrizada por el vector $\boldsymbol{\theta}=(\theta_1,\ldots,\theta_K)^{T}$ y está dada por la siguiente expresión

$$
\begin{equation}
p(\mathbf{Y} \mid \boldsymbol{\theta})=\binom{n}{y_1,\ldots,y_K}\prod_{k=1}^K\theta_k^{y_k} \ \ \ \ \ \theta_k>0 \texttt{ , }  \sum_{k=1}^{K}y_k=n \texttt{ y } \sum_{k=1}^K\theta_k=1
\end{equation}
$$ Donde

$$
\begin{equation*}
\binom{n}{y_1,\ldots,y_K}=\frac{n!}{y_1!\cdots y_K!}.
\end{equation*}
$$

Como cada parámetro $\theta_k$ está restringido al espacio $\Theta=[0,1]$, entonces es posible asignar a la distribución de Dirichlet como la distribución previa del vector de parámetros. Por lo tanto la distribución previa del vector de parámetros $\boldsymbol{\theta}$, parametrizada por el vector de hiperparámetros $\boldsymbol{\alpha}=(\alpha_1,\ldots,\alpha_K)^{T}$, está dada por

$$
\begin{equation}
p(\boldsymbol{\theta} \mid \boldsymbol{\alpha})=\frac{\Gamma(\alpha_1+\cdots+\alpha_K)}{\Gamma(\alpha_1)\cdots\Gamma(\alpha_K)}
  \prod_{k=1}^K\theta_k^{\alpha_k-1} \ \ \ \ \ \alpha_k>0 \texttt{ y } \sum_{k=1}^K\theta_k=1
\end{equation}
$$

La distribución posterior del parámetro $\boldsymbol{\theta}$ sigue una distribución $Dirichlet(y_1+\alpha_1,\ldots,y_K+\alpha_K)$


#### Práctica en **STAN**

Sea $Y$ condición de actividad laboral


```r
dataMult <- encuesta %>% filter(condact3 %in% 1:3) %>% 
  transmute(
   empleo = as_factor(condact3)) %>% 
  group_by(empleo) %>%  tally() %>% 
  mutate(theta = n/sum(n))
tba(dataMult)
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> empleo </th>
   <th style="text-align:right;"> n </th>
   <th style="text-align:right;"> theta </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Ocupado </td>
   <td style="text-align:right;"> 92417 </td>
   <td style="text-align:right;"> 0.5291 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Desocupado </td>
   <td style="text-align:right;"> 8671 </td>
   <td style="text-align:right;"> 0.0496 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Inactivo </td>
   <td style="text-align:right;"> 73567 </td>
   <td style="text-align:right;"> 0.4212 </td>
  </tr>
</tbody>
</table>

donde  *1*  corresponde a **Ocupado**, *2* son los **Desocupado** y *3* son **Inactivo**

Creando código de `STAN`


```r
data {
  int<lower=0> k;  // Número de cátegoria 
  int y[k];        // Número de exitos 
  vector[k] alpha; // Parámetro de las distribción previa 
}
parameters {
  simplex[k] theta;
}
transformed parameters {
  real delta;                              // Tasa de desocupación
  delta = theta[2]/ (theta[2] + theta[1]); // (Desocupado)/(Desocupado + Ocupado)
}
model {
  y ~ multinomial(theta);
  theta ~ dirichlet(alpha);
}
generated quantities {
  int ypred[k];
  ypred = multinomial_rng(theta, sum(y));
}
```

Preparando el código de `STAN`


```r
Multinom  <- "Recursos/Día1/Sesion4/Data/modelosStan/6Multinom.stan" 
```

Organizando datos para `STAN`


```r
sample_data <- list(k = nrow(dataMult),
                    y = dataMult$n,
                    alpha = c(0.5, 0.5, 0.5))
```

Para ejecutar `STAN` en R tenemos la librería *rstan*


```r
options(mc.cores = parallel::detectCores())
rstan::rstan_options(auto_write = TRUE) # speed up running time 
model_Multinom <- stan(
  file = Multinom,  
  data = sample_data,   
  verbose = FALSE,
  warmup = 500,         
  iter = 1000,            
  cores = 4              
)
saveRDS(model_Multinom, "Recursos/Día1/Sesion4/0Recursos/Multinomial/model_Multinom.rds")
model_Multinom <- readRDS("Recursos/Día1/Sesion4/0Recursos/Multinomial/model_Multinom.rds")
```


La estimación del parámetro $\theta$ y $\delta$ es:


```r
tabla_Mul1 <- summary(model_Multinom, pars = c("delta", "theta"))$summary 
tabla_Mul1 %>% tba()
```

<table class="table table-striped lightable-classic" style="width: auto !important; margin-left: auto; margin-right: auto; font-family: Arial Narrow; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> se_mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> 2.5% </th>
   <th style="text-align:right;"> 25% </th>
   <th style="text-align:right;"> 50% </th>
   <th style="text-align:right;"> 75% </th>
   <th style="text-align:right;"> 97.5% </th>
   <th style="text-align:right;"> n_eff </th>
   <th style="text-align:right;"> Rhat </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> delta </td>
   <td style="text-align:right;"> 0.0858 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0009 </td>
   <td style="text-align:right;"> 0.0841 </td>
   <td style="text-align:right;"> 0.0852 </td>
   <td style="text-align:right;"> 0.0858 </td>
   <td style="text-align:right;"> 0.0864 </td>
   <td style="text-align:right;"> 0.0876 </td>
   <td style="text-align:right;"> 1158.205 </td>
   <td style="text-align:right;"> 1.0020 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[1] </td>
   <td style="text-align:right;"> 0.5291 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0012 </td>
   <td style="text-align:right;"> 0.5268 </td>
   <td style="text-align:right;"> 0.5283 </td>
   <td style="text-align:right;"> 0.5291 </td>
   <td style="text-align:right;"> 0.5299 </td>
   <td style="text-align:right;"> 0.5315 </td>
   <td style="text-align:right;"> 1834.800 </td>
   <td style="text-align:right;"> 0.9987 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[2] </td>
   <td style="text-align:right;"> 0.0497 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0005 </td>
   <td style="text-align:right;"> 0.0487 </td>
   <td style="text-align:right;"> 0.0493 </td>
   <td style="text-align:right;"> 0.0497 </td>
   <td style="text-align:right;"> 0.0500 </td>
   <td style="text-align:right;"> 0.0507 </td>
   <td style="text-align:right;"> 1090.703 </td>
   <td style="text-align:right;"> 1.0026 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> theta[3] </td>
   <td style="text-align:right;"> 0.4212 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0012 </td>
   <td style="text-align:right;"> 0.4188 </td>
   <td style="text-align:right;"> 0.4204 </td>
   <td style="text-align:right;"> 0.4212 </td>
   <td style="text-align:right;"> 0.4221 </td>
   <td style="text-align:right;"> 0.4236 </td>
   <td style="text-align:right;"> 1695.183 </td>
   <td style="text-align:right;"> 0.9999 </td>
  </tr>
</tbody>
</table>
        


```r
posterior_theta1 <- as.array(model_Multinom, pars = "theta[1]")
(mcmc_dens_chains(posterior_theta1) +
    mcmc_areas(posterior_theta1) ) / 
  mcmc_trace(posterior_theta1)
```


<img src="Recursos/Día1/Sesion4/0Recursos/Multinomial/Multinomial1.png" width="200%" />


```r
posterior_theta2 <- as.array(model_Multinom, pars = "theta[2]")
(mcmc_dens_chains(posterior_theta2) +
    mcmc_areas(posterior_theta2) ) / 
  mcmc_trace(posterior_theta2)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Multinomial/Multinomial2.png" width="200%" />



```r
posterior_theta3 <- as.array(model_Multinom, pars = "theta[3]")
(mcmc_dens_chains(posterior_theta3) +
    mcmc_areas(posterior_theta3) ) / 
  mcmc_trace(posterior_theta3)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Multinomial/Multinomial3.png" width="200%" />


```r
posterior_delta <- as.array(model_Multinom, pars = "delta")
(mcmc_dens_chains(posterior_delta) +
    mcmc_areas(posterior_delta) ) / 
  mcmc_trace(posterior_delta)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Multinomial/Multinomial4.png" width="200%" />

La imagen es muy pesada no se carga al repositorio. 


```r
n <- nrow(dataMult)
y_pred_B <- as.array(model_Multinom, pars = "ypred") %>% 
  as_draws_matrix()

rowsrandom <- sample(nrow(y_pred_B), 50)
y_pred2 <- y_pred_B[, 1:n]
ppc_dens_overlay(y = as.numeric(dataMult$n), y_pred2)
```

<img src="Recursos/Día1/Sesion4/0Recursos/Multinomial/ppc_multinomial.PNG" width="200%" style="display: block; margin: auto;" />

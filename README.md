# 📊 Inferencia Bayesiana — Modelo Rasch Poisson de Conteo (RPC)

Estimación de parámetros del **Modelo Rasch Poisson de Conteo (RPC)** mediante inferencia bayesiana con MCMC, comparada con inferencia clásica por máxima verosimilitud. Aplicado a datos de una prueba de atención aplicada a 228 estudiantes.

## 📌 Contexto

El modelo RPC, propuesto por George Rasch (1960), pertenece a la **Teoría de Respuesta al Ítem (TRI)** y relaciona los aciertos de una prueba con la habilidad de cada persona y la dificultad de cada ítem, mediante una distribución de Poisson:

$$Y_{ij} | \theta_i, \beta_j \sim \text{Poisson}(\theta_i - \beta_j + t_j)$$

Donde:
- $\theta_i$ = habilidad de la persona $i$
- $\beta_j$ = dificultad del ítem $j$
- $t_j$ = tiempo límite del ítem $j$ (valor conocido)

## 📊 Datos

| Atributo | Detalle |
|----------|---------|
| Fuente | Baghaei & Doebler (2019) |
| Tarea | Tachar los números 2 y 7 en tres líneas de dígitos y letras |
| Personas | 228 estudiantes |
| Ítems | 20 |
| Referencia | *Psychological Reports*, 122(5), 1967–1994 |

## ⚙️ Métodos

### Inferencia Bayesiana (MCMC)

**Selección de distribución a priori** — comparación de 3 modelos:

| Modelo | $\theta_i$ (habilidad) | $\beta_j$ (dificultad) | DIC | AIC |
|--------|------------------------|------------------------|-----|-----|
| N°1 | Normal(0, 1) | Uniforme(−3, 3) | 24.656,65 | 24.905,27 |
| **N°2** ✓ | **LogNormal(0, 1)** | **Uniforme(−3, 3)** | **24.643,90** | **24.901,56** |
| N°3 | LogNormal(0, 1) | Uniforme(−5, 5) | 24.644,46 | 24.901,68 |

> Se seleccionó el **Modelo N°2** por presentar los menores valores de DIC y AIC.

**Configuración MCMC:**
- 3 cadenas independientes
- 200.000 iteraciones por cadena
- Burn-in: 150.000 iteraciones
- Thinning: 10

**Diagnóstico de convergencia:**

| Test | Resultado |
|------|-----------|
| Geweke | Todos los estadísticos z dentro del rango [−2,5; 2,5] ✓ |
| Gelman-Rubin | R-hat < 1,1 para todos los parámetros ✓ |
| Heidelberger-Welch | p-valor > 0,05 para todos los parámetros ✓ |

### Inferencia Clásica (máxima verosimilitud)

Modelo de efectos mixtos lineales generalizados (GLMM) con distribución Poisson, usando librería `lme4`.

## 📈 Resultados

### Estimaciones a posteriori (Modelo N°2)

| Parámetro | Moda a posteriori | Error estándar (EMC) |
|-----------|-------------------|----------------------|
| $\theta_1$ (habilidad persona 1) | 0,4988 | 0,001278 |
| $\beta_1$ (dificultad ítem 1) | −2,2200 | 0,000378 |

### Comparación bayesiana vs. clásica

| Indicador | Bayesiana | Clásica |
|-----------|-----------|---------|
| AIC | **24.901,56** | 24.945,90 |
| BIC | 26.494,98 | **25.080,90** |
| Tiempo de estimación | 7.945,63 seg. | 15,45 seg. |

- **AIC** favorece la estimación bayesiana (mejor ajuste)
- **BIC** favorece la estimación clásica (menor complejidad)
- Ambos métodos identifican consistentemente a la **persona 140** como la de mayor habilidad y a la **persona 141** como la de menor habilidad

> **Conclusión:** La inferencia bayesiana incorpora conocimiento previo y caracteriza la incertidumbre mediante intervalos de máxima densidad posterior (HDP), ofreciendo estimaciones más ricas a costa de mayor tiempo computacional.

## 🛠 Herramientas

`R` · `JAGS` · `rjags` · `R2jags` · `coda` · `lme4` · `tictoc` · `tidyverse`

## 📁 Contenido del repositorio

```
├── script_bayesiano.R          # Estimación MCMC con JAGS
├── script_clasico.R            # Estimación clásica con lme4
├── informe_final.pdf           # Informe completo con resultados
└── README.md
```

## 📚 Referencias

- Baghaei, P. & Doebler, P. (2019). Introduction to the Rasch Poisson Counts Model. *Psychological Reports*, 122(5), 1967–1994.
- Bazán, J. L., Valdivieso, L. H. & Calderón, A. (2010). Enfoque Bayesiano en modelos de TRI.
- Van Buuren, S. (2018). *Flexible Imputation of Missing Data*.

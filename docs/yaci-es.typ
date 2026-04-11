// Importación de módulos desde el registro central
#import "@preview/ilm:2.0.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

// Instanciación de la macroestructura del documento
#show: ilm.with(
  title: [Manual de Referencia: Lenguaje X],
  author: "Comité de Estandarización",
  date: datetime(year: 2026, month: 4, day: 11),
  abstract: [
    Este documento define la especificación sintáctica, léxica y semántica del Lenguaje X, detallando sus rutinas de compilación y las interfaces de su biblioteca estándar.
  ],
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

// Inicialización de la infraestructura léxica para el código fuente
#show: codly-init
#codly(
  languages: codly-languages,
  number-format: none,
  zebra-fill: luma(240),
)

// Inicio del contenido documental
= Introducción a la Sintaxis

El diseño del analizador léxico prioriza la no ambigüedad gramatical y la legibilidad humana. Las estructuras de control de flujo derivan de los paradigmas imperativos consolidados.

== Control de Flujo: Bucle Iterativo

El siguiente segmento demuestra la implementación algorítmica de un bucle iterativo de recuento acotado, ejecutado sobre una asignación de variables tipadas.

```rust
fn main() {
    let mut acumulador: i32 = 0;
    let limite = 10;
    
    // Ejecución de bucle iterativo
    for i in 0..limite {
        acumulador += i;
        println!("El estado del acumulador es: {}", acumulador);
    }
}
```

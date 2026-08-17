# arith

Plantilla para describir circuitos combinacionales en Verilog usando
**oss-cad-suite** (iverilog, vvp, yosys, gtkwave).

## Estructura

```
rtl/        modulos Verilog (el diseño)
tb/         testbenches (uno por modulo, sufijo _tb.v)
build/      salidas generadas (se borra con "make clean")
  waves/    archivos .vcd para ver en gtkwave
  rtl_view/ esquematicos .svg generados por yosys
```

## Requisitos

Tener activado el entorno de oss-cad-suite en la terminal, por ejemplo:

```bash
source /ruta/a/oss-cad-suite/environment
```

## Uso

Simular el modulo de ejemplo (`half_adder`):

```bash
make sim
```

Ver la forma de onda:

```bash
make wave
```

Generar el esquematico RTL, con bloques de alto nivel (`build/rtl_view/half_adder.svg`):

```bash
make rtl
```

Generar el circuito reducido a COMPUERTAS BASICAS (AND, OR, XOR, MUX, NOT),
(`build/rtl_view/half_adder_gates.svg`):

```bash
make gates
```

> Nota sobre `make rtl` vs `make gates`: `yosys show` dibuja todas las
> celdas como cajas rectangulares con el nombre adentro (no usa el simbolo
> grafico clasico de cada compuerta), asi que para circuitos chicos ambas
> vistas pueden verse parecidas. Lo que cambia es el **netlist**: en `rtl`
> son celdas de alto nivel (sumadores, muxes completos); en `gates` es la
> red ya descompuesta en AND/OR/XOR/MUX/NOT.

Opcional: esquematico con los simbolos de compuerta "de libro" (la D de
AND, la curva de OR, el triangulo de NOT). Requiere instalar
`netlistsvg` aparte (no viene con oss-cad-suite, necesita Node.js/npm):

```bash
npm install -g netlistsvg
make gates-schematic
```

Genera `build/rtl_view/half_adder_gates_schematic.svg`.

Todo en un solo comando (simulacion + esquema RTL + esquema a compuertas +
abrir la onda en gtkwave):

```bash
make full
```

Simulacion + esquema RTL + esquema a compuertas, sin abrir la onda:

```bash
make all
```

## Agregar un modulo nuevo

1. Crea `rtl/mi_modulo.v` con `module mi_modulo (...);`
2. Crea `tb/mi_modulo_tb.v` con el testbench correspondiente
   (copia y adapta `tb/half_adder_tb.v` como referencia, prestando
   atencion a la linea `$dumpfile("build/waves/mi_modulo.vcd")`).
3. Corre:

```bash
make sim MODULE=mi_modulo
make rtl MODULE=mi_modulo
```

No hace falta tocar el Makefile: el nombre de archivo/modulo se pasa
como variable `MODULE`.

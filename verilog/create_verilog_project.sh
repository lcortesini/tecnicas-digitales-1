#!/usr/bin/env bash
#
# create_verilog_project.sh
#
# Genera una plantilla de proyecto para trabajar con oss-cad-suite:
#   - rtl/<module>.v      -> descripcion del modulo combinacional
#   - tb/<module>_tb.v    -> testbench del modulo
#   - Makefile             -> compila y simula con icarus verilog (iverilog/vvp)
#                             y genera el esquematico RTL con yosys
#   - build/               -> salidas: .vvp, .vcd (onda) y .svg (esquema RTL)
#
# Uso:
#   ./create_verilog_project.sh <nombre_proyecto> [nombre_modulo]
#
# Ejemplo:
#   ./create_verilog_project.sh mi_alu alu4
#
# Requisitos (ya cubiertos por oss-cad-suite): iverilog, vvp, yosys, dot (graphviz),
# opcionalmente gtkwave para ver la onda.

set -euo pipefail

PROJECT_NAME="${1:-mi_proyecto_verilog}"
MODULE_NAME="${2:-example}"

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: el directorio '$PROJECT_NAME' ya existe. Elegi otro nombre o borralo primero." >&2
  exit 1
fi

echo ">> Creando estructura en ./$PROJECT_NAME ..."
mkdir -p "$PROJECT_NAME"/{rtl,tb,build/waves,build/rtl_view}

# ---------------------------------------------------------------------------
# 1) Modulo RTL de ejemplo (combinacional): mux 4 a 1 de 4 bits
# ---------------------------------------------------------------------------
cat > "$PROJECT_NAME/rtl/${MODULE_NAME}.v" << EOF
// -----------------------------------------------------------------------
// ${MODULE_NAME}.v
// Ejemplo de circuito COMBINACIONAL: multiplexor 4 a 1, datos de 4 bits.
// Reemplaza este contenido por tu propio diseño; mantene el nombre del
// modulo igual al nombre del archivo para que el Makefile funcione sin
// tocar nada mas.
// -----------------------------------------------------------------------
module ${MODULE_NAME} (
    input  wire [3:0] in0,
    input  wire [3:0] in1,
    input  wire [3:0] in2,
    input  wire [3:0] in3,
    input  wire [1:0] sel,
    output reg  [3:0] out
);

    // Logica puramente combinacional -> siempre bloque "always @(*)"
    always @(*) begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
            default: out = 4'bxxxx;
        endcase
    end

endmodule
EOF

# ---------------------------------------------------------------------------
# 2) Testbench de ejemplo
# ---------------------------------------------------------------------------
cat > "$PROJECT_NAME/tb/${MODULE_NAME}_tb.v" << EOF
\`timescale 1ns/1ps
// -----------------------------------------------------------------------
// ${MODULE_NAME}_tb.v
// Testbench basico: aplica estimulos, imprime resultados por consola y
// vuelca las senales a un .vcd para poder verlas en gtkwave.
// -----------------------------------------------------------------------
module ${MODULE_NAME}_tb;

    reg  [3:0] in0, in1, in2, in3;
    reg  [1:0] sel;
    wire [3:0] out;

    integer errores = 0;

    // Instancia del DUT (Device Under Test)
    ${MODULE_NAME} dut (
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .sel(sel),
        .out(out)
    );

    // Volcado de ondas para gtkwave
    initial begin
        \$dumpfile("build/waves/${MODULE_NAME}.vcd");
        \$dumpvars(0, ${MODULE_NAME}_tb);
    end

    task check(input [3:0] esperado);
        begin
            if (out !== esperado) begin
                \$display("FALLO  sel=%b out=%b esperado=%b (t=%0t)", sel, out, esperado, \$time);
                errores = errores + 1;
            end else begin
                \$display("OK     sel=%b out=%b (t=%0t)", sel, out, \$time);
            end
        end
    endtask

    initial begin
        in0 = 4'h1; in1 = 4'h2; in2 = 4'h3; in3 = 4'h4;

        sel = 2'b00; #10; check(in0);
        sel = 2'b01; #10; check(in1);
        sel = 2'b10; #10; check(in2);
        sel = 2'b11; #10; check(in3);

        if (errores == 0)
            \$display("\\n*** TODOS LOS CASOS PASARON ***");
        else
            \$display("\\n*** %0d CASO(S) FALLARON ***", errores);

        \$finish;
    end

endmodule
EOF

# ---------------------------------------------------------------------------
# 3) Makefile
# ---------------------------------------------------------------------------
cat > "$PROJECT_NAME/Makefile" << 'EOF'
# Makefile - flujo de trabajo con oss-cad-suite (iverilog / vvp / yosys)
#
# Uso rapido:
#   make sim              -> compila y simula el testbench (usa MODULE)
#   make wave             -> abre la onda generada en gtkwave
#   make rtl              -> esquematico RTL; submodulos como cajas (jerarquico)
#   make rtl-flat         -> esquematico RTL, todo expandido (sin cajas de submodulos)
#   make gates            -> esquematico a compuertas; submodulos como cajas
#   make gates-flat       -> esquematico a compuertas, todo expandido
#   make rtl-interactive  -> esquematico interactivo en el navegador (DigitalJS)
#   make full             -> sim + rtl + gates (+ gates-schematic si esta disponible) + abre wave
#   make all              -> sim + rtl + gates (sin abrir wave)
#   make clean            -> borra los archivos generados
#
# Para trabajar con otro modulo (sin editar este archivo):
#   make sim MODULE=nombre_modulo

MODULE ?= __MODULE_NAME__

RTL_DIR   := rtl
TB_DIR    := tb
BUILD_DIR := build
WAVE_DIR  := $(BUILD_DIR)/waves
RTL_OUT   := $(BUILD_DIR)/rtl_view

# RTL_SRC junta TODOS los .v de rtl/, no solo el del modulo top. Esto es
# necesario si tu modulo instancia otros (por ejemplo full_adder que usa
# half_adder): yosys/iverilog necesitan ver la definicion de cada submodulo
# ademas del top. "hierarchy -check -top $(MODULE)" (en yosys) y el propio
# testbench (en iverilog) se encargan de elegir cual es el punto de entrada.
RTL_SRC := $(wildcard $(RTL_DIR)/*.v)
TB_SRC  := $(TB_DIR)/$(MODULE)_tb.v

# Ubicacion de los paquetes npm globales usados por "rtl-interactive"
# (yosys2digitaljs y digitaljs). Se resuelve dinamicamente con "npm root -g".
NPM_GLOBAL_ROOT := $(shell npm root -g 2>/dev/null)
Y2D_SCRIPT       := $(NPM_GLOBAL_ROOT)/yosys2digitaljs/process.js
DJS_DIST         := $(NPM_GLOBAL_ROOT)/digitaljs/dist
HTML_OUT         := $(RTL_OUT)/$(MODULE)_interactive.html

.PHONY: all sim wave rtl rtl-flat rtl-interactive gates gates-flat gates-schematic full clean dirs

all: sim rtl gates

# Corre todo: simulacion + ambos esquematicos (RTL y compuertas), y al final
# abre la onda en gtkwave. Si "netlistsvg" esta instalado tambien genera el
# esquematico con simbolos de compuerta reales; si no esta, lo salta con un
# aviso, sin cortar el resto del flujo.
full: sim rtl gates
	@command -v netlistsvg >/dev/null 2>&1 && $(MAKE) gates-schematic || \
		echo "(netlistsvg no encontrado, se omite gates-schematic; ver 'make gates-schematic' para instalarlo)"
	gtkwave $(WAVE_DIR)/$(MODULE).vcd &

dirs:
	mkdir -p $(BUILD_DIR) $(WAVE_DIR) $(RTL_OUT)

# Compila el RTL junto con el testbench y corre la simulacion.
# El testbench se encarga de escribir el .vcd (ver $dumpfile en el tb).
sim: dirs
	iverilog -g2012 -o $(BUILD_DIR)/$(MODULE).vvp $(RTL_SRC) $(TB_SRC)
	vvp $(BUILD_DIR)/$(MODULE).vvp

# Abre la forma de onda generada por la simulacion.
wave: sim
	gtkwave $(WAVE_DIR)/$(MODULE).vcd &

# Genera un esquematico del circuito (RTL view) a partir del modulo,
# sin testbench, usando yosys + graphviz (dot), incluidos en oss-cad-suite.
# Esta vista usa celdas RTL de alto nivel (sumadores, muxes, comparadores, etc).
# Si tu diseño tiene submodulos (p.ej. full_adder que instancia half_adder),
# esos submodulos se dibujan como CAJAS separadas, sin expandirse: pasarle
# "$(MODULE)" a "show" hace que solo dibuje el modulo top y deje las
# instancias de submodulos como bloques. Para ver todo expandido en un solo
# nivel de compuertas, usa "make rtl-flat".
rtl: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; show -format svg -prefix $(RTL_OUT)/$(MODULE) $(MODULE)"
	@echo "Esquematico RTL generado en: $(RTL_OUT)/$(MODULE).svg"

# Igual que "rtl", pero con "flatten": mete las instancias de submodulos
# dentro del top, asi que en el dibujo ya no aparecen como cajas separadas,
# sino como el conjunto completo de celdas que las componen.
rtl-flat: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); flatten; proc; opt; show -format svg -prefix $(RTL_OUT)/$(MODULE)_flat"
	@echo "Esquematico RTL (aplanado) generado en: $(RTL_OUT)/$(MODULE)_flat.svg"

# Genera el circuito ya reducido a COMPUERTAS BASICAS (AND, OR, XOR, MUX, NOT).
# techmap + abc hacen la sintesis logica dentro de CADA modulo por separado;
# los submodulos siguen apareciendo como cajas en el dibujo (misma logica
# que en "rtl"). Para ver las compuertas de los submodulos tambien
# expandidas en el dibujo, usa "make gates-flat".
gates: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; techmap; opt; abc -g AND,OR,XOR,MUX; opt_clean; show -format svg -prefix $(RTL_OUT)/$(MODULE)_gates $(MODULE)"
	@echo "Esquematico a nivel de compuertas generado en: $(RTL_OUT)/$(MODULE)_gates.svg"

# Igual que "gates", pero con "flatten" antes de sintetizar: el resultado
# es un unico modulo con TODAS las compuertas del diseño completo,
# incluyendo las de los submodulos, sin cajas intermedias.
gates-flat: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); flatten; proc; opt; techmap; opt; abc -g AND,OR,XOR,MUX; opt_clean; show -format svg -prefix $(RTL_OUT)/$(MODULE)_gates_flat"
	@echo "Esquematico a nivel de compuertas (aplanado) generado en: $(RTL_OUT)/$(MODULE)_gates_flat.svg"

clean:
	rm -rf $(BUILD_DIR)

# ---------------------------------------------------------------------------
# OPCIONAL: esquematico con simbolos de compuerta "de libro" (la D de AND,
# la curva de OR, el triangulo de NOT), usando netlistsvg.
#
# A diferencia de "rtl" y "gates" (que solo usan yosys+graphviz, incluidos
# en oss-cad-suite), este target necesita netlistsvg, que NO viene con
# oss-cad-suite. Se instala aparte (requiere Node.js/npm):
#
#   npm install -g netlistsvg
#
# Aca tambien se aplana el diseño ("flatten") para que quede un solo modulo
# con todas las compuertas del circuito completo.
# ---------------------------------------------------------------------------
gates-schematic: dirs
	@command -v netlistsvg >/dev/null 2>&1 || { \
		echo "ERROR: no se encontro 'netlistsvg' en el PATH."; \
		echo "Instalalo con: npm install -g netlistsvg  (requiere Node.js/npm)"; \
		exit 1; \
	}
# ---------------------------------------------------------------------------
# OPCIONAL: esquematico INTERACTIVO en el navegador (simbolos de compuerta
# reales + simulacion en vivo tocando los inputs), usando DigitalJS
# (motor: https://github.com/tilk/digitaljs, conversor: yosys2digitaljs).
#
# No viene con oss-cad-suite. Se instala aparte (requiere Node.js/npm):
#
#   npm install -g yosys2digitaljs digitaljs
#
# El motor de simulacion por defecto de DigitalJS (SynchEngine) corre en el
# mismo hilo, sin Web Workers, asi que el .html generado se puede abrir
# directo haciendo doble click o con file:// (no hace falta servidor).
# ---------------------------------------------------------------------------
rtl-interactive: dirs
	@command -v node >/dev/null 2>&1 || { \
		echo "ERROR: no se encontro 'node' en el PATH. Instala Node.js."; \
		exit 1; \
	}
	@[ -f "$(Y2D_SCRIPT)" ] && [ -d "$(DJS_DIST)" ] || { \
		echo "ERROR: falta yosys2digitaljs y/o digitaljs."; \
		echo "Instalalos con: npm install -g yosys2digitaljs digitaljs"; \
		exit 1; \
	}
	node "$(Y2D_SCRIPT)" --tmpdir --html $(RTL_SRC) > $(HTML_OUT)
	cp "$(DJS_DIST)"/*.js $(RTL_OUT)/
	@echo "Esquematico interactivo generado en: $(HTML_OUT)"
	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open "file://$(abspath $(HTML_OUT))" >/dev/null 2>&1 & \
	elif command -v open >/dev/null 2>&1; then \
		open "file://$(abspath $(HTML_OUT))" >/dev/null 2>&1 & \
	else \
		echo "Abrilo manualmente con doble click, o pegando la ruta en el navegador."; \
	fi
EOF

# El Makefile se escribio con heredoc "quoted" (para no expandir $(...) de make),
# asi que el nombre de modulo por defecto se inyecta aca con sed.
sed -i "s/__MODULE_NAME__/${MODULE_NAME}/" "$PROJECT_NAME/Makefile"

# ---------------------------------------------------------------------------
# 4) .gitignore
# ---------------------------------------------------------------------------
cat > "$PROJECT_NAME/.gitignore" << 'EOF'
build/
*.vvp
*.vcd
*.svg
EOF

# ---------------------------------------------------------------------------
# 5) README con instrucciones
# ---------------------------------------------------------------------------
cat > "$PROJECT_NAME/README.md" << EOF
# ${PROJECT_NAME}

Plantilla para describir circuitos combinacionales en Verilog usando
**oss-cad-suite** (iverilog, vvp, yosys, gtkwave).

## Estructura

\`\`\`
rtl/        modulos Verilog (el diseño)
tb/         testbenches (uno por modulo, sufijo _tb.v)
build/      salidas generadas (se borra con "make clean")
  waves/    archivos .vcd para ver en gtkwave
  rtl_view/ esquematicos .svg generados por yosys
\`\`\`

## Requisitos

Tener activado el entorno de oss-cad-suite en la terminal, por ejemplo:

\`\`\`bash
source /ruta/a/oss-cad-suite/environment
\`\`\`

## Uso

Simular el modulo de ejemplo (\`${MODULE_NAME}\`):

\`\`\`bash
make sim
\`\`\`

Ver la forma de onda:

\`\`\`bash
make wave
\`\`\`

Generar el esquematico RTL, con bloques de alto nivel (\`build/rtl_view/${MODULE_NAME}.svg\`):

\`\`\`bash
make rtl
\`\`\`

Generar el circuito reducido a COMPUERTAS BASICAS (AND, OR, XOR, MUX, NOT),
(\`build/rtl_view/${MODULE_NAME}_gates.svg\`):

\`\`\`bash
make gates
\`\`\`

> Nota sobre \`make rtl\` vs \`make gates\`: \`yosys show\` dibuja todas las
> celdas como cajas rectangulares con el nombre adentro (no usa el simbolo
> grafico clasico de cada compuerta), asi que para circuitos chicos ambas
> vistas pueden verse parecidas. Lo que cambia es el **netlist**: en \`rtl\`
> son celdas de alto nivel (sumadores, muxes completos); en \`gates\` es la
> red ya descompuesta en AND/OR/XOR/MUX/NOT.

Opcional: esquematico con los simbolos de compuerta "de libro" (la D de
AND, la curva de OR, el triangulo de NOT). Requiere instalar
\`netlistsvg\` aparte (no viene con oss-cad-suite, necesita Node.js/npm):

\`\`\`bash
npm install -g netlistsvg
make gates-schematic
\`\`\`

Genera \`build/rtl_view/${MODULE_NAME}_gates_schematic.svg\`.

Opcional: esquematico INTERACTIVO en el navegador, con simulacion en vivo
(tocas los inputs y ves como cambia la salida), usando DigitalJS. Requiere
instalar \`yosys2digitaljs\` y \`digitaljs\` aparte (no vienen con
oss-cad-suite, necesitan Node.js/npm):

\`\`\`bash
npm install -g yosys2digitaljs digitaljs
make rtl-interactive
\`\`\`

Genera \`build/rtl_view/${MODULE_NAME}_interactive.html\` y lo abre solo en
el navegador (no hace falta servidor: el motor de simulacion de DigitalJS
corre en el mismo hilo, sin Web Workers).

Todo en un solo comando (simulacion + esquema RTL + esquema a compuertas +
abrir la onda en gtkwave):

\`\`\`bash
make full
\`\`\`

Simulacion + esquema RTL + esquema a compuertas, sin abrir la onda:

\`\`\`bash
make all
\`\`\`

## Agregar un modulo nuevo

1. Crea \`rtl/mi_modulo.v\` con \`module mi_modulo (...);\`
2. Crea \`tb/mi_modulo_tb.v\` con el testbench correspondiente
   (copia y adapta \`tb/${MODULE_NAME}_tb.v\` como referencia, prestando
   atencion a la linea \`\$dumpfile("build/waves/mi_modulo.vcd")\`).
3. Corre:

\`\`\`bash
make sim MODULE=mi_modulo
make rtl MODULE=mi_modulo
\`\`\`

No hace falta tocar el Makefile: el nombre de archivo/modulo se pasa
como variable \`MODULE\`.
EOF

chmod -R u+rwX "$PROJECT_NAME"

echo ""
echo ">> Proyecto '$PROJECT_NAME' creado con exito."
echo ">> Modulo de ejemplo: $MODULE_NAME (rtl/${MODULE_NAME}.v, tb/${MODULE_NAME}_tb.v)"
echo ""
echo "Proximos pasos:"
echo "  cd $PROJECT_NAME"
echo "  source /ruta/a/oss-cad-suite/environment   # si no lo activaste ya"
echo "  make sim     # simula"
echo "  make rtl     # genera el esquematico RTL (bloques de alto nivel)"
echo "  make gates   # genera el circuito reducido a compuertas (AND/OR/XOR/MUX/NOT)"
echo "  make wave    # ver la onda en gtkwave (opcional)"
echo "  make full    # simula + genera todos los esquematicos + abre la onda"
echo ""
echo "Opcional (requiere 'npm install -g netlistsvg', no incluido en oss-cad-suite):"
echo "  make gates-schematic  # simbolos de compuerta clasicos (AND/OR/NOT reales)"
echo ""
echo "Opcional (requiere 'npm install -g yosys2digitaljs digitaljs'):"
echo "  make rtl-interactive  # esquematico interactivo en el navegador (DigitalJS)"

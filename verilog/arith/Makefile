# Makefile - flujo de trabajo con oss-cad-suite (iverilog / vvp / yosys)
#
# Uso rapido:
#   make sim              -> compila y simula el testbench (usa MODULE)
#   make wave             -> abre la onda generada en gtkwave
#   make rtl              -> esquematico RTL; submodulos como cajas (jerarquico)
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
RTL_OUT   := $(BUILD_DIR)/rtl_view
INTERACTIVE_V := $(RTL_OUT)/$(MODULE)_interactive.v
 

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
 
.PHONY: all sim wave rtl rtl-flat rtl-interactive gates gates-flat gates-schematic full clean dirs rtl-all
 
all: sim rtl gates

rtl-all: rtl gates gates-schematic rtl-interactive
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

	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; write_verilog $(INTERACTIVE_V)"

	node "$(Y2D_SCRIPT)" --tmpdir --html "$(INTERACTIVE_V)" > "$(HTML_OUT)"

	cp "$(DJS_DIST)"/*.js $(RTL_OUT)/
	@echo "Esquematico interactivo generado en: $(HTML_OUT)"

	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open "file://$(abspath $(HTML_OUT))" >/dev/null 2>&1 & \
	elif command -v open >/dev/null 2>&1; then \
		open "file://$(abspath $(HTML_OUT))" >/dev/null 2>&1 & \
	else \
		echo "Abrilo manualmente con doble click, o pegando la ruta en el navegador."; \
	fi

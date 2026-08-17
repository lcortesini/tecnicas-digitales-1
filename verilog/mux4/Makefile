# Makefile - flujo de trabajo con oss-cad-suite (iverilog / vvp / yosys)
#
# Uso rapido:
#   make sim              -> compila y simula el testbench (usa MODULE)
#   make wave             -> abre la onda generada en gtkwave
#   make rtl              -> genera el esquematico RTL (.svg) con yosys
#   make gates            -> genera el esquematico a nivel de compuertas (.svg)
#   make full             -> sim + rtl + gates (+ gates-schematic si esta disponible) + abre wave
#   make all              -> sim + rtl + gates (sin abrir wave)
#   make clean            -> borra los archivos generados
#
# Para trabajar con otro modulo (sin editar este archivo):
#   make sim MODULE=nombre_modulo

MODULE ?= mux4

RTL_DIR   := rtl
TB_DIR    := tb
BUILD_DIR := build
WAVE_DIR  := $(BUILD_DIR)/waves
RTL_OUT   := $(BUILD_DIR)/rtl_view

RTL_SRC := $(RTL_DIR)/$(MODULE).v
TB_SRC  := $(TB_DIR)/$(MODULE)_tb.v

.PHONY: all sim wave rtl gates gates-schematic full clean dirs

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
rtl: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; show -format svg -prefix $(RTL_OUT)/$(MODULE)"
	@echo "Esquematico RTL generado en: $(RTL_OUT)/$(MODULE).svg"

# Genera el circuito ya reducido a COMPUERTAS BASICAS (AND, OR, XOR, MUX, NOT).
# techmap + abc hacen la sintesis logica; el resultado es el mismo circuito
# pero expresado como una red de compuertas, no como bloques RTL abstractos.
gates: dirs
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; techmap; opt; abc -g AND,OR,XOR,MUX; opt_clean; show -format svg -prefix $(RTL_OUT)/$(MODULE)_gates"
	@echo "Esquematico a nivel de compuertas generado en: $(RTL_OUT)/$(MODULE)_gates.svg"

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
# "yosys show" dibuja todas las celdas como simples cajas rectangulares con
# el nombre adentro, sin importar el tipo de compuerta; por eso "make rtl"
# y "make gates" pueden verse parecidos entre si para circuitos chicos.
# netlistsvg si usa simbolos graficos reales por tipo de celda.
# ---------------------------------------------------------------------------
gates-schematic: dirs
	@command -v netlistsvg >/dev/null 2>&1 || { \
		echo "ERROR: no se encontro 'netlistsvg' en el PATH."; \
		echo "Instalalo con: npm install -g netlistsvg  (requiere Node.js/npm)"; \
		exit 1; \
	}
	yosys -p "read_verilog $(RTL_SRC); hierarchy -check -top $(MODULE); proc; opt; techmap; opt; abc -g AND,OR,XOR,MUX; opt_clean; write_json $(RTL_OUT)/$(MODULE)_gates.json"
	netlistsvg $(RTL_OUT)/$(MODULE)_gates.json -o $(RTL_OUT)/$(MODULE)_gates_schematic.svg
	@echo "Esquematico con simbolos de compuerta generado en: $(RTL_OUT)/$(MODULE)_gates_schematic.svg"

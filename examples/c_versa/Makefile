TRELLIS=/usr/local/share/trellis

CC=riscv64-linux-gnu-gcc-8
CFLAGS=-Os -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -s

firmware.elf: start.o main.o
	riscv64-linux-gnu-gcc-8 -march=rv32i -mabi=ilp32 -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

firmware.bin: firmware.elf
	riscv64-linux-gnu-objcopy -O binary $< $@

firmware.hex: firmware.bin
	python3 makehex.py $< 256 > $@

attosoc_tb.vvp: attosoc_tb.v attosoc.v picorv32.v 
	iverilog -s testbench -o $@ $^

attosoc_sim: attosoc_tb.vvp firmware.hex
	vvp -N $<

attosoc.json: io_wrapper.v attosoc.v picorv32.v firmware.hex
	yosys -p "synth_ecp5 -nomux -json $@ -top top" io_wrapper.v attosoc.v picorv32.v

attosoc_out.config: attosoc.json
	nextpnr-ecp5 --json $< --textcfg $@ --um-45k

attosoc.bit: attosoc_out.config
	ecppack --svf-rowsize 100000 --svf attosoc.svf $< $@

attosoc.svf: attosoc.bit

prog: attosoc.svf
	openocd -f ${TRELLIS}/misc/openocd/ecp5-versa.cfg -c "transport select jtag; init; svf $<; exit"

.PHONY: attosoc_sim clean prog
.PRECIOUS: attosoc.json attosoc_out.config attosoc.bit

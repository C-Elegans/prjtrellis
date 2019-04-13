TRELLIS=/usr/local/share/trellis


CC=riscv64-linux-gnu-gcc-8
CFLAGS=-Os -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -s

firmware.elf: start.o firmware.o
	riscv64-linux-gnu-gcc-8 -march=rv32i -mabi=ilp32 -Wl,-Bstatic,-T,sections.lds,--strip-debug,--build-id=none -ffreestanding -nostdlib -o firmware.elf $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

firmware.bin: firmware.elf
	riscv64-linux-gnu-objcopy -O binary --only-section=.text firmware.elf firmware.bin

firmware.hex: firmware.bin
	python3 makehex.py $^ 512 > $@

attosoc_tb.vvp: attosoc_tb.v attosoc.v picorv32.v simpleuart.v
	iverilog -s testbench -o $@ $^

attosoc_sim: attosoc_tb.vvp firmware.hex
	vvp -N $<

attosoc.json: top.v pll.v attosoc.v picorv32.v firmware.hex
	yosys -p "synth_ecp5 -json $@ -top top" top.v pll.v attosoc.v picorv32.v simpleuart.v

attosoc_out.config: attosoc.json versa.lpf
	nextpnr-ecp5 --json attosoc.json --lpf versa.lpf --textcfg $@ --um-45k --freq 50 

attosoc.bit: attosoc_out.config
	ecppack --svf-rowsize 100000 --svf attosoc.svf $< $@

attosoc.svf: attosoc_out.config

prog: attosoc.svf attosoc.bit
	openocd -f ${TRELLIS}/misc/openocd/ecp5-versa.cfg -c "transport select jtag; init; svf $<; exit"

.PHONY: attosoc_sim clean prog
.PRECIOUS: attosoc.json attosoc_out.config attosoc.bit

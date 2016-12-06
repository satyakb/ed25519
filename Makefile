CC=yosys
CFLAGS=-p "synth_ice40 -abc2 -blif outputs/test.blif" -ql outputs/test.log -o outputs/test_syn.v

setup:
	mkdir -p outputs

point_add: setup
	rm -f outputs/point_add_tb.out
	iverilog -o outputs/point_add_tb.out src/point_add.v src/point_add_tb.v
	outputs/point_add_tb.out

point_add_lut: setup
	$(CC) $(CFLAGS) src/point_add.v
	# yosys -p "synth_ice40 -abc2 -blif outputs/test.blif" src/point_add.v
	# sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k

seq_mult: setup
	rm -f outputs/seq_mult_tb.out
	iverilog -o outputs/seq_mult_tb.out src/seq_mult.v src/seq_mult_tb.v
	outputs/seq_mult_tb.out

seq_mult_lut: setup
	$(CC) $(CFLAGS) src/seq_mult.v
	# yosys -p "synth_ice40 -abc2 -blif outputs/test.blif" src/point_add.v
	# sleep 1
	arachne-pnr outputs/test.blif -o outputs/test.txt -d 8k

clean:
	rm -rf outputs
RTL = top_pong.sv clock_480p.sv hdmi_device.v rpint.v tmds_encoder.v \
	simple_score.sv simple_480p.sv debounce.sv

pong:
	mkdir -p output
	yosys -q -p "synth_ice40 -top top_pong -json output/pong.json" $(RTL)
	nextpnr-ice40 --hx8k --package ct256 --pcf keks.pcf \
		--asc output/pong.txt --json output/pong.json \
		--pcf-allow-unconstrained
	icebox_explain output/pong.txt > output/pong.ex
	icepack output/pong.txt output/pong.bin

prog:
	ldprog -ks output/pong.bin

flash:
	ldprog -kf output/pong.bin

clean:
	rm -f output/*

.PHONY: pong clean

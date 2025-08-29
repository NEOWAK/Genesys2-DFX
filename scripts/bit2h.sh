./bit2bin.sh system_i_dynamic_0_inv_inst_0_partial.bit inv_partial.bin
./bit2bin.sh system_i_dynamic_0_pass_inst_0_partial.bit pass_partial.bin

xxd -i pass_partial.bin pass_partial.h
xxd -i inv_partial.bin inv_partial.h

#Vérification des fichiers sources necessaires
proc checkRequiredFiles {origin_dir} {
  set status true
  set files [list \
 "[file normalize "$origin_dir/ressources/mig_a.prj"]"\
 "[file normalize "$origin_dir/ressources/Genesys-2-Master.xdc"]"\
  ]
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find local file $ifile "
      set status false
    }
  }

  set paths [list \
 "[file normalize "$origin_dir/[file normalize "$origin_dir/ressources/customs_IP"]"]"\
  ]
  foreach ipath $paths {
    if { ![file isdirectory $ipath] } {
      puts " Could not access $ipath "
      set status false
    }
  }

  return $status
}


#Variables références
set origin_dir [file dirname [info script]]
set _xil_proj_name_ "genesys2_dfx"


#Aide
proc print_help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < $::argc} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set _xil_proj_name_ [lindex $::argv $i] }
      "--help"         { print_help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

#Verification des fichiers necessaires
set validate_required 0
if { $validate_required } {
  if { [checkRequiredFiles $origin_dir] } {
    puts "Tcl file $script_file is valid. All files required for project creation is accesable. "
  } else {
    puts "Tcl file $script_file is not valid. Not all files required for project creation is accesable. "
    return
  }
}

#Creation projet
create_project ${_xil_proj_name_} ${origin_dir}/${_xil_proj_name_} -part xc7k325tffg900-2
set_property board_part digilentinc.com:genesys2:part0:1.1 [current_project]
import_files -fileset constrs_1 -force -norecurse $origin_dir/ressources/Genesys-2-Master.xdc
set_property  ip_repo_paths $origin_dir/ressources/customs_IP [current_project]
update_ip_catalog

#Creation block-design
create_bd_design "system"
update_compile_order -fileset sources_1

#Ajout MIG7
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.2 mig_7series_0
apply_board_connection -board_interface "ddr3_sdram" -ip_intf "mig_7series_0/mig_ddr_interface" -diagram "system" 
endgroup

set_property CONFIG.XML_INPUT_FILE "$origin_dir/ressources/mig_a.prj" [get_bd_cells mig_7series_0]
set_property CONFIG.RESET_BOARD_INTERFACE {Custom} [get_bd_cells mig_7series_0]
set_property CONFIG.MIG_DONT_TOUCH_PARAM {Custom} [get_bd_cells mig_7series_0]
set_property CONFIG.BOARD_MIG_PARAM {ddr3_sdram} [get_bd_cells mig_7series_0]

update_compile_order -fileset sources_1
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( Reset ) } Manual_Source {New External Port (ACTIVE_LOW)}}  [get_bd_pins mig_7series_0/sys_rst]

#Ajout MicroBlaze
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:microblaze -config { axi_intc {0} axi_periph {Enabled} cache {16KB} clk {/mig_7series_0/ui_clk (100 MHz)} cores {1} debug_module {Debug Only} ecc {None} local_mem {16KB} preset {None}}  [get_bd_cells microblaze_0]

#Ajout UART
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
apply_board_connection -board_interface "usb_uart" -ip_intf "axi_uartlite_0/UART" -diagram "system" 
endgroup

#Ajout PUSH_BUTTON
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
apply_board_connection -board_interface "push_buttons_5bits" -ip_intf "axi_gpio_0/GPIO" -diagram "system" 
endgroup

#Ajout de pass (custom IP)
startgroup
create_bd_cell -type ip -vlnv user.org:user:pass:1.0 pass_0
endgroup

#Ajout HWICAP
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_hwicap:3.0 axi_hwicap_0
endgroup

#Creation connections
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/axi_gpio_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_gpio_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config { Clk {/mig_7series_0/ui_clk (100 MHz)} Freq {100} Ref_Clk0 {} Ref_Clk1 {} Ref_Clk2 {}}  [get_bd_pins axi_hwicap_0/icap_clk]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/axi_hwicap_0/S_AXI_LITE} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_hwicap_0/S_AXI_LITE]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/axi_uartlite_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins axi_uartlite_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (100 MHz)} Clk_slave {/mig_7series_0/ui_clk (100 MHz)} Clk_xbar {/mig_7series_0/ui_clk (100 MHz)} Master {/microblaze_0 (Cached)} Slave {/mig_7series_0/S_AXI} ddr_seg {Auto} intc_ip {New AXI SmartConnect} master_apm {0}}  [get_bd_intf_pins mig_7series_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/mig_7series_0/ui_clk (100 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/microblaze_0 (Periph)} Slave {/pass_0/S00_AXI} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins pass_0/S00_AXI]
endgroup

#Ajout port LEDs
startgroup
make_bd_pins_external  [get_bd_pins pass_0/leds_out]
endgroup

#Définition des ports externes déjà définis dans Genesys-2-Master.xdc

#Creation bloc DFX
group_bd_cells dynamic_0 [get_bd_cells pass_0]
validate_bd_design
startgroup
set curdesign [current_bd_design]
create_bd_design -cell [get_bd_cells /dynamic_0] pass
current_bd_design $curdesign
replace_bd_cell [get_bd_cells /dynamic_0] $new_cell
delete_bd_objs  [get_bd_cells /dynamic_0]
set_property name dynamic_0 $new_cell
endgroup
current_bd_design [get_bd_designs pass]
current_bd_design [get_bd_designs system]
set_property -dict [list \
  CONFIG.ENABLE_DFX {true} \
  CONFIG.LOCK_PROPAGATE {true} \
] [get_bd_cells dynamic_0]

validate_bd_design

#Creation du module reconfigurable inv
set curdesign [current_bd_design]
create_bd_design -boundary_from_container [get_bd_cells /dynamic_0] inv
set_property -dict [list CONFIG.LIST_SYNTH_BD {pass.bd:inv.bd} CONFIG.LIST_SIM_BD {pass.bd:inv.bd}] [get_bd_cells /dynamic_0]
current_bd_design $curdesign
current_bd_design [get_bd_designs inv]
startgroup
create_bd_cell -type ip -vlnv user.org:user:inv:1.0 inv_0
endgroup
connect_bd_intf_net [get_bd_intf_ports S00_AXI] [get_bd_intf_pins inv_0/S00_AXI]
connect_bd_net [get_bd_ports s00_axi_aclk] [get_bd_pins inv_0/s00_axi_aclk]
connect_bd_net [get_bd_ports s00_axi_aresetn] [get_bd_pins inv_0/s00_axi_aresetn]
connect_bd_net [get_bd_ports leds_out_0] [get_bd_pins inv_0/leds_out]
assign_bd_address
validate_bd_design
save_bd_design

open_bd_design "$origin_dir/genesys2_dfx/genesys2_dfx.srcs/sources_1/bd/system/system.bd"
save_bd_design

#Creation HDL Wrapper
make_wrapper -files [get_files $origin_dir/genesys2_dfx/genesys2_dfx.srcs/sources_1/bd/system/system.bd] -top
add_files -norecurse $origin_dir/genesys2_dfx/genesys2_dfx.gen/sources_1/bd/system/hdl/system_wrapper.v
update_compile_order -fileset sources_1

#Synthèse
launch_runs synth_1 -jobs 12

#Configuration DFX
create_pr_configuration -name config_1 -partitions [list system_i/dynamic_0:pass_inst_0 ]
create_pr_configuration -name config_2 -partitions [list system_i/dynamic_0:inv_inst_0 ]
set_property PR_CONFIGURATION config_1 [get_runs impl_1]
create_run child_0_impl_1 -parent_run impl_1 -flow {Vivado Implementation 2022} -pr_config config_2

#Dessin de la zone reconfigurable déjà fixée dans le fichier source Genesys-2-Master.xdc

#Implémentation et génération bitstreams
launch_runs impl_1 child_0_impl_1 -to_step write_bitstream -jobs 12

#Attente que les implémentations soient finies
wait_on_run impl_1
wait_on_run child_0_impl_1

#Exportation hardware
write_hw_platform -fixed -include_bit -force -file $origin_dir/$_xil_pro/system_wrapper.xsa
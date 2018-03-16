#
# Vivado (TM) v2014.4 (64-bit)
#
# testing.tcl: Tcl script for re-creating project 'test_proj'
#
# Generated by Vivado on Mon Feb 16 15:30:42 NZDT 2015
# IP Build 1070531 on Tue Nov 18 01:10:18 MST 2014
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (testing.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
#    <none>
#
# 3. The following remote source files that were added to the original project:-
#
#    "/home/matt/workspace/zynq_pcie_rc/dev_branch/src/constrs/zynq_rc_x4g1_loc.xdc"
#    "/home/matt/workspace/zynq_pcie_rc/dev_branch/src/constrs/zynq_rc_x4g1_timing.xdc"
#
#*****************************************************************************************

# Set the reference directory to where the script is
set origin_dir [file dirname [info script]]

# Create project
create_project -force proj ./proj

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects proj]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" "xc7z015clg485-1" $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Empty (no sources present)

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/constrs/zynq_rc_x4g1_loc.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/src/constrs/zynq_rc_x4g1_loc.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj
set_property "used_in_synthesis" "0" $file_obj

# Add/Import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/src/constrs/zynq_rc_x4g1_timing.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file "$origin_dir/src/constrs/zynq_rc_x4g1_timing.xdc"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" "[file normalize "$origin_dir/src/constrs/zynq_rc_x4g1_loc.xdc"]" $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z015clg485-1 -flow {Vivado Synthesis 2013} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2013" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" "xc7z015clg485-1" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7z015clg485-1 -flow {Vivado Implementation 2013} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2013" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" "xc7z015clg485-1" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:test_proj"

# Create block design
 source $origin_dir/src/bd/mk_bd.tcl

 # Generate the wrapper
 set design_name [get_bd_designs]
 make_wrapper -files [get_files $design_name.bd] -top -import

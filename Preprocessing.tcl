	######################################################################################
	## Preprocessing codes for displaying the deformed results 
	######################################################################################
	##  record all the nodetag and nodedisp in the model
	##	Xiaogang Huang & Dongping Zhu & Kun Hua , Southeast University 2016
	##
 	## 	getNodeTags : 		the nodetag list  for all nodes in the model
	## 	NodeNumbering  : 	nodetag is repeatd three times  
	## 	NodeTag.file : 	nodetag is  put in this file
	##  Nodedisp.file : nodedisp is put in this file
	##  trace :         tracer is activated after "analyze" command is executed
	##
	##	you must source Preprocessing.tcl between "node" command and "analyze" command
	#######################################################################################

set hxg 0
proc tracer { args } {

	global hxg
	set hxg [expr $hxg+1]
	if {$hxg == 1}  {
		set NodeNumbering "0"
		set NodeTags [getNodeTags]
		set Total [llength $NodeTags]
		for  {set i 0} { $i<$Total} {incr i} {
			set Single [lindex $NodeTags $i]
			set Triple [lrepeat 3 $Single]
			set NodeNumbering [concat $NodeNumbering $Triple]
		}
		set NodeTagsout [open NodeTag.file w]
		puts $NodeTagsout  "$NodeNumbering"
		close $NodeTagsout
		eval recorder Node -file Nodedisp.file -time -node $NodeTags -dof 1 2 3 disp


	    } 
    }

trace add execution analyze enter tracer
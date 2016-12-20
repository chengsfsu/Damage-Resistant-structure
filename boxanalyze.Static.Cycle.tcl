# --------------------------------------------------------------------------------------------------
# Example 5. 2D Frame --  Static Reversed Cyclic Analysis
#		Silvia Mazzoni & Frank McKenna, 2006
# execute this file after you have built the model, and after you apply gravity
#

# source in procedures
source GeneratePeaks.tcl;		# procedure to generate displacement increments for cyclic peaks

# characteristics of cyclic analysis
 # 2*[expr $bm] 3*[expr $bm] 4*[expr $bm] 5*[expr $bm]
# set bm 22.74
# set iDmax "1*[expr $bm] 2*[expr $bm] 3*[expr $bm] 4*[expr $bm] 5*[expr $bm]" ;

# set bm 1870;
# # set iDmax "[expr $dat1*$bm] [expr $dat2*$bm] [expr $dat3*$bm] [expr $dat4*$bm] [expr $dat5*$bm] [expr $dat6*$bm] [expr $dat7*$bm] [expr $dat8*$bm]  [expr $dat9*$bm]  [expr $dat10*$bm]" ;
# set iDmax "[expr $dat1*$bm] [expr $dat2*$bm] [expr $dat3*$bm] [expr $dat4*$bm] [expr $dat5*$bm] [expr $dat6*$bm]" ;





#set iDmax "1.4 2.8 4.2 5.6 7 8.4 9.8 11.2 12.6 14 15.4 16.8 ";
# 3*[expr $bm]   4*[expr $bm]  5*[expr $bm] 6*[expr $bm]  7*[expr $bm]
#    	# vector of displacement-cycle peaks, in terms of storey drift ratio
set Fact 1 ;			# scale drift ratio by storey height for displacement cycles
set Dincr 0.06;	# displacement increment for pushover. you want this to be very small, but not too small to slow analysis
set CycleType Full;			# you can do Full / Push / Half cycles with the proc
set Ncycles 1;			# specify the number of cycles at each peak
set LunitTXT mm£»
# -- STATIC PUSHOVER/CYCLIC ANALYSIS
# create load pattern for lateral pushover load coefficient when using linear load pattern
#pattern Plain 200 Linear {;			# define load pattern
#	for {set level 2} {$level <=[expr $NStory+1]} {incr level 1} {
#		set Fi [lindex $iFi [expr $level-1-1]];		# lateral load coefficient
#		for {set pier 1} {$pier <= [expr $NBay+1]} {incr pier 1} {
#			set nodeID [expr $level*10+$pier]
#			load $nodeID $Fi 0.0 0.0 0.0 0.0 0.0
#		}
#	}
#};		# end load pattern

# ----------- set up analysis parameters
source LibAnalysisStaticParameters.tcl;	# constraintsHandler,DOFnumberer,system-ofequations,convergenceTest,solutionAlgorithm,integrator

#  ---------------------------------    perform Static Cyclic Displacements Analysis
set fmt1 "%s Cyclic analysis: CtrlNode %.3i, dof %.1i, Disp=%.4f %s";	# format for screen/file output of DONE/PROBLEM analysis
foreach Dmax $iDmax {
	set iDstep [GeneratePeaks $Dmax $Dincr $CycleType $Fact];	# this proc is defined above
	for {set i 1} {$i <= $Ncycles} {incr i 1} {
		set zeroD 0
		set D0 0.0
		foreach Dstep $iDstep {
			set D1 $Dstep
			set Dincr [expr $D1 - $D0]
			integrator DisplacementControl  $IDctrlNode $IDctrlDOF $Dincr
			analysis Static
			# ----------------------------------------------first analyze command------------------------
			set ok [analyze 1]
			# ----------------------------------------------if convergence failure-------------------------
			if {$ok != 0} {
				# if analysis fails, we try some other stuff
				# performance is slower inside this loop	global maxNumIterStatic;	    # max no. of iterations performed before "failure to converge" is ret'd
				if {$ok != 0} {
					puts "Trying Newton with Initial Tangent .."
					test NormDispIncr   $TolStatic 2000 0
					algorithm Newton -initial
					set ok [analyze 1]
					test $testTypeStatic $TolStatic      $maxNumIterStatic    0
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {
					puts "Trying Broyden .."
					algorithm Broyden 8
					set ok [analyze 1 ]
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {
					puts "Trying NewtonWithLineSearch .."
					algorithm NewtonLineSearch 0.8 
					set ok [analyze 1]
					algorithm $algorithmTypeStatic
				}
                      if {$ok != 0} {
					puts "Trying NewtonWithLineSearch .."
                           algorithm KrylovNewton
					set ok [analyze 1]
					algorithm $algorithmTypeStatic
				}
				if {$ok != 0} {
					set putout [format $fmt1 "PROBLEM" $IDctrlNode $IDctrlDOF [nodeDisp $IDctrlNode $IDctrlDOF] $LunitTXT]
					puts $putout
					return -1
				}; # end if
			}; # end if
			# -----------------------------------------------------------------------------------------------------
			set D0 $D1;			# move to next step
			set controlDisp [nodeDisp $IDctrlNode $IDctrlDOF]
            puts $controlDisp
		}; # end Dstep
	};		# end i
};	# end of iDmaxCycl
# -----------------------------------------------------------------------------------------------------
if {$ok != 0 } {
	puts [format $fmt1 "PROBLEM" $IDctrlNode $IDctrlDOF [nodeDisp $IDctrlNode $IDctrlDOF] $LunitTXT]
} else {
	puts [format $fmt1 "DONE"  $IDctrlNode $IDctrlDOF [nodeDisp $IDctrlNode $IDctrlDOF] $LunitTXT]
}

# Units: N, mm, seconds
puts "node"
###################################################################################################
#          Set Up & Source Definition									  
###################################################################################################
	wipe all;							# clear memory of past model definitions
	model BasicBuilder -ndm 2 -ndf 3;	# Define the model builder, ndm = #dimension, ndf = #dofs
	source DisplayModel2D.tcl;			# procedure for displaying a 2D perspective of model
	source DisplayPlane.tcl;			# procedure for displaying a plane in a model
	source rotPanelZone2D.tcl;			# procedure for defining a rotational spring (zero-length element) to capture panel zone shear distortions
	source elemPanelZone2D.tcl;			# procedure for defining 8 elements to create a rectangular panel zone
###################################################################################################
#          Define Analysis Type										  
###################################################################################################
logFile errorFile on
set dataDir Data;				    # set up name of data directory (you can remove this)
file mkdir $dataDir; 				# create data directory
###################################################################################################
#          Define Building Geometry, Nodes, Masses, and Constraints											  
###################################################################################################
puts "node"
# define structure-geometry parameters
	set NStories 1;						# 总楼层数
	set NBays 1;						# 总跨数(除重力柱以外)
	set WBay      9150;		# 跨长
	set HStory1   3960;		# 第一层高度
	set HStoryTyp 3960;		# 其他层高度
	set HBuilding [expr $HStory1 + ($NStories-1)*$HStoryTyp];	# 建筑总高度
    set FDs 300; #摩擦板中心与梁端的距离
# calculate locations of beam-column joint centerlines:
	set Pier1  0.0;		# 柱线1
	set Pier2  [expr $Pier1 + $WBay];     # 柱线2

	set Floor1 0.0;		# 地面
	set Floor2 [expr $Floor1 + $HStory1]; # 楼层1

	
# calculate panel zone dimensions
	set pzlat23  [expr 416/2.0];	# 中心线到节点边缘的水平距离 (= 柱高的一半)
	set pzvert23 [expr 502/2.0];	# 中心线到节点边缘的垂直距离 (= 梁高的一半)

# # calculate plastic hinge offsets from beam-column centerlines:
	# set phlat23 [expr $pzlat23 + 0.0];	# 中心线到梁铰的水平距离
	# set phvert23 [expr $pzvert23 + 0.0];			# 中心线到柱铰的垂直距离
	
# 地面节点
	node 1000 $Pier1 $Floor1;
	node 2000 $Pier2 $Floor1;

	# 梁柱节点1 at Pier 1, Floor 2
	node 1 [expr $Pier1 - $pzlat23] [expr $Floor2 + $pzvert23];
	node 2 [expr $Pier1 - $pzlat23] [expr $Floor2 + $pzvert23];
	node 3 $Pier1  [expr $Floor2 + $pzvert23];
	node 4 [expr $Pier1 + $pzlat23] [expr $Floor2 + $pzvert23];
	node 5 [expr $Pier1 + $pzlat23] [expr $Floor2 + $pzvert23];
	node 6 [expr $Pier1 + $pzlat23] [expr $Floor2];
	node 7 [expr $Pier1 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 8 [expr $Pier1 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 9 $Pier1 [expr $Floor2 - $pzvert23]; 
	node 10 [expr $Pier1 - $pzlat23] [expr $Floor2 - $pzvert23];
	node 11 [expr $Pier1 - $pzlat23] [expr $Floor2 - $pzvert23];
	node 12 [expr $Pier1 - $pzlat23] [expr $Floor2];
	
	# 自复位节点1 at Pier 1, Floor 2
	node 13 [expr $Pier1 + $pzlat23] [expr $Floor2 + $pzvert23];
	node 15 [expr $Pier1 + $pzlat23] [expr $Floor2];
	node 16 [expr $Pier1 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 17 [expr $Pier1 + $pzlat23+$FDs] [expr $Floor2];
	node 18 [expr $Pier1 + $pzlat23+$FDs] [expr $Floor2];
	
	
	# 梁柱节点2 at Pier 2, Floor 2
	node 21 [expr $Pier2 - $pzlat23] [expr $Floor2 + $pzvert23];
	node 22 [expr $Pier2 - $pzlat23] [expr $Floor2 + $pzvert23];
	node 23 $Pier2  [expr $Floor2 + $pzvert23];
	node 24 [expr $Pier2 + $pzlat23] [expr $Floor2 + $pzvert23];
	node 25 [expr $Pier2 + $pzlat23] [expr $Floor2 + $pzvert23];
	node 26 [expr $Pier2 + $pzlat23] [expr $Floor2];
	node 27 [expr $Pier2 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 28 [expr $Pier2 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 29 $Pier2 [expr $Floor2 - $pzvert23]; 
	node 30 [expr $Pier2 - $pzlat23] [expr $Floor2 - $pzvert23];
	node 31 [expr $Pier2 - $pzlat23] [expr $Floor2 - $pzvert23];
	node 32 [expr $Pier2 - $pzlat23] [expr $Floor2];

		# 自复位节点1 at Pier 2, Floor 2
	node 33 [expr $Pier2 - $pzlat23] [expr $Floor2 + $pzvert23];
	node 35 [expr $Pier2 - $pzlat23] [expr $Floor2];
	node 36 [expr $Pier2 - $pzlat23] [expr $Floor2 - $pzvert23];
	node 37 [expr $Pier2 - $pzlat23-$FDs] [expr $Floor2];
	node 38 [expr $Pier2 - $pzlat23-$FDs] [expr $Floor2];


# 定义填充墙节点
	node 40 $Pier1 $Floor1;;
	node 41 $Pier2 $Floor1;
	node 42 [expr $Pier1 + $pzlat23] [expr $Floor2 - $pzvert23];
	node 43 [expr $Pier2 - $pzlat23] [expr $Floor2 - $pzvert23];

node 50 [expr $Pier1 + $WBay/2] [expr $Floor2];

# 地面固结
	fix 1000 1 1 0;
	fix 2000 1 1 0;
    
# 约束竖向位移
    equalDOF 6 15 2;
	equalDOF 32 35 2;
###################################################################################################
#          Define Section Properties and Elements													  
###################################################################################################
puts "section"
# 定义材料性质
    set matID_C 1;         # 钢柱标签
	set matID_B 2;         # 钢梁标签
	set matID_Ch 3;          # 梁Channel单元标签
    set matID_P 5;			# 填充墙标签
	set matID_Z1 6;			# 零长度平动自由度标签
	set matID_Z2 7;			# 零长度旋转自由度标签
	set matID_T0 8;          # 未施加预应力时预应力筋标签
	set matID_T1 9;          # 预应力筋标签
	set matID_D 10;          # 耗能器标签
	set matID_G1 11;          # 梁柱仅受压接触单元标签
	set matID_G2 12;          # 梁柱仅受压接触单元标签
	
	set Es 2.06e5;			# 钢弹性模量
	set Fy 345;			# 钢屈服强度
# 定义框架柱材料参数
    set b 0.01;
    set R0 15;
    set cR1 0.925;
    set cR2 0.15;
    set a1 0.02;
    set a2 1.0;
    set a3 0.02;
    set a4 1.0;
    set sigInit 0;
	
uniaxialMaterial Steel02 $matID_C $Fy $Es $b $R0 $cR1 $cR2 $a1 $a2 $a3 $a4 $sigInit;

# 定义框架梁材料参数
uniaxialMaterial Steel01 $matID_B $Fy $Es $b;





# 定义Hysteretic填充墙材料参数


# set s1p 0.001;
# set e1p 0.0008;
# set s2p 0.001;
# set e2p 0.0018;
# set s3p 0.001;
# set e3p 0.00182;



# set s1n -4;
# set e1n -0.0008;
# set s2n -4;
# set e2n -0.0018;
# set s3n -0;
# set e3n -0.00182;


set s1p 0.001;
set e1p 0.000189995;
set s2p 0.001;
set e2p 0.002273839;
set s3p 0.001;
set e3p 0.011369195;




set s1n -5.558704102;
set e1n -0.000189995;
set s2n -7.226315333;
set e2n -0.002273839;
set s3n -0.144526307;
set e3n -0.011369195;



set pinchX 1;
set pinchY 1;
set damage1 0;
set damage2 0;
uniaxialMaterial Hysteretic $matID_P $s1p $e1p $s2p $e2p $s3p $e3p $s1n $e1n $s2n $e2n $s3n $e3n $pinchX $pinchY $damage1 $damage2


# 定义预应力筋参数
set fz 1860;
set E2 1.95e5;
#预应力筋初始应变
set initStrain 2.95e-3;

uniaxialMaterial Steel01 $matID_T0 $fz $E2 $b;   #预应力筋
uniaxialMaterial InitStrainMaterial $matID_T1 $matID_T0 $initStrain;

# 定义耗能器参数
set Ff 158400;
set E3 2.06e7;
set Rhard 0;
uniaxialMaterial Steel01 $matID_D $Ff $E3 $Rhard ;    # 耗能器

# 定义梁柱仅受压缝截面参数
set Ect 2.06e9; 
uniaxialMaterial ENT  $matID_G1  $Ect;
uniaxialMaterial Elastic $matID_G2 [expr $Es/100];
# 定义填充墙铰接参数
set E0 2.06e10;
set E1 1;
uniaxialMaterial Elastic $matID_Z1 $E0;
uniaxialMaterial Elastic $matID_Z2 $E1;


#定义梁、柱截面
set secTag_C 1
set secTag_B 2
source WSection.tcl;
WSection $secTag_C $matID_C  416.04 406.27 48 29.84   10 2 2 5;
WSection $secTag_B $matID_B  570.99 315.47 34.54 19.05  10 2 2 5;

set numIntgrPts 10;	
# 定义柱截面的几何性质W14*257
	set Acol_12 48774.1;		# cross-sectional area
	set Icol_12  1.415e9;	# moment of inertia
	# set Mycol_12 20350.0;	# yield moment at plastic hinge location (i.e., My of RBS section)
	set dcol_12 416.04;		# depth
	set bfcol_12 406.27;		# flange width
	set tfcol_12 48;		# flange thickness
	set twcol_12 29.84;		# web thickness

# 定义梁截面的几何性质W21*166
	set Abeam_23  31484;		# cross-sectional area (full section properties)
	set Ibeam_23  1.78e9;	# moment of inertia  (full section properties)
	# set Mybeam_23 10938.0;	# yield moment at plastic hinge location (i.e., My of RBS section)
	set dbeam_23 570.99;		# depth
	
puts "element"	
# set up geometric transformation of elements
	set PDeltaTransf 1;
	geomTransf PDelta $PDeltaTransf; 	# PDelta transformation

	
	
#定义柱单元
element	nonlinearBeamColumn	1  1000 9 $numIntgrPts	$secTag_C	$PDeltaTransf;	# Pier 1
element	nonlinearBeamColumn	2  2000 29 $numIntgrPts	$secTag_C	$PDeltaTransf;	# Pier 2	
	
	
	
#定义梁单元
# element	nonlinearBeamColumn	3  18 38 $numIntgrPts	$secTag_B	$PDeltaTransf;
element	nonlinearBeamColumn	3  18 50 $numIntgrPts	$secTag_B	$PDeltaTransf;
element	nonlinearBeamColumn	5  50 38 $numIntgrPts	$secTag_B	$PDeltaTransf;

element	nonlinearBeamColumn	6  15 18 $numIntgrPts	$secTag_B	$PDeltaTransf;
element	nonlinearBeamColumn	7  35 38 $numIntgrPts	$secTag_B	$PDeltaTransf;
element	elasticBeamColumn	8  6 17  [expr $Abeam_23*3] $Es [expr $Ibeam_23*10] $PDeltaTransf;    # Channel 1
element	elasticBeamColumn	9  32 37  [expr $Abeam_23*3] $Es [expr $Ibeam_23*10] $PDeltaTransf;    # Channel 2
	

#定义节点刚臂梁单元
	set Apz  [expr $Acol_12*100];	# area of panel zone element (make much larger than A of frame elements)
	set Ipz  [expr $Icol_12*100];  # moment of intertia of panel zone element (make much larger than I of frame elements)
	# elemPanelZone2D eleID  nodeR E  A_PZ I_PZ transfTag
	elemPanelZone2D   10 1 $Es $Apz $Ipz $PDeltaTransf;	# Pier 1, Floor 2
	elemPanelZone2D   20 21 $Es $Apz $Ipz $PDeltaTransf;	# Pier 2, Floor 2
#定义节点旋转弹簧单元
	source rotPanelZone2D.tcl
	set Ry 1.2; 	# expected yield strength multiplier
	set as_PZ 0.01; # strain hardening of panel zones
#ElemID  ndR  ndC  E   Fy   dc       bf_c        tf_c       tp        db       Ry   as
	rotPanelZone2D 32 4 5 $Es $Fy $dcol_12 $bfcol_12 $tfcol_12 $twcol_12 $dbeam_23 $Ry $as_PZ;
	rotPanelZone2D 35 24 25 $Es $Fy $dcol_12 $bfcol_12 $tfcol_12 $twcol_12 $dbeam_23 $Ry $as_PZ;


#定义刚臂接触单元
element elasticBeamColumn    36    13 15    $Es $Apz $Ipz    $PDeltaTransf;
element elasticBeamColumn    37    15 16    $Es $Apz $Ipz    $PDeltaTransf;
element elasticBeamColumn    38    33 35    $Es $Apz $Ipz    $PDeltaTransf;
element elasticBeamColumn    39    35 36    $Es $Apz $Ipz    $PDeltaTransf;
	
#定义预应力筋单元
set ABfrp 7.4e2;
element truss 40 12 26 $ABfrp $matID_T1; 	
# element truss 40 6 32 $ABfrp $matID_T1; 	
	

#定义耗能器单元
element twoNodeLink 41 17 18 -mat $matID_D $matID_D -dir 1 2;
element twoNodeLink 42 37 38 -mat $matID_D $matID_D -dir 1 2;

	

# 定义梁柱仅受压接触单元

element zeroLength  43 4 13 -mat $matID_G1 -dir 1;
element zeroLength  45 7 16 -mat $matID_G1 -dir 1;
element zeroLength  46 33 21  -mat $matID_G1  -dir 1;
element zeroLength  47 36 30  -mat $matID_G1  -dir 1;



element zeroLength  48 4 13 -mat $matID_G2 -dir 1;
element zeroLength  49 7 16 -mat $matID_G2  -dir 1;
element zeroLength  50 33 21  -mat $matID_G2  -dir 1;
element zeroLength  51 36 30  -mat $matID_G2  -dir 1;

	
#定义填充墙单元
set Area 28336
element truss 52 42 41 $Area $matID_P; 
element truss 53 43 40 $Area $matID_P; 
element zeroLength  55 7 42 -mat $matID_Z1 $matID_Z1 $matID_Z2 -dir 1 2 3;
element zeroLength  56 41 2000  -mat $matID_Z1 $matID_Z1 $matID_Z2 -dir 1 2 3;
element zeroLength  57 40 1000  -mat $matID_Z1 $matID_Z1 $matID_Z2 -dir 1 2 3;
element zeroLength  58 30 43   -mat $matID_Z1 $matID_Z1 $matID_Z2 -dir 1 2 3;



# display the model with the node numbers
DisplayModel2D NodeNumbers;
	


############################################################################
#              Recorders					                			   
############################################################################
# record drift histories
	# record drifts
	recorder Drift -file $dataDir/Drift-Story1.out -time -iNode 1000 -jNode 6 -dof 1 -perpDirn 2;
	
# record floor displacements	
	recorder Node -file $dataDir/Disp.out -time -node 6 -dof 1 disp;
	
# record base shear reactions
	recorder Node -file $dataDir/Vbase.out -time -node 1000 2000 -dof 1 reaction;
	
# record story 1 column forces in global coordinates 
	recorder Element -file $dataDir/Fcol1.out -time -ele 1 force;
	recorder Element -file $dataDir/Fcol2.out -time -ele 2 force;
############################################################################
#              Pushover Analysis                			   			   #
############################################################################
# # display deformed shape:
	set ViewScale 5;
	DisplayModel2D DeformedShape $ViewScale ;	# display deformed shape, the scaling factor needs to be adjusted for each model


# set	dat1	0.005508021
# set	dat2	0.008128342
# set	dat3	0.010748663
# set	dat4	0.013208556
# set	dat5	0.01631016
# set	dat6	0.018823529
# set	dat7	0.021550802
# set	dat8	0.024278075
# set	dat9	0.027005348
# set	dat10	0.032352941

set	dat1	0.01
set	dat2	0.02
set	dat3	0.03
set	dat4	0.04
set	dat5	0.05
# set	dat6	0.06
# set	dat7	0.07
# set	dat8	0.08
# set	dat9	0.09
# set	dat10	0.10
source Display.tcl

puts "loads"
pattern Plain 1 Linear  {
load 50 1000 0 0
};
puts "analysis"
constraints Transformation;	
numberer Plain;
system BandGeneral;
test NormDispIncr 1.0e-6 200 0;
algorithm KrylovNewton;
integrator LoadControl 0.01;
analysis Static;
analyze 1;


set bm $HBuilding;
set iDmax "[expr $dat1*$bm]
          [expr $dat2*$bm]
          [expr $dat3*$bm]
          [expr $dat4*$bm]
          [expr $dat5*$bm]" ;

set IDctrlNode 50
set IDctrlDOF 1
puts "analysis"
source boxanalyze.Static.Cycle.tcl

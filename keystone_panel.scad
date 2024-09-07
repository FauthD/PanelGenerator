/*
	Modified by Dieter Fauth.
	Cleanups for some differences().
	Made hidden real Hidden.
	Add Epsilon.
*/

/*
 *  This is a cleaned up version of the keystone mounting jack by
 *  jsadusk on thingiverse.com.  I've changed it so you can make
 *  keystone patch panels with an arbitrary number of rows and columns.
 *
 *  I've also added some optional mounting brackets that will fit M5 
 *  screws.
 * 
 *  Shawn Wilson
 *  Aug 27, 2016
 */
 
/****************
 * Modify the settings below accordingly.  
 * 
 * For example, the following values will make a 16 port patch panel 
 * that can be mounted in a standard 19in rack:
 *
 *  num_jacks = 16;
 *  num_rows = 1;
 *  wall_thickness_x = 6.5625;
 *  wall_thickness_y = 6.5625;
 *  mounting_brackets = true;
 *
 ****************/

/* [Print] */
WhatToPrint = "panel"; // ["panel", "box", "mount", "cut"]

/* [Sizes] */
// Number of columns 
num_jacks = 4;
// Number of rows
num_rows = 2;

// Pad the height of each row (mm).  Industry standard is 6.5625.
height_padding = 6.5625;	//[6.0:0.01:40.0]

// Pad the spacing between each jack (mm).  Industry standard is 6.5625.
width_padding = 6.5625;	//[6.0:0.01:40.0]

// Specify if you want mounting holes on the sides.
mounting_brackets = true;
bracket_width = 15.0;	//[0.0:0.05:40.0]

// in mm
screw_hole_diameter = 5.5;	//[2.0:0.1:6.0]
screw_head_diameter = 9.0;	//[3.0:0.1:11.0]
screw_offset = 0.0;	// [-30.0:0.05:30.0]

num_mounting_screw_rows=2; // [1,2]

/* 
 *  The soffits are the overhangs that make the front of the faceplate
 *  look pretty.  However, leaving the soffits off can make it easier to
 *  pop the jack out from the front with a screwdriver.
 */
top_soffit = true;
bottom_soffit = true;
/***************/

EmulateFrame = false;
SlotWidth = 1.2;	
SlotDistance = 4.5;
SlotDept=4;

/* [Wall box] */
// Material thickness
BoxThickness = 1.8;
// How deep is the inner hole
BoxDept = 70;
// Make box smaller than panel
BoxInset = 7;

// Add a place to press the bubble level against. Cut it off after use.
BubbleLevelHelper = true;

/* [Hidden] */

module __Customizer_Limit__ () {}
		shown_by_customizer = false;

wall_thickness_x = height_padding;
wall_thickness_y = width_padding;


wall_height = 10;
jack_length = 20.5;
jack_width = 15;

catch_overhang = 2;
small_clip_depth = catch_overhang;
big_clip_depth = catch_overhang + 2;
big_clip_clearance = 1.7;
small_clip_clearance = 6.5;

outer_length = jack_length + big_clip_depth + (wall_thickness_x * 2);
outer_width = jack_width + (wall_thickness_y * 2);

total_outer_length = outer_length * num_rows;
total_outer_width = (outer_width * num_jacks) + (mounting_brackets ? 2*bracket_width : 0);
mount_hole_distance = (outer_width * num_jacks) + bracket_width + 2*screw_offset;

png=false;
$fa = png ? 1 : $preview ? 16 : 2;
$fs = png ? 0.5 : $preview ? 2 : 0.5;
Epsilon = 0.01;
epsilon = Epsilon;

include <./wallbox.scad>

module show_values()
{
	echo ("jack width:", outer_width, "jack length:", outer_length);
	echo ("total width:", total_outer_width, "total length", total_outer_length);
	echo ("distance between mounting holes:", mount_hole_distance);
}

/*
 *  This is the overhang that hides the clips so you can't see
 *  them from the front. 
 */
module clip_soffit(overhang = 2)
{
	rotate([90, 0, 0])
	{
		linear_extrude(height = outer_width)
		{
			polygon(points = [[0,0],
						[overhang, 0],
						[2 + overhang, 2],
						[0,2]],
						paths = [[0,1,2,3]]);
		}
	}
}

/* 
 *  This draws a single keystone module.
 */
module keystone()
{
	union()
	{
		difference()
		{
			difference()
			{
				cube([outer_length, outer_width, wall_height]);
				translate([wall_thickness_x, wall_thickness_y, big_clip_clearance])
					cube([outer_length, jack_width, wall_height]);
			}
			translate([wall_thickness_x + small_clip_depth, wall_thickness_y, -wall_height])
			{
				cube([jack_length, jack_width, 3*wall_height]);
			}
		}
	}

	cube([wall_thickness_x, outer_width, wall_height]);
	translate([outer_length - wall_thickness_x,0,0])
		cube([wall_thickness_x, outer_width, wall_height]);

	/* Draw the soffits if requested. */
	if (bottom_soffit)
	{
		translate([wall_thickness_x, outer_width, wall_height - 2])
			clip_soffit(overhang = 0);
	}
	if (top_soffit)
	{
		translate([outer_length - wall_thickness_x, 0, wall_height - 2])
			rotate([0, 0, -180])
				clip_soffit(overhang = 4);
	}
}

module mounting_bracket(length, width, screw_offset)
{
	cube([length, width, wall_height], center=true);
}

module mounting_bracket_hole(length, width, screw_offset)
{
	translate([0, screw_offset, 0])
	{
		cylinder(r = screw_hole_diameter / 2, h = 3*wall_height, center=true);
		translate([0,0,wall_height/2])
			cylinder(r = screw_head_diameter / 2, h = wall_height, center=true);
	}
}

module mounting_bracket_holes()
{
	// Draw the mounting holes
	if(num_mounting_screw_rows==1)
	{
		translate([total_outer_length/2, -1 * bracket_width + bracket_width/2, wall_height/2])
			mounting_bracket_hole(outer_length, bracket_width, -screw_offset);

		translate([total_outer_length/2, outer_width * num_jacks + bracket_width/2, wall_height/2]) 
			mounting_bracket_hole(outer_length, bracket_width, screw_offset);
	}
	else
	{
		for (j = [0 : num_mounting_screw_rows - 1] )
		{
			translate([j * outer_length + outer_length/2, -1 * bracket_width + bracket_width/2, wall_height/2])
				mounting_bracket_hole(outer_length, bracket_width, -screw_offset);

			translate([j * outer_length + outer_length/2, outer_width * num_jacks + bracket_width/2, wall_height/2]) 
				mounting_bracket_hole(outer_length, bracket_width, screw_offset);
		}
	}
}

module raw_panel()
{
		/* Draw the patch panel. */
	for (j = [0 : num_rows - 1] )
	{
		for (i = [0 : num_jacks - 1] )
		{
			translate([j * outer_length, i * outer_width, 0])
				keystone();
		}

		/* Add some mounting brackets if requested. */
		if (mounting_brackets)
		{
			translate([j * outer_length + outer_length/2, -1 * bracket_width + bracket_width/2, wall_height/2])
				mounting_bracket(outer_length, bracket_width, -screw_offset);

			translate([j * outer_length + outer_length/2, outer_width * num_jacks + bracket_width/2, wall_height/2]) 
				mounting_bracket(outer_length, bracket_width, screw_offset);
		}
	}
}

module panel()
{
	difference()
	{
		raw_panel();
		if (mounting_brackets)
		{
			mounting_bracket_holes();
		}
		
		if(EmulateFrame)
		{
			for (n=[1,-1])
			{
				with = total_outer_width-2*SlotDistance;
				translate([total_outer_length/2 + n*(total_outer_length/2-SlotDistance), with/2-bracket_width+SlotDistance+SlotWidth/4, wall_height-SlotDept/2])
					cube([SlotWidth, with+SlotWidth/2, SlotDept+Epsilon], center=true);
			}
			len = total_outer_length-2*SlotDistance+SlotWidth;
			translate([total_outer_length/2, -bracket_width+SlotWidth/2+SlotDistance-SlotWidth/2, wall_height-SlotDept/2])
				cube([len, SlotWidth, SlotDept+Epsilon], center=true);
			translate([total_outer_length/2, total_outer_width-bracket_width-SlotDistance, wall_height-SlotDept/2])
				cube([len, SlotWidth, SlotDept+Epsilon], center=true);
		}
	}
}

module mount()
{
	translate([-total_outer_length/2, -total_outer_width/2 + bracket_width, 0])
		print("panel");
	color("blue")
		translate([0,0, -BoxDept/2])
			print("box");
}

module cut()
{
	difference()
	{
		mount();
		translate([0,0,-BoxDept/2])
			cube([total_outer_length/2+Epsilon,total_outer_width/2+Epsilon, BoxDept ]);
	}
}

module print(what="panel")
{
	if(what == "panel")
	{
		panel();
	}
	else if(what == "box")
	{
		outer = [total_outer_length-2*BoxInset, total_outer_width-2*BoxInset, BoxDept];
		screws= [(num_mounting_screw_rows * outer_length - outer_length)/2, (outer_width * num_jacks + bracket_width)/2, screw_hole_diameter];
		box(outer=outer, thickness=BoxThickness, screws=screws);
	}
	else if(what == "mount")
	{
		mount();
	}
	else if(what == "cut")
	{
		cut();
	}
	show_values();
}

print(WhatToPrint);

/*
	Modified by Dieter Fauth.
	Cleanups for some differences().
	Made hidden real Hidden.
	Add Epsilon.
	Lots of other improvements.
	Changed the way a panel is setup so it fits to my needs.
	Drawback is that a std. 19" panel is a bit more difficuölt to create,
	but my panels are mucgh easier.
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

panel_length=80.0;
panel_width=130.0;

// in mm
screw_hole_diameter = 4.0;	//[2.0:0.1:6.0]
// Set head diamet to 0 for no screws
screw_head_diameter = 7.0;	//[0.0:0.1:11.0]
// screw_offset = 0.0;	// [-30.0:0.05:30.0]
screw_hole_width = 110;
screw_hole_lenght = 60;


/* 
 *  The soffits are the overhangs that make the front of the faceplate
 *  look pretty.  However, leaving the soffits off can make it easier to
 *  pop the jack out from the front with a screwdriver.
 */
top_soffit = true;
bottom_soffit = true;
/***************/

EmulateFrame = false;
SlotWidth = 1.1;	
SlotDistance = 4.5;
SlotDept=4;

/* [Wall box] */
// Material thickness
BoxThickness = 1.8;
// How deep is the inner hole
BoxDept = 70;
// Make box smaller than panel
BoxInsetLength = 1;

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
total_outer_width = (outer_width * num_jacks);

png=false;
$fa = png ? 1 : $preview ? 16 : 2;
$fs = png ? 0.5 : $preview ? 2 : 0.5;
Epsilon = 0.01;
epsilon = Epsilon;

include <./wallbox.scad>

module show_values()
{
	echo ("jack width:", outer_width, "jack length:", outer_length);
	echo ("total width:", panel_width, "total length", panel_length);
	echo ("distance between mounting holes:", screw_hole_width);
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

module mounting_bracket_hole(length, width, screw_offset)
{
	translate([0, screw_offset, 0])
	{
		cylinder(r = screw_hole_diameter / 2, h = 3*wall_height, center=true);
		translate([0,0,wall_height/2])
			cylinder(r = screw_head_diameter / 2, h = wall_height, center=true);
	}
}

module mounting_holes()
{
	// Draw the mounting holes
	for (j = [1,-1] )
	{
		for (i = [1,-1] )
		{
			translate([j*screw_hole_lenght/2, i*screw_hole_width/2, 0])
			{
				cylinder(r = screw_hole_diameter / 2, h = 3*wall_height, center=true);
				translate([0,0,wall_height])
					cylinder(r = screw_head_diameter / 2, h = wall_height, center=true);
			}
		}
	}
}

module raw_panel()
{
	// Draw the patch panel.
	difference()
	{
		translate([0, 0, wall_height/2])
			cube([panel_length, panel_width, wall_height], center=true);

		translate([-num_rows*outer_length/2, -num_jacks*outer_width/2, 0])
		{
			for (j = [0 : num_rows - 1] )
			{
				for (i = [0 : num_jacks - 1] )
				{
					translate([j * outer_length, i * outer_width, -wall_height])
						cube([outer_length+Epsilon, outer_width+Epsilon, 3*wall_height]);
				}
			}
		}
	}

	translate([-num_rows*outer_length/2, -num_jacks*outer_width/2, 0])
	{
		for (j = [0 : num_rows - 1] )
		{
			for (i = [0 : num_jacks - 1] )
			{
				translate([j * outer_length, i * outer_width, 0])
					keystone();
			}
		}
	}
}

module panel()
{
	difference()
	{
		raw_panel();

		if(screw_head_diameter>0)
			mounting_holes();

		if(EmulateFrame)
		{
			for (n=[1,-1])
			{
				translate([n*(panel_length/2-SlotDistance), 0, wall_height-SlotDept/2])
					cube([SlotWidth, panel_width-2*SlotDistance, SlotDept+Epsilon], center=true);
				translate([0, n*(panel_width/2-SlotDistance), wall_height-SlotDept/2])
					cube([panel_length-2*SlotDistance+SlotWidth, SlotWidth, SlotDept+Epsilon], center=true);
			}
		}
	}
}

module Stones()
{
	color("gray", 0.5)
	{
		translate([-num_rows*outer_length/2, -num_jacks*outer_width/2, 0])
		{
			x=21.5+2;
			y=15+2;
			z=32+2;
			for (j = [0 : num_rows - 1] )
			{
				for (i = [0 : num_jacks - 1] )
				{
					translate([x/2 + j * outer_length - 7, y/2 + i * outer_width - 3, -z+wall_height+Epsilon])
						cube([x,y,z], center=false);
				}
			}
		}
	}
}

module mount()
{
	print("panel");

	color("blue", 0.1)
		translate([0,0, -BoxDept/2])
			print("box");

	Stones();
}

module cut()
{
	difference()
	{
		mount();
		translate([0,0,-BoxDept/2])
			cube([panel_length/2+Epsilon, panel_width/2+Epsilon, BoxDept ]);
		translate([-panel_length/2, -panel_width/2,-BoxDept/2])
			cube([panel_length/2+Epsilon, panel_width/2+Epsilon, BoxDept ]);
	}
	Stones();
}

module print(what="panel")
{
	if(what == "panel")
	{
		panel();
	}
	else if(what == "box")
	{
		outer = [panel_length-2*BoxInsetLength, screw_hole_width+BoxThickness, BoxDept];
		screws= [screw_hole_lenght, screw_hole_width, screw_hole_diameter];
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

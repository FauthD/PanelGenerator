/*
	Modified by Dieter Fauth.
	Cleanups for some differences().
	Made hidden real Hidden.
	Add Epsilon.
	Lots of other improvements.
	Changed the way a panel is setup so it fits to my needs.
	Drawback is that a std. 19" panel is a bit more difficuölt to create,
	but my panels are much easier.
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
WhatToPrint = "panel"; // ["panel", "box", "cover", "mount", "cut"]

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

rounding = 1.0;	// [0.01:0.1:12.1]

// in mm
screw_hole_diameter = 4.0;	//[2.0:0.1:6.0]
// Set head diameter to 0 for no screws
screw_head_diameter = 7.0;	//[0.0:0.1:11.0]
screw_hole_width = 110;
screw_hole_lenght = 60;

// Allow for mounting tolereances
use_sloted_hole=true;
// You can use 45° with 4 holes if you want
sloted_angle=0;	// [0,45,90]
// calculate the slot lenght based on diameter
sloted_multiplier = 1.5;	// [1:0.25:5]

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
SlotDistance = 4.1;
SlotDept=4;

/* [Wall distance] */
wall_distance = 0.0; // [0.0:1:100]
wall_distance_thickness = 2.0; // [1:0.2:4]

/* [Cover] */
use_cover=false;
cover_space = 80.0; // [8.0:1:15.0]
cover_screws_width = 110;
cover_screws_length = 60;
cover_screws_diameter = 4.0;	//[2.0:0.1:6.0]
cover_screw_head_diameter = 7.5;	//[0.0:0.1:11.0]
cover_thickness = 2.0; // [1:0.2:4]

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
jack_length = 19.7; // was 20.5;
jack_width = 15;

catch_overhang = 2;
small_clip_depth = catch_overhang;
big_clip_depth = catch_overhang + 2;
big_clip_clearance = 1.6; // was 1.7;
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
use <./SlottedHole.scad>
use <./RoundCornersCube.scad>

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
				clip_soffit(overhang = 3.5);	// was 4
	}
}

module mounting_holes(h=wall_height)
{
	// Draw the mounting holes
	for (j = [1,-1] )
	{
		for (i = [1,-1] )
		{
			translate([j*screw_hole_lenght/2, i*screw_hole_width/2, 0])
			{
				if (use_sloted_hole)
				{
					rotate([0,0,j*i*sloted_angle])
					{
						SlottedHole(d = screw_hole_diameter, h = 3*h, length=sloted_multiplier*screw_hole_diameter);
						translate([0,0,h/2])
							SlottedHole(d = screw_head_diameter, h = h, length=sloted_multiplier*screw_hole_diameter);
					}
				}
				else
				{
					cylinder(d = screw_hole_diameter, h = 3*h, center=true);
					translate([0,0,h])
						cylinder(d = screw_head_diameter, h = h, center=true);
				}
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
			RoundCornersCube([panel_length, panel_width, wall_height], center=true, r=rounding);

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

	// Draw the keystone holders
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

	if(wall_distance > 0)
	{
		difference()
		{
			translate([0,0,-wall_distance/2])
				RoundCornersCube([panel_length, panel_width, wall_distance], center=true, r=rounding);
			translate([0,0,-wall_distance/2])
				RoundCornersCube([panel_length-2*cover_thickness, panel_width-2*cover_thickness, wall_distance+Epsilon], center=true, r=rounding);
		}

		// leads for the screws. Also reduces screw lenght.
		h=wall_distance;
		for (j = [1,-1] )
		{
			for (i = [1,-1] )
			{
				translate([j*screw_hole_lenght/2, i*screw_hole_width/2, -wall_distance])
				{
					if (use_sloted_hole)
					{
						l=1.5;
						rotate([0,0,j*i*sloted_angle])
						{
							SlottedHole(d = 2*screw_head_diameter, h = h, length=l*screw_head_diameter);
							offset=(panel_width-screw_hole_width)*1.414 - cover_thickness;
							translate([0, 0, h])
								cube([cover_thickness, offset, h/2], center=true);
						}
					}
					else
					{
						translate([0,0,h/2])
							cylinder(d = 2.5*screw_head_diameter, h = h, center=true);
					}
				}
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
			translate([0,0, wall_height-SlotDept/2+Epsilon])
			difference()
			{
				cube([panel_length-2*SlotDistance, panel_width-2*SlotDistance, SlotDept+Epsilon], center=true);
				RoundCornersCube([panel_length-2*SlotDistance-2*SlotWidth, panel_width-2*SlotDistance-2*SlotWidth, SlotDept], center=true, r=rounding);
			}
		}
		
		if(wall_distance > 0)
		{
			translate([0,0, -wall_distance-wall_height/2])
				mounting_holes(h=wall_distance);
		}
		
		if(use_cover)
		{
			h=cover_space+cover_thickness;
			for (j = [1,-1])
			{
				for (i = [1,-1])
				{
					translate([j*cover_screws_length/2, i*cover_screws_width/2, h/2])
						cylinder(d=cover_screws_diameter, h=3*h, center=true);
				}
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

module cover_raw(h)
{
	// Draw the cover.
	difference()
	{
		translate([0, 0, h/2])
			RoundCornersCube([panel_length, panel_width, h], center=true, r=rounding);

		translate([0, 0, h/2+cover_thickness])
			RoundCornersCube([panel_length-2*cover_thickness, panel_width-2*cover_thickness, h], center=true, r=rounding);
	}	
	for (j = [1,-1])
	{
		for (i = [1,-1])
		{
			translate([j*cover_screws_length/2, i*cover_screws_width/2, h/2])
				cylinder(d=2.5*cover_screw_head_diameter, h=h, center=true);
		}
	}
}

module cover()
{
	h=cover_space+cover_thickness;
	difference()
	{
		cover_raw(h);
		for (j = [1,-1])
		{
			for (i = [1,-1])
			{
				translate([j*cover_screws_length/2, i*cover_screws_width/2, h/2-2*cover_thickness])
					cylinder(d=cover_screw_head_diameter, h=h, center=true);
				translate([j*cover_screws_length/2, i*cover_screws_width/2, 0])
					cylinder(d=cover_screws_diameter, h=3*h, center=true);
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
	else if(what == "cover")
	{
		cover();
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

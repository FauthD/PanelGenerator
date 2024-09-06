
// Epsilon = 0.01;

module mounting_posts(screws, dept, thickness)
{
	screw_post=max(screws[2]*2.2, screws[2]+2*thickness);
	for (x=[screws[0], -screws[0]])
	{
		for (y=[screws[1], -screws[1]])
		{
			translate([x,y,0])
			{
				cylinder(d=screw_post, h=dept, center=true);
				translate([0,0, -dept+screw_post])
					sphere(d=screw_post);
			}
		}
	}
}

module mounting_post_holes(screws, dept, thickness)
{
	screw_hole=screws[2]-1;
	for (x=[screws[0], -screws[0]])
	{
		for (y=[screws[1], -screws[1]])
		{
			translate([x,y,0])
				cylinder(d=screw_hole, h=dept, center=true);
		}
	}
}

module ring(dia, wall, h)
{
	difference()
	{
		cylinder(d=dia, h=h, center=true);
		cylinder(d=dia-wall, h=3*h, center=true);
		cube([dia, wall, 3*h], center=true);
		cube([wall, dia, 3*h], center=true);
	}
}

module PipeHole(dia, h)
{
	holder=1;
	ring(dia, holder, h);
	// Note: The second smaller ring slows down the preview a lot
	// ring(dia/2, holder, h);
}

module body(outer, thickness, screws)
{
	inner = [outer.x-2*thickness, outer.y-2*thickness, outer.z];
	echo(outer);
	difference()
	{
		cube(size=outer, center=true);
		translate([0,0, thickness])
			cube(size=inner, center=true);
	}
	translate([0,0, 3*outer.z/8])
		mounting_posts(screws, outer.z/4, thickness);
}

PipeDiameter = 21.5;
PipeDistance = 1;
PipeOffset = 10;

module box(outer, thickness, screws)
{
	difference()
	{
		body(outer, thickness, screws);
		translate([0,0, outer.z/2])
			mounting_post_holes(screws, outer.z/2+Epsilon, thickness);
		
		// bottom
		for (w=[0, outer[1]/4, -outer[1]/4])
		{
			translate([0, w, -outer.z/4])
				PipeHole(PipeDiameter, outer.z/2);
		}
		// small side
		for (w=[outer[0]/4, -outer[0]/4])
		{
			translate([w, 0, 0])
			rotate([90,0,0])
				PipeHole(PipeDiameter, 3*outer[0]);
		}
		// long side
		if (outer[1] > 5*(PipeDiameter+PipeDistance) + 4*thickness)
		{
			for (w=[0, PipeDiameter+PipeDistance, -PipeDiameter-PipeDistance, 2*(PipeDiameter+PipeDistance), -2*(PipeDiameter+PipeDistance)])
			{
				translate([0, w, PipeOffset])
				rotate([90,0,90])
					PipeHole(PipeDiameter, 3*outer[0]);
			}
		}
		else if (outer[1] > 3*(PipeDiameter+PipeDistance) + 4*thickness)
		{
			for (w=[0, PipeDiameter+PipeDistance, -PipeDiameter-PipeDistance])
			{
				translate([0, w, PipeOffset])
				rotate([90,0,90])
					PipeHole(PipeDiameter, 3*outer[0]);
			}
		}
		else
		{
			for (w=[outer[1]/4, -outer[1]/4])
			{
				translate([0, w, PipeOffset])
				rotate([90,0,90])
					PipeHole(PipeDiameter, 3*outer[0]);
			}
		}
	}
}

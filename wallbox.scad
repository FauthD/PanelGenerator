
// Epsilon = 0.01;

module mounting_posts(screws, dept, thickness)
{
	screw_post=max(screws[2]*2.2, screws[2]+2*thickness);
	for (x=[screws[0]/2, -screws[0]/2])
	{
		for (y=[screws[1]/2, -screws[1]/2])
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
	screw_hole=screws[2]-1.5;
	for (x=[screws[0]/2, -screws[0]/2])
	{
		for (y=[screws[1]/2, -screws[1]/2])
		{
			translate([x,y, -dept/2+Epsilon])
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
		rotate([0,0,45])
		{
			cube([dia, wall, 3*h], center=true);
			cube([wall, dia, 3*h], center=true);
		}
	}
}

module PipeHole(dia, h)
{
	holder=2;
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

	// improve holding better in the gypsum
	translate([0,0, -outer[2]/2 + 0.5/2])
		cube([outer[0]+1, outer[1]+1, 0.5], center=true);

	// enforce
	if (outer[1] > 80)
	{
		for (n=[1,-1])
		{
			s1=5+thickness;
			s2=3;
			l=outer[2]/2-3;
			translate([n*(outer[0]/2 - s1/4), 0, -outer[2]/2+l/2])
				cube([s1, s2, l], center=true);
		}
	}
	if (BubbleLevelHelper)
	{
		h = 7;
		w = 4;
		for (n=[1,-1])
		{
			difference()
			{
				translate([w/2, n*(outer[1]/2-thickness/2), outer[2]/2+h/2])
					cube([w, thickness, h], center=true);
			}
		}
	}
}

PipeDiameter = 22.5;
PipeDistance = 1.0;
PipeOffset = 9.0;

module PipeHoles(lenght, width, thickness, rot)
{
	num = floor((lenght-PipeDiameter/2) / (PipeDiameter+PipeDistance + 3*thickness));
	offset = lenght - num * (PipeDiameter+PipeDistance);
	for (n=[-1,1])
	{
		for (w=[0:num])
		{
			if(rot[1]==0)
				translate([n*width/2, w * (PipeDiameter+PipeDistance) - lenght/2 + offset/2, PipeOffset])
					rotate(rot)
						PipeHole(PipeDiameter, 3*thickness);
			else
				translate([ w * (PipeDiameter+PipeDistance) - lenght/2 + offset/2, n*width/2, 0])
					rotate(rot)
						PipeHole(PipeDiameter, 3*thickness);
		}
	}
}

module box(outer, thickness, screws)
{
	difference()
	{
		body(outer, thickness, screws);
		translate([0,0, outer.z/2])
			mounting_post_holes(screws, outer.z/4, thickness);
		
		// bottom
		for (w=[0, outer[1]/4, -outer[1]/4])
		{
			translate([0, w, -outer.z/4])
				PipeHole(PipeDiameter, outer.z/2);
		}
		// small side
		PipeHoles(outer[0], outer[1], thickness, [90,90,0]);
		// long side
		PipeHoles(outer[1], outer[0], thickness, [90,0,90]);
	}
}

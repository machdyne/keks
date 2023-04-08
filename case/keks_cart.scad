/*
 * Keks Cartridge
 * Copyright (c) 2022 Lone Dynamics Corporation. All rights reserved.
 *
 * required hardware:
 *  - 1 x M3 x 12mm countersunk bolt
 *  - 1 x M3 nut
 *  - 1 x MMOD (https://github.com/machdyne/mmod)
 *
 */
 
$fn = 36;
 
cart_height = 26;
cart_width = 19.75;
cart_depth = 10;

notch_width = 4.5;
notch_depth = 2.5;

wall = 1.75;

catch_height = 2;
catch_depth_a = cart_depth - wall - 5.9;
catch_depth_b = 1.5;
catch_pos = 7.25;

lid_height = 1;
lid_insert_height = 9;

translate([0,0,28.5]) color([0.8,0,0])
	cart_lid();

cart();

//translate([0,0,-10])
//	mmod();

module mmod() {
	color([0,1,0])
		cube([16.5,2.5,12.5], center=true);
}

module cart_lid () {
	
	cube([cart_width-wall-1.45,cart_depth-wall-0.1,lid_height], center=true);
	
	difference() {
			
		translate([0,0,-5])
			cube([cart_width-wall-1.45,cart_depth-wall-0.1,lid_insert_height], center=true);
		
		translate([0,0,-16])
			cube([16.6,2.6,lid_insert_height+9], center=true);

		translate([0,-10,-5.5])
			rotate([0,90,90])
				cylinder(d=3.2, h=40);

	}
	
	rotate(0)
		translate([0,-1.25,0])
			linear_extrude(1)
				text("PONG", size=3, halign="center", font="Liberation Sans:style=Bold");

}

module cart() {

	difference() {
		
		union() {
	
			difference() {
		
				cube([cart_width,cart_depth,cart_height], center=true);
			
				translate([0,0,1])
					cube([cart_width-wall-1.35,cart_depth-wall,cart_height+wall+1], center=true);
			
				translate([0,-11,8])
					rotate([0,90,90])
						cylinder(d=5.6, h=40, $fn=36);
	
			}
	
			translate([0,(cart_depth/2)-(catch_depth_a/2)-(wall/2),-(cart_height/2)+(catch_height/2)+catch_pos])
				cube([cart_width, catch_depth_a, catch_height], center=true);

			translate([0,-(cart_depth/2)+(catch_depth_b/2)+(wall/2),-(cart_height/2)+(catch_height/2)+catch_pos])
				cube([cart_width, catch_depth_b, catch_height], center=true);
	
			translate([0,(cart_depth/2)+(notch_depth/2),0])
				cube([notch_width, notch_depth, cart_height], center=true);

			translate([0,(cart_depth/2)+(notch_depth/2),8])
				cube([cart_width, notch_depth, 10], center=true);
	
		}
	
		// nut holes
		translate([0,1,8])
				rotate([0,90,90])
					cylinder(d=7, h=50, $fn=6);
		
	}
	
}

// https://gist.github.com/tinkerology/ae257c5340a33ee2f149ff3ae97d9826
module roundedcube(xx, yy, height, radius)
{
    translate([0,0,height/2])
    hull()
    {
        translate([radius,radius,0])
        cylinder(height,radius,radius,true);

        translate([xx-radius,radius,0])
        cylinder(height,radius,radius,true);

        translate([xx-radius,yy-radius,0])
        cylinder(height,radius,radius,true);

        translate([radius,yy-radius,0])
        cylinder(height,radius,radius,true);
    }
}

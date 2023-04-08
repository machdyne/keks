/*
 * Keks Case
 * Copyright (c) 2022 Lone Dynamics Corporation. All rights reserved.
 *
 * required hardware:
 *  - 4 x M3 x 20mm countersunk bolts
 *  - 4 x M3 nuts
 *
 */

$fn = 100;

keks_text = true;

board_width = 80;
board_thickness = 1.5;
board_length = 80;
board_height = 20;
board_spacing = 2;

ldg_board();

translate([0,0,15])
	ldg_case_top();

translate([0,0,-15])
	ldg_case_bottom();

module ldg_board() {
	
	difference() {
		color([0,0.5,0])
			roundedcube(board_width,board_length,board_thickness,3);
		translate([5, 5, -1]) cylinder(d=3.2, h=10);
		translate([5, 75, -1]) cylinder(d=3.2, h=10);
		translate([75, 5, -1]) cylinder(d=3.2, h=10);
		translate([75, 75, -1]) cylinder(d=3.2, h=10);
	}	
	
}

module ldg_case_top() {

	union() {
	
		difference() {

			union () {
			
				color([0.5,0.5,0.5])
					roundedcube(board_width,board_length,13,3);

				translate([-1,27.5,8])
					cube([board_height+60+2,25,6]);
			
			}
	
			translate([1.5,2,-4.8])
				roundedcube(board_width-3,board_length-4,6,3);

			translate([1.5,10,-4])
				roundedcube(board_width-8,board_length-63.7,15,3);
			
			translate([10.5,2,-4])
				roundedcube(board_width-20.5,board_length-4,15,5);

			// LED vent
			translate([28+5,10,10])
				cube([2,10,20]);

			translate([28,10,10])
				cube([2,10,20]);

			translate([28-5,10,10])
				cube([2,10,20]);
			
			// FPGA vent
			translate([45,40-(10/2),10])
				cube([2,10,20]);

			translate([50,40-(10/2),10])
				cube([2,10,20]);

			translate([55,40-(10/2),10])
				cube([2,10,20]);

			// BUTTON
			translate([28.475-(18/2),66.225-(18/2)+0.25,-10]) cube([18,18,50]);
		
			// DDMI
			translate([65,29.05-(16/2),-2]) cube([40,15.5,6+2]);

			// USBC
			translate([65,60.75-(10.5/2)+0.25,-2]) cube([40,10-0.1,3.5+1.75]);

			// PMODA (CART)
			translate([28.4-(7/2)-1.5,40-(20/2),10]) cube([10.5,20,10]);
			translate([28.4-(7/2)+0.5,40-(5/2),10]) cube([11,5,10]);
		
			// PMODB
			translate([55.4-(16/2),75,-2]) cube([16,25,7+1]);
		
			// SD
			translate([26.3-(15/2),-2,-2]) cube([15,30,2+2]);

			// RCA
			translate([53.85-(32.5/2),-2,-3]) cube([32.5,30,13+1.5]);
			
			// USBA HOST
			translate([-2,20-(14.5/2),-0.5]) cube([30,14.5,7.5+1]);
			translate([-2,60-(14.5/2),-0.5]) cube([30,14.5,7.5+1]);
		
			// bolt holes
			translate([5, 5, -21]) cylinder(d=3.5, h=40);
			translate([5, 75, -21]) cylinder(d=3.5, h=40);
			translate([75, 5, -20]) cylinder(d=3.5, h=40);
			translate([75, 75, -21]) cylinder(d=3.5, h=40);

			// flush mount bolt holes
			translate([5, 5, 11.5]) cylinder(d=5.2, h=4);
			translate([5, 75, 11.5]) cylinder(d=5.2, h=4);
			translate([75, 5, 11.5]) cylinder(d=5.2, h=4);
			translate([75, 75, 11.5]) cylinder(d=5.2, h=4);


			// keks text
			if (keks_text) {
				rotate(270)
					translate([-40,10,13])
						linear_extrude(5)
							text("K  E  K  S", size=3.5, halign="center",
								font="Ubuntu:style=Bold");
			}

		}	
	
	}

}

module ldg_case_bottom() {
	
	difference() {
		color([0.5,0.5,0.5])
			roundedcube(board_width,board_length,6,3);
		
		translate([2,10,2])
			roundedcube(board_width-4,board_length-20,8,3);
				
		translate([10,2.5,2])
			roundedcube(board_width-20,board_length-5,8,3);

		// bolt holes
		translate([5, 5, -11]) cylinder(d=3.2, h=25);
		translate([5, 75, -11]) cylinder(d=3.2, h=25);
		translate([75, 5, -11]) cylinder(d=3.2, h=25);
		translate([75, 75, -11]) cylinder(d=3.2, h=25);

		// nut holes
		translate([5, 5, -1.5]) cylinder(d=7, h=4.5, $fn=6);
		translate([5, 75, -1.5]) cylinder(d=7, h=4.5, $fn=6);
		translate([75, 5, -1.5]) cylinder(d=7, h=4.5, $fn=6);
		translate([75, 75, -1.5]) cylinder(d=7, h=4.5, $fn=6);

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

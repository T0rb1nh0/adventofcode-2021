use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my $puzzle = File::Slurp::read_file('../Input/AoC_2021_D17.txt');

# Parse target area
$puzzle =~ m/x=((?:-)?\d+)..((?:-)?\d+),\sy=((?:-)?\d+)..((?:-)?\d+)/;
my ($min_x, $max_x, $min_y, $max_y) = ($1, $2, $3, $4);

say "The target are is for x from $min_x to $max_x and for y from $min_y to $max_y";

my $highest_y_total = 0;
my $total_working_tracks = 0;
foreach (my $x = 0; $x <= $max_x; ++$x) {
	foreach (my $y = $min_y - 1; $y <= abs($max_y) * 100; ++$y) {
		my ($x_velocity, $y_velocity, $x_position, $y_position, $steps, $highest_point) = ($x, $y, 0, 0, 0, 0);
		while (($x_velocity || $x_position >= $min_x) && $x_position <= $max_x && $y_position >= $min_y - 10) {
			++$steps;
			$x_position += $x_velocity;
			$y_position += $y_velocity;
			--$x_velocity if $x_velocity > 0;
			++$x_velocity if $x_velocity < 0;
			--$y_velocity;
			$highest_point = $y_position if $y_position > $highest_point;
			if ($x_position >= $min_x && $x_position <= $max_x && $y_position >= $min_y && $y_position <= $max_y) {
				say "Target area hit after $steps steps with initial velocity $x,$y. Highest point was $highest_point.";
				$highest_y_total = $highest_point if $highest_point > $highest_y_total;
				++$total_working_tracks;
				last;
			}
		}
	}
}

say "Highest point of all tracks which hit target area is at y=$highest_y_total";

say "Total number of potential working tracks: $total_working_tracks";
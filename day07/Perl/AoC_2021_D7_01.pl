use strict;
use warnings FATAL => 'all';

use File::Slurp;
use Data::Dumper;
use List::Util;

my $puzzle = File::Slurp::read_file('../Input/AoC_2021_D7.txt');

my $best_min_position = -1;
my $best_min_fuel = 99999999;

for (my $i = 0; $i < 1788; ++$i) {
	my $current_fuel = 0;
	foreach my $crab_position (split(/\D/, $puzzle)) {
		$current_fuel += abs($crab_position - $i);
	}
	if ($current_fuel < $best_min_fuel) {
		$best_min_position = $i;
		$best_min_fuel = $current_fuel;
	}
}

print "Best minimal position detected at slot $best_min_position with fuel usage of $best_min_fuel";
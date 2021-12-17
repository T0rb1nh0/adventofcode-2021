use strict;
#use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D11.txt');

my @octopusmap = [];
my $y = 0;
foreach my $line (@puzzle) {
	my $x = 0;
	foreach my $energylevel (split(//, $line)) {
		next unless $energylevel =~ m/^\d$/;
		$octopusmap[$x++][$y] = $energylevel;
	}
	++$y;
}

my $flash_counter = 0;
for (my $steps = 1; $steps <= 100; ++$steps) {
	for my $y (0 .. $#octopusmap) {
		for my $x (0 .. $#{$octopusmap[$y]}) {
			++$octopusmap[$y][$x];
		}
	}

	my $done;
	do {
		$done = 1;

		for my $y (0 .. $#octopusmap) {
			for my $x (0 .. $#{$octopusmap[$y]}) {
				if ($octopusmap[$y][$x] =~ /^\d+$/ && $octopusmap[$y][$x] > 9) {
					$octopusmap[$y][$x] = 'F';
					++$flash_counter;

					++$octopusmap[$y - 1][$x - 1] if $x > 0 && $y > 0;
					++$octopusmap[$y][$x - 1] if $x > 0;
					++$octopusmap[$y - 1][$x] if $y > 0;

					++$octopusmap[$y + 1][$x + 1] if $x < $#{$octopusmap[$y]} && $y < $#octopusmap;
					++$octopusmap[$y][$x + 1] if $x < $#{$octopusmap[$y]};
					++$octopusmap[$y + 1][$x] if $y < $#octopusmap;

					++$octopusmap[$y - 1][$x + 1] if $x < $#{$octopusmap[$y]} && $y > 0;
					++$octopusmap[$y + 1][$x - 1] if $x > 0 && $y < $#octopusmap;

					$done = 0;
				}
			}
		}
	} while (!$done);

	for my $y (0 .. $#octopusmap) {
		for my $x (0 .. $#{$octopusmap[$y]}) {
			$octopusmap[$y][$x] = 0 if $octopusmap[$y][$x] !~ /^\d+$/;
		}
	}

	#print_array(\@octopusmap);
}

say "Total amount of flashes: " . $flash_counter;

sub print_array {
	my ($arr_ref) = @_;
	my @arr = @$arr_ref;
	for my $y (0 .. $#arr) {
		for my $x (0 .. $#{$arr[$y]}) {
			print $arr[$y][$x];
		}
		print "\n";
	}
	print "\n";

}
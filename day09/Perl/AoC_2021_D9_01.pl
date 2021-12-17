use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D9.txt');

my @heightmap = [];
my $y = 0;
foreach my $line (@puzzle) {
	my $x = 0;
	foreach my $location (split(//, $line)) {
		next unless $location =~ m/^\d$/;
		$heightmap[$x++][$y] = $location;
	}
	++$y;
}

my $result = 0;
for my $y (0 .. $#heightmap) {
	for my $x (0 .. $#{$heightmap[$y]}) {
		next if $y > 0 && $heightmap[$y - 1][$x] <= $heightmap[$y][$x];
		next if $y < $#heightmap && $heightmap[$y + 1][$x] <= $heightmap[$y][$x];
		next if $x > 0 && $heightmap[$y][$x - 1] <= $heightmap[$y][$x];
		next if $x < $#{$heightmap[$y]} && $heightmap[$y][$x + 1] <= $heightmap[$y][$x];
		$result += 1 + $heightmap[$y][$x];
	}
}

say "Sum of low points:\t" . $result;
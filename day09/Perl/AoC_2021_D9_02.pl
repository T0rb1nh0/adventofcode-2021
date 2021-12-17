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
my @basin_sizes;
for my $y (0 .. $#heightmap) {
	for my $x (0 .. $#{$heightmap[$y]}) {
		my $already_checked = {};
		next if $y > 0 && $heightmap[$y - 1][$x] <= $heightmap[$y][$x];
		next if $y < $#heightmap && $heightmap[$y + 1][$x] <= $heightmap[$y][$x];
		next if $x > 0 && $heightmap[$y][$x - 1] <= $heightmap[$y][$x];
		next if $x < $#{$heightmap[$y]} && $heightmap[$y][$x + 1] <= $heightmap[$y][$x];
		$result += 1 + $heightmap[$y][$x];

		my $basin_size = 1;
		$already_checked->{$y}->{$x} = 1;

		$basin_size += check_basin_size_recursively($x, $y - 1, $already_checked, \@heightmap);
		$basin_size += check_basin_size_recursively($x, $y + 1, $already_checked, \@heightmap);
		$basin_size += check_basin_size_recursively($x - 1, $y, $already_checked, \@heightmap);
		$basin_size += check_basin_size_recursively($x + 1, $y, $already_checked, \@heightmap);

		push(@basin_sizes, $basin_size);
	}
}

sub check_basin_size_recursively {
	my ($x, $y, $already_checked, $heightmap) = @_;

	return 0 if $already_checked->{$y}->{$x};
	return 0 if $y < 0;
	return 0 if $y > $#heightmap;
	return 0 if $x < 0;
	return 0 if $x > $#{$heightmap[$y]};
	return 0 if $heightmap[$y][$x] == 9;

	$already_checked->{$y}->{$x} = 1;

	my $basin_size = 1;

	$basin_size += check_basin_size_recursively($x, $y - 1, $already_checked, $heightmap);
	$basin_size += check_basin_size_recursively($x, $y + 1, $already_checked, $heightmap);
	$basin_size += check_basin_size_recursively($x - 1, $y, $already_checked, $heightmap);
	$basin_size += check_basin_size_recursively($x + 1, $y, $already_checked, $heightmap);

	return $basin_size;
}

@basin_sizes = sort {$b <=> $a} @basin_sizes;

say "\n\nSum of low points:\t" . $result;
say "\nProduct of size of three biggest basins:\t" . ($basin_sizes[0] * $basin_sizes[1] * $basin_sizes[2]);
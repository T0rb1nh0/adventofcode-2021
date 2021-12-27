use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D22.txt');

my %global_map;
my $cubes_on_within_50 = 0;

foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;
	next unless $line =~ m/^(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/;

	my ($on, $minX, $maxX, $minY, $maxY, $minZ, $maxZ) = ($1 eq 'on', $2, $3, $4, $5, $6, $7);
	$minX = -50 if $minX < -50;
	$minY = -50 if $minY < -50;
	$minZ = -50 if $minZ < -50;
	$maxX = 50 if $maxX > 50;
	$maxY = 50 if $maxY > 50;
	$maxZ = 50 if $maxZ > 50;

	foreach my $x ($minX .. $maxX) {
		foreach my $y ($minY .. $maxY) {
			foreach my $z ($minZ .. $maxZ) {
				if ($on && !$global_map{$x}->{$y}->{$z}) {
					++$cubes_on_within_50;
					$global_map{$x}->{$y}->{$z} = 1;
				}
				elsif (!$on && $global_map{$x}->{$y}->{$z}) {
					--$cubes_on_within_50;
					$global_map{$x}->{$y}->{$z} = 0;
				}
			}
		}
	}
}

say "Number of cubes on within range of 50: " . $cubes_on_within_50;
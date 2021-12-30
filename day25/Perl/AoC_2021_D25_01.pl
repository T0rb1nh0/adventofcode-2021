use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;
use Storable qw(dclone);

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D25.txt');

my @map = [];
my $y = 0;
foreach my $line (@puzzle) {
	my $x = 0;
	foreach my $point (split(//, $line)) {
		next unless $point =~ m/^[\.\>v]$/;
		$map[$y][$x++] = $point;
	}
	++$y;
}

my $changed = 1;
my $steps = 0;
while (!$steps || $changed) {
	++$steps;
	$changed = 0;
	foreach my $axe (qw(x y)) {
		my @new_map = @{dclone(\@map)};
		for my $y (0 .. $#map) {
			for my $x (0 .. $#{$map[$y]}) {
				next if $map[$y][$x] ne '>' && $axe eq 'x';
				next if $map[$y][$x] ne 'v' && $axe eq 'y';
				my ($next_x, $next_y) = (($axe eq 'x' ? (($x + 1) % ($#{$map[$y]} + 1)) : $x), ($axe eq 'y' ? (($y + 1) % ($#map + 1)) : $y));
				next if $map[$next_y][$next_x] ne '.';
				$changed = 1;
				$new_map[$next_y][$next_x] = $map[$y][$x];
				$new_map[$y][$x] = '.';
			}
		}
		@map = @new_map;
	}
};

say "Done searching after $steps steps!";

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
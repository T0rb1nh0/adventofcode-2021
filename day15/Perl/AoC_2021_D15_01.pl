use strict;
use warnings FATAL => 'all';
no warnings 'recursion';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D15.txt');

my @map = [];
my $y = 0;
foreach my $line (@puzzle) {
	my $x = 0;
	foreach my $risklevel (split(//, $line)) {
		next unless $risklevel =~ m/^\d$/;
		$map[$y][$x++] = $risklevel;
	}
	++$y;
}

# Start point doesnt count. Risk doesnt matter
$map[0][0] = 0;

# Store map dimensions
my ($map_size_y, $map_size_x) = ($#map, $#{$map[0]});

say "Risk map:";
print_array(\@map);

# Initialize best total risk option with outer line
my $best_total_risk = 0;
for my $y (0 .. $#map) {
	$best_total_risk += $map[$y][0];
}
for my $x (0 .. $#{$map[$#map]}) {
	$best_total_risk += $map[$#map][$x];
}
say "Risk value of outer line being $best_total_risk";

my %already_been_there = ();
evaluate(0, 0, \%already_been_there, 0);

say "Risk value of best route with lowest risk being found: $best_total_risk";

sub evaluate {
	# Dont evaluate routes which risk is higher than what we already got
	return 0 if $best_total_risk && $best_total_risk <= $_[3] + $map[$_[0]][$_[1]] + $map_size_y - $_[0] + $map_size_x - $_[1];

	# End point reached? Return total effort
	if ($_[1] == $map_size_x && $_[0] == $map_size_y) {
		$best_total_risk = $_[3] + $map[$_[0]][$_[1]];
		say "New route with less risk found with total risk of $best_total_risk";
		return 1;
	}

	# Dont e the same spot twice
	my $key = "(" . $_[0] . "," . $_[1] . "," . $map[$_[0]][$_[1]] . ")";
	return -1 if $_[2]->{$key};
	$_[2]->{$key} = 1;

	# Evaluate nearby fields by chance in descending order
	my %nearbys = ();
	$nearbys{ $_[0] . "," . ($_[1] + 1) } = $map[$_[0]][$_[1] + 1] if $_[1] < $map_size_x;
	$nearbys{ ($_[0] + 1) . "," . $_[1] } = $map[$_[0] + 1][$_[1]] if $_[0] < $map_size_y;
	$nearbys{ ($_[0] - 1) . "," . $_[1] } = $map[$_[0] - 1][$_[1]] if $_[0] > 0;
	$nearbys{ $_[0] . "," . ($_[1] - 1) } = $map[$_[0]][$_[1] - 1] if $_[1] > 0;
	foreach $key (sort {$nearbys{$a} <=> $nearbys{$b}} (keys(%nearbys))) {
		my ($y, $x) = split(",", $key);
		evaluate($y, $x, $_[2], $_[3] + $map[$_[0]][$_[1]]);
	}

	# Allow the same spot to be visited again by other routes
	delete $_[2]->{$key};

	return 1;
}

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
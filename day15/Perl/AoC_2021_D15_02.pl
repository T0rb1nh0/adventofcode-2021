use strict;
use warnings FATAL => 'all';
no warnings 'recursion';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;
use Graph::Dijkstra;

my $graph = Graph::Dijkstra->new();

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D15.txt');

# Load risk map
my @riskmap = [];
my $y = 0;
foreach my $line (@puzzle) {
	my $x = 0;
	foreach my $risklevel (split(//, $line)) {
		next unless $risklevel =~ m/^\d$/;
		$riskmap[$y][$x++] = $risklevel;
	}
	++$y;
}

my @enriched_riskmap;
for (my $m = 0; $m < 5; ++$m) {
	for (my $n = 0; $n < 5; ++$n) {
		for my $y (0 .. $#riskmap) {
			for my $x (0 .. $#{$riskmap[$y]}) {
				$enriched_riskmap[$y + $m * ($#riskmap + 1)][$x + $n * ($#{$riskmap[$y]} + 1)] = ($riskmap[$y][$x] + $n + $m);
				$enriched_riskmap[$y + $m * ($#riskmap + 1)][$x + $n * ($#{$riskmap[$y]} + 1)] -= 9 while $enriched_riskmap[$y + $m * ($#riskmap + 1)][$x + $n * ($#{$riskmap[$y]} + 1)] > 9;
			}
		}
	}
}
@riskmap = @enriched_riskmap;

# Create related nodes accordingly
my @nodeidmap = [];
for my $y (0 .. $#riskmap) {
	for my $x (0 .. $#{$riskmap[$y]}) {
		my $nodeid = $y * ($#{$riskmap[$y]} + 1) + $x;
		$graph->node($nodeid, "");
		$nodeidmap[$y][$x] = $nodeid;
	}
}

# Create connections between nodes
for my $y (0 .. $#riskmap) {
	for my $x (0 .. $#{$riskmap[$y]}) {
		if ($y > 0) {
			$graph->edge($nodeidmap[$y - 1][$x], $nodeidmap[$y][$x], $riskmap[$y][$x]);
		}
		if ($x > 0) {
			$graph->edge($nodeidmap[$y][$x - 1], $nodeidmap[$y][$x], $riskmap[$y][$x]);
		}
		if ($y < $#riskmap) {
			$graph->edge($nodeidmap[$y + 1][$x], $nodeidmap[$y][$x], $riskmap[$y][$x]);
		}
		if ($x < $#{$riskmap[$y]}) {
			$graph->edge($nodeidmap[$y][$x + 1], $nodeidmap[$y][$x], $riskmap[$y][$x]);
		}
	}
}

# Calculate shortes path between start and end node
my %Solution = ();
if (my $pathCost = $graph->shortestPath(0, $nodeidmap[$#nodeidmap][$#{$nodeidmap[$y]}], \%Solution)) {
	say "Lowest risk between start and end node is " . $pathCost;
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
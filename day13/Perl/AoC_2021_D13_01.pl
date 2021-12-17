use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D13.txt');

my @map = [];
my @rules;

my ($max_x, $max_y) = (0, 0);
foreach my $line (@puzzle) {
	$line =~ s/^\s|\s$//gi;
	if ($line =~ m/^(\d+),(\d+)$/) {
		$map[$2][$1] = 1;
		$max_y = $2 if $2 > $max_y;
		$max_x = $1 if $1 > $max_x;
	}
	elsif ($line =~ m/(x|y)=(\d+)$/) {
		push(@rules, "$1,$2");
	}
}

for my $y (0 .. $max_y) {
	for my $x (0 .. $max_x) {
		$map[$y][$x] = 0 if !$map[$y][$x];
	}
}

foreach my $rule (@rules) {

	my $count_dots = 0;
	for my $y (0 .. $#map) {
		for my $x (0 .. $#{$map[$y]}) {
			++$count_dots if $map[$y][$x];
		}
	}

	my ($dimension, $line) = split(",", $rule);

	if ($dimension eq 'y') {
		for my $y ($line + 1 .. $#map) {
			last if $line - ($y - $line) < 0;
			for my $x (0 .. $#{$map[$y]}) {
				$map[$line - ($y - $line)][$x] = $map[$y][$x] if $map[$y][$x];
			}
		}
		$#map = $line - 1;
	}
	else {
		for my $y (0 .. $#map) {
			for my $x ($line + 1 .. $#{$map[$y]}) {
				last if $line - ($x - $line) < 0;
				$map[$y][$line - ($x - $line)] = $map[$y][$x] if $map[$y][$x];
			}
			$#{$map[$y]} = $line - 1;
		}
	}

	$count_dots = 0;
	for my $y (0 .. $#map) {
		for my $x (0 .. $#{$map[$y]}) {
			++$count_dots if $map[$y][$x];
		}
	}

	say " Dots counted after processing rule $rule : " . $count_dots;
}

say "Final map:\n";

print_array(\@map);

sub print_array {
	my ($arr_ref) = @_;
	my @arr = @$arr_ref;
	for my $y (0 .. $#arr) {
		for my $x (0 .. $#{$arr[$y]}) {
			print $arr[$y][$x] ? '#' : '.';
		}
		print "\n";
	}
	print "\n\n";
}
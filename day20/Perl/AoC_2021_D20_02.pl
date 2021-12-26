use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

$Data::Dumper::Sortkeys = 1;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D20.txt');

my @input_image;
my $image_enhancement_algorithm;
my $y = 0;
my $offset = 5;
# Load data from file
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	if (!$image_enhancement_algorithm) {
		$image_enhancement_algorithm = $line;
		next;
	}

	my $x = 0;
	foreach my $pixel (split(//, $line)) {
		next unless $pixel =~ m/^(?:\.|#)$/;
		$input_image[$y][$x++] = $pixel;
	}
	++$y;
}

print_array(\@input_image);

@input_image = process_image(\@input_image, 50);

my $ctr_lit_pixels = 0;
for my $y (0 .. $#input_image) {
	for my $x (0 .. $#{$input_image[$y]}) {
		++$ctr_lit_pixels if $input_image[$y][$x] eq '#';
	}
}

say "Number of lit pixels after two times processing the image:" . $ctr_lit_pixels;

sub process_image {
	my @input_image = @{$_[0]};

	foreach my $iteration (1 .. $_[1]) {
		my $outer_line_flag = $iteration % 2 ? '.' : "#";

		for my $y (0 .. $#input_image) {
			unshift(@{$input_image[$y]}, ($outer_line_flag));
			push(@{$input_image[$y]}, ($outer_line_flag));
		}
		unshift(@input_image, [ ($outer_line_flag) x (1 + $#{$input_image[0]}) ]);
		push(@input_image, [ ($outer_line_flag) x (1 + $#{$input_image[0]}) ]);

		my @output_image;

		for my $y (0 .. $#input_image) {
			for my $x (0 .. $#{$input_image[$y]}) {
				my $string = "";
				for my $m (-1 .. 1) {
					for my $n (-1 .. 1) {
						if ($y + $m < 0 || $y + $m > $#input_image) {
							$string .= $outer_line_flag;
						}
						elsif ($x + $n < 0 || $x + $n > $#{$input_image[$y + $m]}) {
							$string .= $outer_line_flag;
						}
						else {
							$string .= $input_image[$y + $m][$x + $n];
						}
					}
				}
				$string =~ s/\./0/gi;
				$string =~ s/\#/1/gi;
				$output_image[$y][$x] = substr($image_enhancement_algorithm, oct("0b" . $string), 1);
			}
		}

		print_array(\@output_image);

		@input_image = @output_image;
	}

	return @input_image;
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
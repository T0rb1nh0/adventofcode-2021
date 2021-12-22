use strict;
use warnings FATAL => 'all';
use feature 'say';
use POSIX;

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D18.txt');

my $current_number;
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//gi;
	next unless $line;

	#$line = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]";
	#$line = "[[[[[9,8],1],2],3],4]";
	#$line = "[7,[6,[5,[4,[3,2]]]]]";
	#$line = "[[6,[5,[4,[3,2]]]],1]";
	#$line = "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]";
	#$line = "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]";
	#$line = "[5,4]";

	say "Evaluation of number $line";

	# Add new line to existing number
	if ($current_number) {
		$current_number = "[" . $current_number . "," . $line . "]";
		say "Result of addition with current number: $current_number";
	}
	else {
		$current_number = $line;
	}

	# Reduce number
	my $number_reduced = 0;
	while (!$number_reduced) {
		$number_reduced = 1;
		my $level = 0;
		my $new_number;
		while ($current_number) {
			my $char = substr($current_number, 0, 1, '');

			++$level if $char eq '[';
			--$level if $char eq ']';

			# Explode number
			if ($level == 5) {
				$number_reduced = 0;

				$current_number =~ s/^(\d+),(\d+)]//;
				my ($left, $right) = ($1, $2);

				say "Detected exploding part between $new_number and $current_number with value [$left,$right]";

				if ($new_number =~ m/\d+/) {
					$new_number =~ s/(\d+)(\D+)$/($1 + $left) . $2/e;
				}
				else {
					$new_number .= "0";
				}
				if ($current_number =~ m/\d+/) {
					$current_number =~ s/^(\D+)(\d+)+/$1 . ($2 + $right)/e;
				}
				else {
					$current_number = "0" . $current_number;
				}

				$new_number = $new_number . $current_number;
				$new_number =~ s/,\]/,0\]/;
				$new_number =~ s/\[,/\[0,/;

				say "Reduced number with additions to the left and right: $new_number";

				last;
			}
			$new_number .= $char;
		}
		$current_number = $new_number;
		next if !$number_reduced;

		if ($current_number =~ m/(\d{2,})/) {
			$number_reduced = 0;

			say "Detected double digit number $1 in $current_number to be split.";

			my $replacement = "[" . floor($1 / 2) . "," . ceil($1 / 2) . "]";
			$current_number =~ s/$1/$replacement/;

			say "Reduced number with executed split: $current_number";

			next;
		}
	}
}

while ($current_number =~ m/\[(\d+),(\d+)\]/) {
	$current_number =~ s/\[(\d+),(\d+)\]/$1 * 3 + $2 * 2/eg;
}

say "Magnitude of last number is $current_number";
use strict;
use warnings FATAL => 'all';
use feature 'say';
use bigint;

use File::Slurp;
use Data::Dumper;
use List::Util;

my $puzzle = File::Slurp::read_file('../Input/AoC_2021_D16.txt');

say $puzzle;

my $bits = join "", map {sprintf("%.4b", hex('0x' . $_))} split //, $puzzle;

my $version_sum = 0;

my @numbers = ();
parse($bits, \@numbers);

sub parse {
	my ($bits, $numbers, $number_limit) = @_;

	while ($bits =~ m/1/) {
		return $bits if $number_limit && $number_limit == @$numbers;

		my $version = oct("0b" . substr($bits, 0, 3, ''));
		my $type_id = oct("0b" . substr($bits, 0, 3, ''));

		$version_sum += $version;

		say "New package with version value $version of type id $type_id detected.";

		if ($type_id == 4) {
			my $number;
			while ($bits =~ m/^(\d)(\d{4})/) {
				$number .= $2;
				substr($bits, 0, 5, '');
				last unless $1;
			}
			push(@$numbers, oct("0b" . $number));
			say "New literal number detected: " . $numbers->[-1];
		}
		else {
			# Get sub package numbers
			my @sub_numbers = ();
			my $lookup_strategy_by_number_limit = oct("0b" . substr($bits, 0, 1, ''));
			if ($lookup_strategy_by_number_limit) {
				my $sub_package_number_limit = oct("0b" . substr($bits, 0, 11, ''));
				$bits = parse($bits, \@sub_numbers, $sub_package_number_limit);
			}
			else {
				my $sub_package_bit_length = oct("0b" . substr($bits, 0, 15, ''));
				parse(substr($bits, 0, $sub_package_bit_length, ''), \@sub_numbers);
			}

			say "Detected sub numbers " . join(",", @sub_numbers) . " which are getting calculated with " . $type_id;
			if ($type_id == 0) {
				push(@$numbers, List::Util::sum(@sub_numbers));
			}
			elsif ($type_id == 1) {
				push(@$numbers, List::Util::product(@sub_numbers));
			}
			elsif ($type_id == 2) {
				push(@$numbers, List::Util::min(@sub_numbers));
			}
			elsif ($type_id == 3) {
				push(@$numbers, List::Util::max(@sub_numbers));
			}
			elsif ($type_id == 5) {
				push(@$numbers, $sub_numbers[0] > $sub_numbers[1] ? 1 : 0);
			}
			elsif ($type_id == 6) {
				push(@$numbers, $sub_numbers[0] < $sub_numbers[1] ? 1 : 0);
			}
			elsif ($type_id == 7) {
				push(@$numbers, $sub_numbers[0] == $sub_numbers[1] ? 1 : 0);
			}
			say "Result of calculation of numbers of sub packages (" . join(",", @sub_numbers) . ") with rule $type_id  is " . $numbers->[-1];
		}
	}
}

say "Sum of all versions: $version_sum";

say "Sum of all calculations: " . $numbers[0];
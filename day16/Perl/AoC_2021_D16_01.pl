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

parse($bits);

sub parse {
	my ($bits, $limit_hits, $numbers) = @_;

	my $hits = 0;
	while ($bits =~ m/1/) {
		return $bits if $limit_hits && $limit_hits == $hits;

		my $version = oct("0b" . substr($bits, 0, 3, ''));
		my $type_id = oct("0b" . substr($bits, 0, 3, ''));

		$version_sum += $version;

		say "New package detected with version $version and type id $type_id";

		if ($type_id == 4) {
			my $number;
			while ($bits =~ m/^(\d)(\d{4})/) {
				$number .= $2;
				substr($bits, 0, 5, '');
				last unless $1;
			}
			$number = oct("0b" . $number);
			push(@$numbers, $number);
			++$hits;
			say "Detected literal number: $number";
		}
		else {
			my $lookup_strategy_by_number_limit = oct("0b" . substr($bits, 0, 1, ''));
			if ($lookup_strategy_by_number_limit) {
				my $sub_ctr_limit = oct("0b" . substr($bits, 0, 11, ''));
				$bits = parse($bits, $sub_ctr_limit);
			}
			else {
				my $sub_bitlength = oct("0b" . substr($bits, 0, 15, ''));
				parse(substr($bits, 0, $sub_bitlength, ''));
			}
		}
	}
}

say "Sum of all version numbers: $version_sum";

exit;

#substr($message, 0, abs(((6 + $ctr * 5) % 4) - 4) % 4, '');
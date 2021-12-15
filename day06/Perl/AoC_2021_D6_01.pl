use strict;
use warnings FATAL => 'all';

use File::Slurp;
use Data::Dumper;
use List::Util;

my $puzzle = File::Slurp::read_file('../Input/AoC_2021_D6.txt');

my %lanternfish_by_age = ();

foreach my $lanternfish_age (split(/\D/, $puzzle)) {
	next unless $lanternfish_age;
	++$lanternfish_by_age{$lanternfish_age};
}

my $day = 0;

do {
	print "Fishes after day $day:\t" . List::Util::sum(values %lanternfish_by_age) . "\n";

	my %lanternfish_by_age_next_day = ();

	foreach my $lanternfish_age (keys %lanternfish_by_age) {
		if ($lanternfish_age > 0) {
			$lanternfish_by_age_next_day{$lanternfish_age - 1} += $lanternfish_by_age{$lanternfish_age};
		}
		else {
			$lanternfish_by_age_next_day{8} += $lanternfish_by_age{$lanternfish_age};
			$lanternfish_by_age_next_day{6} += $lanternfish_by_age{$lanternfish_age};
		}
	}
	%lanternfish_by_age = %lanternfish_by_age_next_day;
} while (++$day < 81);

print Data::Dumper::Dumper(\%lanternfish_by_age);


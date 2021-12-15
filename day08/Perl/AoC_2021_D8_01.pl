use strict;
use warnings FATAL => 'all';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D8.txt');

my $counter = 0;
foreach my $line (@puzzle) {
    my ($signal_pattern, $output_values) = split(/\|/, $line);
    foreach my $output_value (split(/\s/, $output_values)) {
        ++$counter if length($output_value) > 1 && length($output_value) < 5 || length($output_value) == 7;
    }
}

print "Number of times 1, 2, 4, 7 appears in output values:\t".$counter;
use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D14.txt');

my $template;
my %rules;
foreach my $line (@puzzle) {
	$line =~ s/^\s|\s$//gi;
	$template = $line if !$template && $line =~ m/^[A-Z]+$/;

	if ($line =~ m/^([A-Z]+)\s-\>\s([A-Z]+)$/) {
		$rules{$1} = $2;
	}
}

my %current_pairs;
my %counted_chars;

my $last_char;
while ($template) {
	my $char = substr($template, 0, 1);
	substr($template, 0, 1) = "";
	if ($last_char) {
		++$current_pairs{$last_char . $char};
	}
	$last_char = $char;
	++$counted_chars{$char};
}

for (my $i = 1; $i <= 40; ++$i) {
	my %new_pair_counts;
	foreach my $pair (keys(%current_pairs)) {
		next unless $current_pairs{$pair};
		if ($rules{$pair}) {
			my ($a, $b) = split("", $pair);
			$new_pair_counts{$a . $rules{$pair}} += $current_pairs{$pair};
			$new_pair_counts{$rules{$pair} . $b} += $current_pairs{$pair};
			$new_pair_counts{$pair} -= $current_pairs{$pair};
			$counted_chars{$rules{$pair}} += $current_pairs{$pair};
		}
	}
	foreach my $pair (keys(%new_pair_counts)) {
		$current_pairs{$pair} += $new_pair_counts{$pair};
		delete $current_pairs{$pair} unless $current_pairs{$pair};
	}
}

my ($min_char, $max_char) = (-1, -1);
foreach my $char (keys(%counted_chars)) {
	$min_char = $counted_chars{$char} if $min_char == -1 || $counted_chars{$char} < $min_char;
	$max_char = $counted_chars{$char} if $min_char == -1 || $counted_chars{$char} > $max_char;
}

say "Substract of max_char occourances to min_char occurances is " . ($max_char - $min_char);
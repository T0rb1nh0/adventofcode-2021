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

for (my $i = 1; $i < 11; ++$i) {
	my @chars = split(//, $template);

	my @result;
	my $last_char;
	foreach my $char (@chars) {
		if ($last_char && $rules{$last_char . $char}) {
			push(@result, $rules{$last_char . $char});
		}
		$last_char = $char;
		push(@result, $char);
	}

	$template = join("", @result);
}

my %count_chars;
my @chars = split(//, $template);
foreach my $char (@chars) {
	++$count_chars{$char};
}

my ($min_char, $max_char) = (99999999, 0);
foreach my $char (keys(%count_chars)) {
	$min_char = $count_chars{$char} if $count_chars{$char} < $min_char;
	$max_char = $count_chars{$char} if $count_chars{$char} > $max_char;
}

say "Substract of max_char occourances to min_char occurances is " . ($max_char - $min_char);
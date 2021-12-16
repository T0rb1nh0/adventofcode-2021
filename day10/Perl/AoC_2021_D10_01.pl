use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D10.txt');

my $syntax_error_score = 0;
foreach my $line (@puzzle) {
	$line =~ s/^\s|\s$//gi;
	my @chunks;
	foreach my $chunk (split(//, $line)) {
		next unless $chunk;
		if ($chunk eq '>' && $chunks[$#chunks] ne '<' || $chunk eq '}' && $chunks[$#chunks] ne '{' || $chunk eq ']' && $chunks[$#chunks] ne '[' || $chunk eq ')' && $chunks[$#chunks] ne '(') {
			say "Invalid chunk detected. Got $chunk but expected closing chunk of " . $chunks[$#chunks] . "\t (-- Full line $line  --)";
			$syntax_error_score += 3 if $chunk eq ')';
			$syntax_error_score += 57 if $chunk eq ']';
			$syntax_error_score += 1197 if $chunk eq '}';
			$syntax_error_score += 25137 if $chunk eq '>';
			@chunks = ();
			last;
		}
		if ($chunk eq '>' || $chunk eq ')' || $chunk eq ']' || $chunk eq '}') {
			pop(@chunks);
		}
		else {
			push(@chunks, $chunk);
		}
	}
	if (@chunks) {
		say "Incomplete valid line detected:\t" . $line;
	}
}

say "Final syntax error score is " . $syntax_error_score;
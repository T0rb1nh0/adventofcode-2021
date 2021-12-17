use strict;
use warnings FATAL => 'all';
use feature 'say';

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D10.txt');

my $syntax_error_score = 0;
my @incomplete_string_scores;
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
		my $total_score = 0;
		foreach my $chunk (reverse @chunks) {
			$total_score *= 5;
			$total_score += 1 if $chunk eq '(';
			$total_score += 2 if $chunk eq '[';
			$total_score += 3 if $chunk eq '{';
			$total_score += 4 if $chunk eq '<';
		}
		say "Incomplete valid line detected:\t" . $line."\t(-- ".join("",@chunks)." --)\t Total score: ".$total_score;

		push(@incomplete_string_scores, $total_score);
	}
}

say "Final syntax error score is " . $syntax_error_score;

@incomplete_string_scores = sort { $a <=> $b } @incomplete_string_scores;

while(@incomplete_string_scores > 1) {
    pop(@incomplete_string_scores);
    shift(@incomplete_string_scores);
}

print "Middle incompletioon string score:".$incomplete_string_scores[0];
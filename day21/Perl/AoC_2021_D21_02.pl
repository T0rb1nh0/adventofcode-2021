use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D21.txt');

my @player_wins = ();
my $max_score = 21;
my @player_positions = ();

foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	$line =~ m/(\d+)$/;
	push(@player_positions, $1);
}

my %factors = (
	3 => 1,
	4 => 3,
	5 => 6,
	6 => 7,
	7 => 6,
	8 => 3,
	9 => 1,
);

play(0, 0, 0, $player_positions[0], $player_positions[1], 1);

sub play {
	my ($player, $scoreA, $scoreB, $posA, $posB, $factor) = @_;

	for my $i (3 .. 9) {
		my $new_position = ((($i + ($player ? $posB : $posA)) - 1) % 10) + 1;
		if ($max_score <= ($new_position + ($player ? $scoreB : $scoreA))) {
			$player_wins[$player] += $factor * $factors{$i};
			next;
		}
		play(($player ? 0 : 1), ($player ? $scoreA : $scoreA + $new_position), ($player ? $scoreB + $new_position : $scoreB), ($player ? $posA : $new_position), ($player ? $new_position : $posB), $factor * $factors{$i});
	}
}

@player_wins = sort {$b <=> $a} @player_wins;

say "The player which wins more universes does this so many times: " . $player_wins[0];
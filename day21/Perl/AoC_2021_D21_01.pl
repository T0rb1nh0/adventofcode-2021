use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D21.txt');

my @player_positions = ();
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;

	$line =~ m/(\d+)$/;
	push(@player_positions, $1);
}

my $max_score = 1000;
my @player_scores;
my $rolled_dices = 0;
my $current_player = 0;
while (!grep {$_ > 999} @player_scores) {
	my $new_position = (($player_positions[$current_player] + ++$rolled_dices + ++$rolled_dices + ++$rolled_dices - 1) % 10) + 1;
	$player_positions[$current_player] = $new_position;
	$player_scores[$current_player] += $new_position;
	say "Player " . ($current_player + 1) . " moves from " . $player_positions[$current_player] . " to $new_position after $rolled_dices dices have been rolled which sets his score to be " . $player_scores[$current_player];
	$current_player = ++$current_player % ($#player_positions + 1);
}
say "Product of number of rolled dices with the score of the loser is " . ($rolled_dices * (grep {$_ < 1000} @player_scores)[0]);
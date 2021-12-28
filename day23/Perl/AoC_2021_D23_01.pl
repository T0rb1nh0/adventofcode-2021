use strict;
use warnings FATAL => 'all';
use feature "say";

use File::Slurp;
use Data::Dumper;
use List::Util;
use Storable qw(dclone);

my @puzzle = File::Slurp::read_file('../Input/AoC_2021_D23.txt');

my @board;
$board[0] = [ (".") x 11 ];
$board[1] = [ ("") x 11 ];
$board[2] = [ ("") x 11 ];

my $row = 1;
foreach my $line (@puzzle) {
	$line =~ s/^\s+|\s+$//g;
	next unless $line;
	next unless $line =~ m/#([ABCD])#([ABCD])#([ABCD])#([ABCD])#/;
	$board[$row][2] = $1;
	$board[$row][4] = $2;
	$board[$row][6] = $3;
	$board[$row++][8] = $4;
}

my %pits = (
	"A" => 2,
	"B" => 4,
	"C" => 6,
	"D" => 8,
);

my %energy = (
	"A" => 1,
	"B" => 10,
	"C" => 100,
	"D" => 1000,
);

my $best_result_overall = 0;

play(\@board, 0);

say "----------------------------------------------------------------------------------";
say "Lowest energylevel needed to solve this puzzle is " . $best_result_overall;

sub play {
	my ($board_aref, $energy) = @_;

	return 0 if $best_result_overall && $energy > $best_result_overall;

	print "Current best energy level: $best_result_overall\r";
	#print_board($board_aref);

	# Done? Lets return!
	if ($board_aref->[1][2] eq "A" && $board_aref->[2][2] eq "A" && $board_aref->[1][4] eq "B" && $board_aref->[2][4] eq "B" && $board_aref->[1][6] eq "C" && $board_aref->[2][6] eq "C" && $board_aref->[1][8] eq "D" && $board_aref->[2][8] eq "D") {

		$best_result_overall = $energy if !$best_result_overall || $energy < $best_result_overall;
		return $energy;
	}

	my @board = @{dclone($board_aref)};

	my $best_result = 0;

	for my $y (0 .. $#board) {
		for my $x (0 .. $#{$board[$y]}) {
			next unless $board[$y][$x] =~ m/^[ABCD]$/;

			# Being outside? Could just move home if possible
			if ($y == 0) {
				# Own pit is blocked by something else
				next if $board[1][$pits{$board[$y][$x]}] ne '.';
				next if $board[2][$pits{$board[$y][$x]}] ne '.' && $board[2][$pits{$board[$y][$x]}] ne $board[$y][$x];

				# Check if way to own pit is free
				my $e = 0;
				if ($x < $pits{$board[$y][$x]}) {
					for (my $m = $x + 1; $m <= $pits{$board[$y][$x]}; ++$m) {
						if ($board[$y][$m] ne '.') {
							$e = -1;
							last;
						}
						$e += $energy{$board[$y][$x]};
					}
				}
				else {
					for (my $m = $x - 1; $m >= $pits{$board[$y][$x]}; --$m) {
						if ($board[$y][$m] ne '.') {
							$e = -1;
							last;
						}
						$e += $energy{$board[$y][$x]};
					}
				}
				next if $e == -1;

				my @new_board = @{dclone(\@board)};

				# Move down in second tier
				if ($board[2][$pits{$board[$y][$x]}] eq '.') {
					$new_board[2][$pits{$board[$y][$x]}] = $board[$y][$x];
					$new_board[$y][$x] = ".";
					my $result = play(\@new_board, $energy + $e + $energy{$board[$y][$x]} * 2);
					$best_result = $result if $result > 0 && (!$best_result || $best_result > $result);
				}
				# Move down to first tier
				else {
					$new_board[1][$pits{$board[$y][$x]}] = $board[$y][$x];
					$new_board[$y][$x] = ".";
					my $result = play(\@new_board, $energy + $e + $energy{$board[$y][$x]});
					$best_result = $result if $result > 0 && (!$best_result || $best_result > $result);
				}
			}
			else {

				# Something in tier one in the way? Skip!
				if ($y == 2 && $board[1][$x] ne '.') {
					next;
				}

				# Already done!
				if ($x eq $pits{$board[$y][$x]} && ($y == 2 || $y == 1 && $board[2][$x] eq $board[$y][$x])) {
					next;
				}

				# Own pit empty // available? Jump directly!
				if ($x != $pits{$board[$y][$x]} && $board[1][$pits{$board[$y][$x]}] eq '.' && ($board[2][$pits{$board[$y][$x]}] eq '.' || $board[2][$pits{$board[$y][$x]}] eq $board[$y][$x])) {

					my $e = 0;
					if ($x < $pits{$board[$y][$x]}) {
						for (my $m = $x + 1; $m <= $pits{$board[$y][$x]}; ++$m) {
							if ($board[$y][$m] ne '.') {
								$e = -1;
								last;
							}
							$e += $energy{$board[$y][$x]};
						}
					}
					else {
						for (my $m = $x - 1; $m >= $pits{$board[$y][$x]}; --$m) {
							if ($board[$y][$m] ne '.') {
								$e = -1;
								last;
							}
							$e += $energy{$board[$y][$x]};
						}
					}

					if ($e > -1) {
						my @new_board = @{dclone(\@board)};

						# Move down in second tier
						if ($board[2][$pits{$board[$y][$x]}] eq '.') {
							$new_board[2][$pits{$board[$y][$x]}] = $board[$y][$x];
							$new_board[$y][$x] = ".";
							my $result = play(\@new_board, $energy + $e + $energy{$board[$y][$x]} * 2 + $energy{$board[$y][$x]} * $y);
							$best_result = $result if $result > 0 && (!$best_result || $best_result > $result);
						}
						# Move down to first tier
						else {
							$new_board[1][$pits{$board[$y][$x]}] = $board[$y][$x];
							$new_board[$y][$x] = ".";
							my $result = play(\@new_board, $energy + $e + $energy{$board[$y][$x]} + $energy{$board[$y][$x]} * $y);
							$best_result = $result if $result > 0 && (!$best_result || $best_result > $result);
						}
						next;
					}
				}

				# Move up to all possible places
				# Check if way to own pit is free
				my $e = 0;
				for (my $m = $x - 1; $m >= 0; --$m) {
					# Something in the way? Stop!
					last if $board[0][$m] ne '.';

					$e += $energy{$board[$y][$x]};

					# Dont stop before the pits
					next if $m =~ m/[2468]/;

					my @new_board = @{dclone(\@board)};

					$new_board[0][$m] = $board[$y][$x];
					$new_board[$y][$x] = ".";

					my $result = play(\@new_board, $energy + $e + $y * $energy{$new_board[0][$m]});
					$best_result = $result if $result > 0 && ($best_result || $best_result > $result);
				}

				$e = 0;
				for (my $m = $x + 1; $m <= 10; ++$m) {
					# Something in the way? Stop!
					last if $board[0][$m] ne '.';

					$e += $energy{$board[$y][$x]};

					# Dont stop before the pits
					next if $m =~ m/[2468]/;

					my @new_board = @{dclone(\@board)};

					$new_board[0][$m] = $board[$y][$x];
					$new_board[$y][$x] = ".";
					my $result = play(\@new_board, $energy + $e + $y * $energy{$new_board[0][$m]});
					$best_result = $result if $result > 0 && ($best_result || $best_result > $result);
				}
			}
		}
	}

	return $best_result;
}

sub print_board {
	my ($arr_ref) = @_;
	my @arr = @$arr_ref;
	say "\nCurrent board:";
	say "----------------------------------------------------------------------------------";
	for my $y (0 .. $#arr) {
		for my $x (0 .. $#{$arr[$y]}) {
			print "" . $arr[$y][$x] . "\t";
		}
		print "\n";
	}
	say "----------------------------------------------------------------------------------";
}
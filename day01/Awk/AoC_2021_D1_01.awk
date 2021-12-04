NR > 1 {if ($1 > prev) {counter = counter + 1}}  {prev = $1} END {print counter} 

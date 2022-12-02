play_scores = %{
  "A" => 1,
  "B" => 2,
  "C" => 3,
}

File.stream!("puzzle.txt")
|> Enum.reduce(0, fn play, my_score ->
  [_, my_outcome] = play = String.split(play)
  outcome_score =
    case my_outcome do
      "X" -> 0
      "Y" -> 3
      "Z" -> 6
    end

  my_play =
    case play do
      ["A", "X"] -> "C"
      ["A", "Y"] -> "A"
      ["A", "Z"] -> "B"
      ["B", "X"] -> "A"
      ["B", "Y"] -> "B"
      ["B", "Z"] -> "C"
      ["C", "X"] -> "B"
      ["C", "Y"] -> "C"
      ["C", "Z"] -> "A"
    end
  my_score + outcome_score + play_scores[my_play]
end)
|> IO.puts()


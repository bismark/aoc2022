play_scores = %{
  "X" => 1,
  "Y" => 2,
  "Z" => 3
}

File.stream!("puzzle.txt")
|> Enum.reduce(0, fn play, my_score ->
  play = String.split(play)
  outcome_score =
    case play do
      ["A", "X"] -> 3
      ["A", "Y"] -> 6
      ["A", "Z"] -> 0
      ["B", "X"] -> 0
      ["B", "Y"] -> 3
      ["B", "Z"] -> 6
      ["C", "X"] -> 6
      ["C", "Y"] -> 0
      ["C", "Z"] -> 3
    end
  [_, my_play] = play
  my_score + outcome_score + play_scores[my_play]
end)
|> IO.puts()

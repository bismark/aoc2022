lower_case = MapSet.new(?a..?z)
upper_case = MapSet.new(?A..?Z)

__DIR__
|> Path.join("puzzle.txt")
|> File.stream!()
|> Stream.map(& &1 |> String.trim() |> String.to_charlist() |> MapSet.new())
|> Stream.chunk_every(3)
|> Stream.map(fn chunk ->
  matching = Enum.reduce(chunk, & MapSet.intersection(&2, &1))
  lower = MapSet.intersection(lower_case, matching) |> Enum.map(& &1-96)
  upper = MapSet.intersection(upper_case, matching) |> Enum.map(& &1-38)
  Enum.sum(lower ++ upper)
end)
|> Enum.sum()
|> IO.puts()




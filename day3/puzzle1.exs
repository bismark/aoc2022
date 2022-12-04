lower_case = MapSet.new(?a..?z)
upper_case = MapSet.new(?A..?Z)

__DIR__
|> Path.join("puzzle.txt")
|> File.stream!()
|> Stream.map(fn s ->
  s = String.trim(s)
  {first, second} = String.split_at(s, div(String.length(s), 2))
  in_both = MapSet.intersection(
    MapSet.new(String.to_charlist(first)),
    MapSet.new(String.to_charlist(second))
  )
  lower = MapSet.intersection(lower_case, in_both) |> Enum.map(& &1-96)
  upper = MapSet.intersection(upper_case, in_both) |> Enum.map(& &1-38)
  Enum.sum(lower ++ upper)
end)
|> Enum.sum()
|> IO.puts()



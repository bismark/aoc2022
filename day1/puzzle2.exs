top3 = for _ <- 1..3, do: 0

File.stream!("puzzle.txt")
|> Stream.chunk_while(0, fn
  "\n", acc ->
    {:cont, acc, 0}
  num, acc ->
    {:cont, num |> String.trim() |> String.to_integer() |> Kernel.+(acc)}
end, fn acc ->
  {:cont, acc, 0}
end)
  |> Enum.reduce(top3, fn
    cals, [min | rest] when cals > min -> Enum.sort([cals | rest])
    _, top3 -> top3
  end)
|> Enum.sum()
|> IO.puts()

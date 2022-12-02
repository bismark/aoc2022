File.stream!("puzzle.txt")
|> Stream.chunk_while(0, fn
  "\n", acc ->
    {:cont, acc, 0}
  num, acc ->
    {:cont, num |> String.trim() |> String.to_integer() |> Kernel.+(acc)}
end, fn acc ->
  {:cont, acc, 0}
end)
|> Enum.max()
|> IO.puts()

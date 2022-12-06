import Bitwise

__DIR__
|> Path.join("puzzle.txt")
|> File.stream!()
|> Stream.filter(fn line ->
  line
  |> String.trim()
  |> String.split(",")
  |> Enum.map(fn range ->
    [s,e] = range |> String.split("-") |> Enum.map(& String.to_integer(&1))
    Integer.pow(2, e - s + 1) - 1 <<< (s - 1)
  end)
  |> Enum.reduce(fn int1, int2 ->
    (int1 &&& int2) != 0
  end)
end)
|> Enum.count()
|> IO.puts()

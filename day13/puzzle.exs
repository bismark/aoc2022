defmodule Puzzle do
  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Stream.chunk_every(3)
    |> Enum.map(fn [line1, line2 | _] ->
      {list1, "\n"} = start_parse_list(line1)
      {list2, "\n"} = start_parse_list(line2)
      {list1, list2}
    end)
  end

  defp start_parse_list("[" <> rest) do
    parse_list(rest, [])
  end

  defp parse_list("]" <> rest, acc) do
    {Enum.reverse(acc), rest}
  end

  defp parse_list("," <> rest, acc) do
    parse_list(rest, acc)
  end

  defp parse_list("[" <> _ = rest, acc) do
    {list, rest} = start_parse_list(rest)
    acc = [list | acc]

    case rest do
      "\n" -> Enum.reverse(acc)
      rest -> parse_list(rest, acc)
    end
  end

  defp parse_list(other, acc) do
    {number, rest} = parse_number(other, "")
    parse_list(rest, [number | acc])
  end

  defp parse_number("]" <> _ = rest, acc) do
    {String.to_integer(acc), rest}
  end

  defp parse_number("," <> _ = rest, acc) do
    {String.to_integer(acc), rest}
  end

  defp parse_number(<<digit::binary-size(1), rest::binary>>, acc) do
    parse_number(rest, acc <> digit)
  end

  def puzzle1(packets) do
    packets
    |> Enum.with_index(1)
    |> Enum.filter(fn {{left, right}, _} ->
      compare_packets(left, right)
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def puzzle2(packets) do
    packets = [[[2]], [[6]] | Enum.flat_map(packets, & Tuple.to_list(&1))]
    sorted = Enum.sort(packets, &compare_packets/2)
    (Enum.find_index(sorted, & &1 == [[2]]) + 1)
    *
    (Enum.find_index(sorted, & &1 == [[6]]) + 1)
  end

  defp compare_packets([], []), do: :cont
  defp compare_packets([], _), do: true
  defp compare_packets(_, []), do: false

  defp compare_packets([left | _], [right | _])
       when is_integer(left) and is_integer(right) and left < right,
       do: true

  defp compare_packets([left | _], [right | _])
       when is_integer(left) and is_integer(right) and left > right,
       do: false

  defp compare_packets([same | left], [same | right]) when is_integer(same) do
    compare_packets(left, right)
  end

  defp compare_packets([left | left_rem], [right | _] = right_rem)
       when is_integer(left) and is_list(right) do
    compare_packets([[left] | left_rem], right_rem)
  end

  defp compare_packets([left | _] = left_rem, [right | right_rem])
       when is_list(left) and is_integer(right) do
    compare_packets(left_rem, [[right] | right_rem])
  end

  defp compare_packets([left | left_rem], [right | right_rem])
       when is_list(left) and is_list(right) do
    with :cont <- compare_packets(left, right) do
      compare_packets(left_rem, right_rem)
    end
  end
end

13 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle1()

Puzzle.parse() |> Puzzle.puzzle1() |> IO.puts()

140 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle2()

Puzzle.parse() |> Puzzle.puzzle2() |> IO.puts()

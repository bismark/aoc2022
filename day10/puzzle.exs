defmodule Puzzle do
  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Stream.map(fn
      "noop" <> _ ->
        {:noop, 1}

      "addx " <> num ->
        {{:addx, num |> String.trim() |> String.to_integer()}, 2}
    end)
    |> Enum.to_list()
  end

  def puzzle1(instructions, samples_to_make \\ 20..220//40) do
    x = 1
    cycle = 1
    run_sample(x, cycle, instructions, samples_to_make)
    |> elem(1)
    |> Enum.map(fn {k, v} -> k * v end)
    |> Enum.sum()
  end

  defp run_sample(x, cycle, instructions, samples_to_make, samples \\ %{})

  defp run_sample(x, _cycle, [], _samples_to_make, samples), do: {x, samples}

  defp run_sample(x, cycle, [next|rem], samples_to_make, samples) do
    samples =
      if cycle in samples_to_make do
        Map.put(samples, cycle, x)
      else
        samples
      end

    case next do
      {:noop, 1} -> run_sample(x, cycle + 1, rem, samples_to_make, samples)
      {{:addx, to_add}, 1} -> run_sample(x + to_add, cycle + 1, rem, samples_to_make, samples)
      {inst, 2} -> run_sample(x, cycle + 1, [{inst, 1}|rem], samples_to_make, samples)
    end
  end

  def puzzle2(instructions) do
    x = 0..2
    cycle = 0
    run_crt(x, cycle, instructions)
    |> Enum.chunk_every(40)
    |> Enum.reverse()
    |> Enum.map(fn line ->
      line |> Enum.reverse() |> to_string
    end)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end


  defp run_crt(sprite, cycle, instructions, pixels \\ [])

  defp run_crt(_sprite, _cycle, [], pixels), do: pixels

  defp run_crt(sprite, cycle, [next|rem], pixels) do
    pixels = [get_pixel(sprite, cycle)|pixels]

    case next do
      {:noop, 1} -> run_crt(sprite, cycle + 1, rem, pixels)
      {{:addx, to_add}, 1} -> run_crt(Range.shift(sprite, to_add), cycle + 1, rem, pixels)
      {inst, 2} -> run_crt(sprite, cycle + 1, [{inst, 1}|rem], pixels)
    end
  end

  defp get_pixel(sprite, cycle),
    do: if Integer.mod(cycle, 40) in sprite, do: ?#, else: ?.

end

13140 = Puzzle.parse("puzzle_demo2.txt") |> Puzzle.puzzle1()
Puzzle.parse() |> Puzzle.puzzle1() |> IO.puts

"""
##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
""" = Puzzle.parse("puzzle_demo2.txt") |> Puzzle.puzzle2()

Puzzle.parse() |> Puzzle.puzzle2() |> IO.puts()

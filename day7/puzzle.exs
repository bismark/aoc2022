defmodule Puzzle do
  def parse_files(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Enum.reduce({[], %{}}, fn
      "$ cd ..\n", {[_|path], files} ->
        {path, files}
      "$ cd " <> dir, {path, files} ->
        dir = String.trim(dir)
        path = [dir | path]
        files = Map.put_new(files, path, 0)
        {path, files}
      "$ ls" <> _, acc ->
        acc
      "dir " <> _dir, acc ->
        acc
      file, {path, files} ->
        size = file |> String.split() |> hd |> String.to_integer()
        files = iterate_path(path, files, fn path, files ->
          Map.update!(files, path, &size + &1)
        end)
        {path, files}
    end)
    |> elem(1)
  end

  def part1(files) do
    files
    |> Map.filter(fn {_, val} ->
      val < 100000
    end)
    |> Map.values()
    |> Enum.sum()
    |> IO.puts()
  end

  @available 70000000
  @needed 30000000

  def part2(files) do
    total = Map.fetch!(files, ["/"])
    current_free = @available - total
    to_free = @needed - current_free

    files
    |> Enum.filter(fn
      {_, size} when size > to_free -> true
      _ -> false
    end)
    |> Enum.sort_by(& elem(&1, 1))
    |> hd()
    |> elem(1)
    |> IO.puts()
  end

  defp iterate_path([], acc, _fun), do: acc

  defp iterate_path(path, acc, fun) do
    acc = fun.(path, acc)
    iterate_path(tl(path), acc, fun)
  end
end

#Puzzle.parse_files("puzzle_demo.txt")
Puzzle.parse_files()
|> Puzzle.part2()

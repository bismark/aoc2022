defmodule Puzzle do

  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Stream.flat_map(fn <<dir>> <> " " <> num ->
      dir =
        case dir do
          ?R -> :right
          ?U -> :up
          ?L -> :left
          ?D -> :down
        end
      for _ <- 0..(String.to_integer(String.trim(num)) - 1), do: dir
    end)
    |> Enum.into([])
  end

  def part1(moves) do
    run_moves(moves, [{0,0}, {0,0}], MapSet.new())
    |> MapSet.size()
  end

  def part2(moves) do
    run_moves(moves, for(_ <- 0..9, do: {0,0}), MapSet.new())
    |> MapSet.size()
  end

  defp run_moves([], pos, visited) do
    MapSet.put(visited, List.last(pos))
  end

  defp run_moves([move|moves], pos, visited) do
    visited = MapSet.put(visited, List.last(pos))
    [h_pos|pos] = pos
    h_pos = run_move(move, h_pos)

    pos = Enum.scan([h_pos|pos], fn t_pos, pre_pos ->
      react(pre_pos, t_pos)
    end)

    run_moves(moves, pos, visited)
  end

  defp run_move(:right, {row, column}), do: {row, column + 1}
  defp run_move(:left, {row, column}), do: {row, column - 1}
  defp run_move(:down, {row, column}), do: {row - 1, column}
  defp run_move(:up, {row, column}), do: {row + 1, column}

  defp react(same, same), do: same
  defp react({h_row, col}, {t_row, col} = same) when abs(h_row - t_row) <= 1, do: same
  defp react({h_row, col}, {t_row, col}) when h_row - t_row > 1, do: {t_row + 1, col}
  defp react({h_row, col}, {t_row, col}) when h_row - t_row < -1, do: {t_row - 1, col}
  defp react({row, h_col}, {row, t_col} = same) when abs(h_col - t_col) <= 1, do: same
  defp react({row, h_col}, {row, t_col}) when h_col - t_col > 1, do: {row, t_col + 1}
  defp react({row, h_col}, {row, t_col}) when h_col - t_col < -1, do: {row, t_col - 1}
  defp react({h_row, h_col}, {t_row, t_col} = same) when abs(h_col - t_col) == 1 and abs(h_row - t_row) == 1, do: same
  defp react({h_row, h_col}, {t_row, t_col}) when h_row > t_row and h_col > t_col, do: {t_row + 1, t_col + 1}
  defp react({h_row, h_col}, {t_row, t_col}) when h_row > t_row and h_col < t_col, do: {t_row + 1, t_col - 1}
  defp react({h_row, h_col}, {t_row, t_col}) when h_row < t_row and h_col > t_col, do: {t_row - 1, t_col + 1}
  defp react({h_row, h_col}, {t_row, t_col}) when h_row < t_row and h_col < t_col, do: {t_row - 1, t_col - 1}

end

13 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.part1()
1 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.part2()
36 = Puzzle.parse("puzzle_demo2.txt") |> Puzzle.part2()


Puzzle.parse() |> Puzzle.part1() |> IO.puts()
Puzzle.parse() |> Puzzle.part2() |> IO.puts()


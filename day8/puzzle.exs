defmodule Puzzle.Guards do
  defguard is_taller(height, coords, trees) when height > elem(elem(trees, elem(coords, 0)), elem(coords, 1))
end

defmodule Puzzle do
  import Puzzle.Guards

  def parse(file \\ "puzzle.txt") do
    __DIR__
    |> Path.join(file)
    |> File.stream!()
    |> Stream.map(fn line ->
      line |> String.trim() |> :binary.bin_to_list() |> Enum.map(& &1 - 48) |>  List.to_tuple()
    end)
    |> Enum.into([])
    |> List.to_tuple()
  end

  def find_visible_count(trees) do
    row_size = tuple_size(trees)
    num_trees = row_size * row_size
    Enum.count(0..(num_trees - 1), fn tree -> tree_visible?(tree, trees) end)
  end

  def tree_visible?(tree, trees) do
    coords = tree_to_coord(tree, trees)
    height = height(coords, trees)
    visible_up?(height, dec_row(coords), trees) ||
    visible_down?(height, inc_row(coords), trees) ||
    visible_left?(height, dec_column(coords), trees) ||
    visible_right?(height, inc_column(coords), trees)
  end

  def find_max_scenic_score(trees) do
    row_size = tuple_size(trees)
    num_trees = row_size * row_size
    Enum.map(0..(num_trees - 1), fn tree ->
      tree_score(tree, trees)
    end)
    |> Enum.max()
  end

  def tree_score(tree, trees) do
    coords = tree_to_coord(tree, trees)
    height = height(coords, trees)
    score_up(height, dec_row(coords), trees) *
    score_down(height, inc_row(coords), trees) *
    score_left(height, dec_column(coords), trees) *
    score_right(height, inc_column(coords), trees)
  end

  defp height({row, column}, trees) do
    trees |> elem(row) |> elem(column)
  end

  defp dec_row({row, column}), do: {row - 1, column}
  defp inc_row({row, column}), do: {row + 1, column}
  defp dec_column({row, column}), do: {row, column - 1}
  defp inc_column({row, column}), do: {row, column + 1}

  defp visible_up?(_height, {-1, _column}, _trees),  do: true
  defp visible_up?(height, coords, trees) when is_taller(height, coords, trees), do: visible_up?(height, dec_row(coords), trees)
  defp visible_up?(_height, _coords, _trees) , do: false

  defp visible_down?(_height, {row, _column}, trees) when row == tuple_size(trees),  do: true
  defp visible_down?(height, coords, trees) when is_taller(height, coords, trees), do: visible_down?(height, inc_row(coords), trees)
  defp visible_down?(_height, _coords, _trees) , do: false

  defp visible_left?(_height, {_row, -1}, _trees),  do: true
  defp visible_left?(height, coords, trees) when is_taller(height, coords, trees), do: visible_left?(height, dec_column(coords), trees)
  defp visible_left?(_height, _coords, _trees) , do: false

  defp visible_right?(_height, {_row, column}, trees) when column == tuple_size(trees), do: true
  defp visible_right?(height, coords, trees) when is_taller(height, coords, trees), do: visible_right?(height, inc_column(coords), trees)
  defp visible_right?(_height, _coords, _trees),  do: false

  defp score_up(height, coords, trees, score \\ 0)
  defp score_up(_height, {-1, _column}, _trees, score), do: score
  defp score_up(height, coords, trees, score) when is_taller(height, coords, trees), do: score_up(height, dec_row(coords), trees, score + 1)
  defp score_up(_height, _coords, _trees, score), do: score + 1

  defp score_down(height, coords, trees, score \\ 0)
  defp score_down(_height, {row, _column}, trees, score) when row == tuple_size(trees), do: score
  defp score_down(height, coords, trees, score) when is_taller(height, coords, trees), do: score_down(height, inc_row(coords), trees, score + 1)
  defp score_down(_height, _coords, _trees, score), do: score + 1

  defp score_left(height, coords, trees, score \\ 0)
  defp score_left(_height, {_row, -1}, _trees, score), do: score
  defp score_left(height, coords, trees, score) when is_taller(height, coords, trees), do: score_left(height, dec_column(coords), trees, score + 1)
  defp score_left(_height, _coords, _trees, score), do: score + 1

  defp score_right(height, coords, trees, score \\ 0)
  defp score_right(_height, {_row, column}, trees, score) when column == tuple_size(trees), do: score
  defp score_right(height, coords, trees, score) when is_taller(height, coords, trees), do: score_right(height, inc_column(coords), trees, score + 1)
  defp score_right(_height, _coords, _trees, score), do: score + 1

  def tree_to_coord(tree, trees) do
    row_size = tuple_size(trees)
    row = div(tree, row_size)
    column = Integer.mod(tree, row_size)
    {row, column}
  end

end

trees = Puzzle.parse("puzzle.txt")
#Puzzle.tree_visible?(16, trees) |> IO.inspect()
#4 = Puzzle.tree_score(7, trees) |> IO.inspect()
#8 = Puzzle.tree_score(17, trees) |> IO.inspect()

Puzzle.find_visible_count(trees) |> IO.puts()
Puzzle.find_max_scenic_score(trees) |> IO.puts()


defmodule Puzzle do
  def parse(path \\ "puzzle.txt") do
      __DIR__
      |> Path.join(path)
      |> File.stream!()
      |> Stream.map(fn line ->
        line |> String.trim() |> :binary.bin_to_list() |> List.to_tuple()
      end)
      |> Enum.into([])
      |> List.to_tuple()
  end


  defp find_start_end(map) do
    start_pos = find(map, ?S)
    end_pos = find(map, ?E)

    map =
      map
      |> update_map(start_pos, ?a)
      |> update_map(end_pos, ?z)
    {map, start_pos, end_pos}
  end

  defp update_map(map, {row, col}, val) do
    put_elem(map, row, map |> elem(row) |> put_elem(col, val))
  end


  defp find(map, char) do
    columns = (map |> elem(0) |> tuple_size()) - 1
    rows = tuple_size(map) - 1

    Enum.find_value(0..rows, fn row ->
      Enum.find_value(0..columns, fn column ->
        if map |> elem(row) |> elem(column) == char do
          {row, column}
        end
      end)
    end)
  end

  defp find_all(map, char) do
    columns = (map |> elem(0) |> tuple_size()) - 1
    rows = tuple_size(map) - 1

    Enum.reduce(0..rows, [], fn row, acc ->
      Enum.reduce(0..columns, acc, fn column, acc ->
        if map |> elem(row) |> elem(column) == char do
          [{row, column}|acc]
        else
          acc
        end
      end)
    end)
  end

  def puzzle1(map) do
    {map, start_pos, end_pos} = find_start_end(map)
    dijkstras(map, start_pos, end_pos)
  end

  def puzzle2(map) do
    {map, _, end_pos} = find_start_end(map)
    start_pos = find_all(map, ?a)

    Enum.map(start_pos, fn start_pos ->
      dijkstras(map, start_pos, end_pos)
    end)
    |> Enum.reject(& &1 == :no_path)
    |> Enum.min
  end

  def dijkstras(map, start_pos, end_pos) do
    visited = %{start_pos => nil}
    set = :gb_sets.new()
    set = :gb_sets.add_element({0, start_pos}, set)

    do_dijkstras(map, set, visited, end_pos)
    |> then(fn visited ->
      if Map.has_key?(visited, end_pos) do
        visited
        |> get_path(end_pos)
        |> length
      else
        :no_path
      end
    end)
  end

  defp do_dijkstras(map, set, visited, end_pos) do
    {{distance, pos}, set} = :gb_sets.take_smallest(set)

    traversable = traversable(map, pos)
    Enum.reduce(traversable, {set, visited}, fn to_pos, {set, visited} ->
      if Map.has_key?(visited, to_pos) do
        {set, visited}

      else
        visited = Map.put(visited, to_pos, pos)
        set = :gb_sets.add_element({distance + 1, to_pos}, set)
        {set, visited}
      end
    end)
    |> then(fn {set, visited} ->
      if :gb_sets.size(set) == 0 do
        visited
      else
        do_dijkstras(map, set, visited, end_pos)
      end
    end)
  end

  def get_path(visited, post, path \\ []) do
    case Map.fetch!(visited, post) do
      nil -> path
      prev -> get_path(visited, prev, [post|path])
    end
  end

  def traversable(map, {row, col}) do
    pos = []

    height = elem(elem(map, row), col)

    # up
    pos =
      case row do
        0 -> pos
        row when (elem(elem(map, row - 1), col) - 1) <= height -> [{row - 1, col}|pos]
        _ -> pos
      end

    # down
    pos =
      case row do
        row when row == tuple_size(map) - 1 -> pos
        row when (elem(elem(map, row + 1), col) - 1) <= height -> [{row + 1, col}|pos]
        _ -> pos
      end

    # left
    pos =
      case col do
        0 -> pos
        col when (elem(elem(map, row), col - 1) - 1) <= height -> [{row, col - 1}|pos]
        _ -> pos
      end

    # right
    pos =
      case col do
        col when col == tuple_size(elem(map, 0)) - 1 -> pos
        col when (elem(elem(map, row), col + 1) - 1) <= height -> [{row, col + 1}| pos]
        _ -> pos
      end

    pos
  end

end

31 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle1()
29 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle2()
Puzzle.parse() |> Puzzle.puzzle1() |> IO.puts
Puzzle.parse() |> Puzzle.puzzle2() |> IO.puts

defmodule Puzzle do
  defmodule CaveMap do
    defstruct [
      :map,
      :x_offset,
      :abyss,
      allow_extension?: false
    ]
  end

  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Enum.map(fn line ->
      line
      |> String.trim_trailing()
      |> String.splitter(" -> ")
      |> Enum.map(fn point ->
        [x, y] = String.split(point, ",") |> Enum.map(&String.to_integer/1)
        {x, y}
      end)
    end)
  end

  def to_map(rock_paths) do
    {min_x, max_x} =
      Enum.reduce(rock_paths, {500, 500}, fn paths, acc ->
        Enum.reduce(paths, acc, fn {x, _}, {min_x, max_x} ->
          min_x = if x < min_x, do: x, else: min_x
          max_x = if x > max_x, do: x, else: max_x
          {min_x, max_x}
        end)
      end)

    max_y =
      Enum.reduce(rock_paths, 0, fn paths, acc ->
        Enum.reduce(paths, acc, fn {_, y}, max_x ->
          if y > max_x, do: y, else: max_x
        end)
      end)

    row = Tuple.duplicate(".", max_x + 2 - (min_x - 1))
    map = Tuple.duplicate(row, max_y + 1)

    map = %CaveMap{map: map, x_offset: min_x - 1, abyss: max_y}

    Enum.reduce(rock_paths, map, fn path, map ->
      place_rocks(map, path)
    end)
  end

  def add_floor(map) do
    width = tuple_size(elem(map.map, 0))
    empty_row = Tuple.duplicate(".", width)
    floor_row = Tuple.duplicate("#", width)

    new_map =
      map.map
      |> Tuple.append(empty_row)
      |> Tuple.append(floor_row)

    %CaveMap{map | map: new_map}
  end

  defp set_pos(map, x, y, char) do
    new_map =
      map.map
      |> elem(y)
      |> put_elem(x - map.x_offset, char)
      |> then(fn row ->
        put_elem(map.map, y, row)
      end)

    %CaveMap{map | map: new_map}
  end

  defp place_rocks(map, [_]), do: map

  defp place_rocks(map, [from, to | rest]) do
    {from_x, from_y} = from
    {to_x, to_y} = to

    map =
      if from_x == to_x do
        Enum.reduce(from_y..to_y, map, fn y, map -> set_pos(map, from_x, y, "#") end)
      else
        Enum.reduce(from_x..to_x, map, fn x, map -> set_pos(map, x, from_y, "#") end)
      end

    place_rocks(map, [to | rest])
  end

  def print_map(map) do
    for i <- 0..(tuple_size(map.map) - 1) do
      map.map |> elem(i) |> Tuple.to_list() |> Enum.join() |> IO.puts()
    end

    IO.puts("")
    map
  end

  def puzzle1(map, count \\ 0) do
    case drop_sand(map, 500, 0) do
      {:cont, map} ->
        puzzle1(map, count + 1)

      {:halt, map} ->
        {count, map}
    end
  end

  def puzzle2(map) do
    map = add_floor(%CaveMap{map | allow_extension?: true, abyss: (map.abyss + 2)})
    puzzle1(map)
  end

  defp drop_sand(map, pos_x, pos_y) do
    cond do
      blocked?(map, 500, 0) ->
        {:halt, map}

      pos_x - map.x_offset <= 0 ->
        if map.allow_extension? do
          map |> extend(:left) |> drop_sand(pos_x, pos_y)
        else
          {:halt, map}
        end

      pos_x - map.x_offset >= tuple_size(elem(map.map, 0)) - 1 ->
        if map.allow_extension? do
          map |> extend(:right) |> drop_sand(pos_x, pos_y)
        else
          {:halt, map}
        end

      pos_y == map.abyss ->
        {:halt, map}

      not blocked?(map, pos_x, pos_y + 1) ->
        drop_sand(map, pos_x, pos_y + 1)

      not blocked?(map, pos_x - 1, pos_y + 1) ->
        drop_sand(map, pos_x - 1, pos_y + 1)

      not blocked?(map, pos_x + 1, pos_y + 1) ->
        drop_sand(map, pos_x + 1, pos_y + 1)

      true ->
        {:cont, set_pos(map, pos_x, pos_y, "o")}
    end
  end

  def extend(cave_map, dir) do
    #IO.puts("extending #{dir}")
    map = cave_map.map

    {column, x_offset} =
      case dir do
        :left -> {0, cave_map.x_offset - 1}
        :right -> {tuple_size(elem(map, 0)), cave_map.x_offset}
      end

    map =
      Enum.reduce(0..(tuple_size(map) - 2), map, fn y, map ->
        row = elem(map, y)
        row = Tuple.insert_at(row, column, ".")
        put_elem(map, y, row)
      end)

    floor = elem(map, tuple_size(map) - 1)
    floor = Tuple.insert_at(floor, column, "#")
    map = put_elem(map, tuple_size(map) - 1, floor)
    %CaveMap{cave_map | map: map, x_offset: x_offset}
  end

  defp blocked?(map, x, y) do
    map.map |> elem(y) |> elem(x - map.x_offset) |> Kernel.!=(".")
  end
end

24 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.to_map() |> Puzzle.puzzle1() |> elem(0)

93 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.to_map() |> Puzzle.puzzle2() |> elem(0)

Puzzle.parse() |> Puzzle.to_map |> Puzzle.puzzle1 |> elem(0) |> IO.puts
Puzzle.parse() |> Puzzle.to_map |> Puzzle.puzzle2 |> elem(0) |> IO.puts

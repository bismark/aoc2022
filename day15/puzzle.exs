defmodule Puzzle do
  defmodule SensorBounds do
    defstruct [
      :coord,
      :x_range,
      :y_range
    ]
  end

  @regex ~r/x=(-?\d+), y=(-?\d+)/

  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Enum.reduce({[], MapSet.new()}, fn line, {sensor_bounds, known_beacons} ->
      [{sensor_x, sensor_y}, {beacon_x, beacon_y} = beacon] =
        Regex.scan(@regex, line, capture: :all_but_first)
        |> Enum.map(fn [x, y] ->
          {String.to_integer(x), String.to_integer(y)}
        end)

      known_beacons = MapSet.put(known_beacons, beacon)

      dist = abs(sensor_x - beacon_x) + abs(sensor_y - beacon_y)

      bounds = %SensorBounds{
        coord: {sensor_x, sensor_y},
        x_range: (sensor_x - dist)..(sensor_x + dist),
        y_range: (sensor_y - dist)..(sensor_y + dist)
      }

      {[bounds | sensor_bounds], known_beacons}
    end)
  end

  def puzzle1({bounds, beacons}, target_y) do
    unavailable_ranges(bounds, beacons, target_y)
    |> Enum.map(&Enum.count(&1))
    |> Enum.sum()
  end

  def puzzle2({bounds, beacons}, max) do
    Enum.find_value(0..max, fn target_y ->
      ranges = unavailable_ranges(bounds, beacons, target_y)

      case clamp_ranges(ranges, max) do
        [_] ->
          false

        ranges ->
          gaps = get_gaps(ranges, [])

          x =
            Enum.find_value(gaps, fn gap ->
              Enum.find(gap, fn x ->
                not MapSet.member?(beacons, {x, target_y})
              end)
            end)

          if x, do: {x, target_y}
      end
    end)
    |> then(fn {x, y} -> x * 4_000_000 + y end)
  end

  defp clamp_ranges(ranges, max) do
    ranges
    |> Enum.reject(fn range ->
      (range.first < 0 and range.last < 0) or
        (range.first > max and range.last > max)
    end)
    |> Enum.map(fn range ->
      cond do
        range.first < 0 -> 0..range.last
        range.last > max -> range.first..max
        true -> range
      end
    end)
  end

  defp get_gaps([_], gaps), do: gaps

  defp get_gaps([first, second | rest], gaps) do
    gaps = [(first.last + 1)..(second.first - 1) | gaps]
    get_gaps([second | rest], gaps)
  end

  defp unavailable_ranges(bounds, beacons, target_y) do
    beacons = MapSet.filter(beacons, &(elem(&1, 1) == target_y)) |> Enum.map(&elem(&1, 0))

    bounds
    |> Enum.filter(&(target_y in &1.y_range))
    |> Enum.map(&get_x_range(&1, target_y))
    |> Enum.sort()
    |> Enum.reduce([], fn
      range, [] ->
        [range]

      range, [prev | rest] = acc ->
        if Range.disjoint?(range, prev) do
          [range | acc]
        else
          first = min(prev.first, range.first)
          last = max(prev.last, range.last)
          [first..last | rest]
        end
    end)
    |> Enum.reverse()
    |> Enum.reduce([], fn range, acc ->
      ranges =
        Enum.reduce(beacons, [range], fn beacon, ranges ->
          if range = Enum.find(ranges, &(beacon in &1)) do
            ranges = List.delete(ranges, range)
            [range.first..(beacon - 1), (beacon + 1)..range.last | ranges]
          else
            ranges
          end
        end)

      ranges ++ acc
    end)
    |> Enum.sort()
  end

  defp get_x_range(bound, target_y) do
    {x, y} = bound.coord

    if target_y < y do
      (-target_y + bound.y_range.first + x)..(target_y + -bound.y_range.first + x)
    else
      (target_y + -bound.y_range.last + x)..(-target_y + bound.y_range.last + x)
    end
  end
end

26 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle1(10)
Puzzle.parse() |> Puzzle.puzzle1(2_000_000) |> IO.puts()
56_000_011 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle2(20)
Puzzle.parse() |> Puzzle.puzzle2(4_000_000) |> IO.puts()

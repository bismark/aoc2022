defmodule Puzzle do

  def find_marker(string, size) do
    in_queue = MapSet.new()
    queue = :queue.new()
    _find_marker(string, in_queue, queue, 1, size)
  end

  defp _find_marker("", _, _, _, _), do: raise "no marker"

  defp _find_marker(<<char::binary-size(1), rest::binary>>, in_queue, queue, idx, size) do
    if MapSet.member?(in_queue, char) do
      {in_queue, queue} = drain_queue(char, in_queue, queue)
      _find_marker(rest, in_queue, queue, idx + 1, size)
    else
      in_queue = MapSet.put(in_queue, char)
      if MapSet.size(in_queue) == size do
        idx
      else
        queue = :queue.in(char, queue)
        _find_marker(rest, in_queue, queue, idx + 1, size)
      end
    end
  end

  defp drain_queue(char, in_queue, queue) do
    {{:value, out_char}, queue} = :queue.out(queue)
    if out_char == char do
      {in_queue, :queue.in(char, queue)}
    else
      in_queue = MapSet.delete(in_queue, out_char)
      drain_queue(char, in_queue, queue)
    end
  end

end

__DIR__
|> Path.join("puzzle.txt")
|> File.stream!()
#|> Enum.take(1)
|> Enum.map(fn line ->
  Puzzle.find_marker(line, 14)
end)
|> IO.inspect(charlists: :as_lists)

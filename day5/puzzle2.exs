__DIR__
|> Path.join("puzzle.txt")
|> File.stream!
|> Enum.reduce({:stacks, :empty, :empty}, fn
  "\n", {:stacks, stacks, _} ->
    {:instructions, stacks, []}

  " 1 " <> _, {:stacks, stacks, _} ->
    {:stacks, Enum.map(stacks, & Enum.reverse(&1)), :empty}

  line, {:stacks, stacks, _} ->
    parsed = line |> :binary.bin_to_list() |> Enum.chunk_every(4)

    stacks =
      case stacks do
        :empty -> for _ <- 1..length(parsed), do: []
        _ -> stacks
      end

    stacks =
      Enum.zip(parsed, stacks)
      |> Enum.reduce([], fn
        {[32|_], stack}, stacks -> [stack|stacks]
        {[91,char|_], stack}, stacks -> [[char|stack]|stacks]
      end)
      |> Enum.reverse()

    {:stacks, stacks, :empty}

  instruction, {:instructions, stacks, instructions} ->
    ["move", count, "from", from, "to", to] = String.split(instruction)
    {:instructions, stacks, [{String.to_integer(count), String.to_integer(from) - 1, String.to_integer(to) - 1}|instructions]}
end)
|> then(fn {_, stacks, instructions} ->
    instructions = Enum.reverse(instructions)

    Enum.reduce(instructions, stacks, fn {count, from, to}, stacks ->
      from_stack = Enum.at(stacks, from)
      {move, from_stack} = Enum.split(from_stack, count)
      stacks = List.update_at(stacks, to, & move ++ &1)
      List.replace_at(stacks, from, from_stack)
    end)
    |> Enum.reduce([], &[hd(&1)|&2])
    |> Enum.reverse()
end)
|> IO.puts()











defmodule Puzzle do
  defmodule Monkey do
    defstruct [
      :id,
      :items,
      :operation,
      :divisible_by,
      :true_target,
      :false_target,
      num_checks: 0
    ]
  end

  def parse(path \\ "puzzle.txt") do
    __DIR__
    |> Path.join(path)
    |> File.stream!()
    |> Stream.chunk_every(7)
    |> Enum.map(fn chunk ->
      ["Monkey " <> num | chunk] = chunk
      id = num |> String.split(":") |> hd |> String.to_integer()

      ["  Starting items: " <> items | chunk] = chunk

      items =
        items
        |> String.split(",", trim: true)
        |> Enum.map(&(&1 |> String.trim() |> String.to_integer()))

      ["  Operation: new = old " <> operation | chunk] = chunk
      [operator, operand] = String.split(operation)

      operator_fun =
        case operator do
          "*" -> &Kernel.*/2
          "+" -> &Kernel.+/2
        end

      operation =
        case operand do
          "old" ->
            fn a -> operator_fun.(a, a) end

          num ->
            num = String.to_integer(num)
            fn a -> operator_fun.(a, num) end
        end

      ["  Test: divisible by " <> num | chunk] = chunk
      divisible_by = num |> String.trim() |> String.to_integer()

      ["    If true: throw to monkey " <> num | chunk] = chunk
      true_target = num |> String.trim() |> String.to_integer()

      ["    If false: throw to monkey " <> num | _] = chunk
      false_target = num |> String.trim() |> String.to_integer()

      %Monkey{
        id: id,
        items: items,
        operation: operation,
        divisible_by: divisible_by,
        true_target: true_target,
        false_target: false_target
      }
    end)
  end

  def run_rounds(monkeys, num_rounds \\ 1, worry_reducer \\ fn n -> div(n, 3) end) do
    for _ <- 0..(num_rounds - 1), i <- 0..(length(monkeys) - 1), reduce: monkeys do
      monkeys ->
        monkey = Enum.at(monkeys, i)

        monkeys =
          Enum.reduce(monkey.items, monkeys, fn item, monkeys ->
            #worry = item |> monkey.operation.() |> div(3)
            worry = item |> monkey.operation.() |> worry_reducer.()

            target =
              if rem(worry, monkey.divisible_by) == 0 do
                monkey.true_target
              else
                monkey.false_target
              end

            List.update_at(monkeys, target, &%Monkey{&1 | items: &1.items ++ [worry]})
          end)

        List.update_at(
          monkeys,
          i,
          &%Monkey{&1 | num_checks: &1.num_checks + length(&1.items), items: []}
        )
    end
  end

  def puzzle1(monkeys) do
    monkeys
    |> run_rounds(20)
    |> Enum.sort_by(& &1.num_checks, :desc)
    |> Enum.take(2)
    |> Enum.map(& &1.num_checks)
    |> Enum.product()
  end

  def puzzle2(monkeys, rounds \\ 10000) do
    sum = monkeys |> Enum.map(& &1.divisible_by) |> Enum.product()
    worry_reducer = fn n -> rem(n, sum) end

    monkeys
    |> run_rounds(rounds, worry_reducer)
    |> Enum.sort_by(& &1.num_checks, :desc)
    |> Enum.take(2)
    |> Enum.map(& &1.num_checks)
    |> Enum.product()
  end

end

10605 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle1()
Puzzle.parse() |> Puzzle.puzzle1() |> IO.puts

2713310158 = Puzzle.parse("puzzle_demo.txt") |> Puzzle.puzzle2()
Puzzle.parse() |> Puzzle.puzzle2() |> IO.puts

defmodule RobotSimulator do
  defstruct position: {0, 0}, direction: :north

  @type t :: %__MODULE__{
          position: {integer(), integer()},
          direction: :atom
        }
  @directions [:north, :east, :south, :west]
  @right_turns %{
    north: :east,
    east: :south,
    south: :west,
    west: :north
  }

  @left_turns %{
    north: :west,
    east: :north,
    south: :east,
    west: :south
  }

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: t
  def create(direction \\ :north, position \\ {0, 0}) do
    with true <- is_integer(position.x),
         true <- is_integer(position.y),
         direction in @directions,
         do: %__MODULE__{position: position, direction: direction}
  end

  defp validate_dir(dir) when dir in @directions, do: :ok
  defp validate_dir(_), do: {:error, "invalid direction"}
  defp validate_pos({x, y}) when is_integer(x) and is_integer(y), do: :ok
  defp validate_pos(_), do: {:error, "invalid position"}

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction(robot), do: robot.direction

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: {integer, integer}
  def position(robot), do: robot.position

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: any, instructions :: String.t()) :: any
  def simulate(robot, instructions) do
    case Regex.match?(~r/[^RLA]/, instructions) do
      true ->
        {:error, "invalid instruction"}

      false ->
        instructions |> String.graphemes() |> Enum.reduce(robot, &handle(&1, &2))
    end
  end

  defp handle("R", robot), do: %{robot | direction: Map.fetch!(@right_turns, robot.direction)}
  defp handle("L", robot), do: %{robot | direction: Map.fetch!(@left_turns, robot.direction)}

  defp handle("A", robot) do
    advance = fn
      {x, y}, :north -> {x, y + 1}
      {x, y}, :east -> {x + 1, y}
      {x, y}, :south -> {x, y - 1}
      {x, y}, :west -> {x - 1, y}
    end

    %{robot | position: advance.(robot.position, robot.direction)}
  end

  defp handle(_, _), do: :error
end

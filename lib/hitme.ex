defmodule Hitme do
  @moduledoc """
  An example of a command line application in Elixir: fetches a random reminder / quote / inspirational phrase from a number of previously saved or default phrases.
  """

  @default_vault System.user_home <> "/.hitme"

  @doc """
  Path to the phrase vault
  """
  def vault do
    case System.get_env("HITME_VAULT") do
      nil -> @default_vault
      vault -> vault
    end
  end

  @doc """
  Path to the seed
  """
  def seed_vault, do: "./.hitme.default"

  @doc """
  Command line script entry point
  """
  def main(args) do
    args
    |> parse_args
    |> process
  end

  @doc """
  Parse command line arguments
  """
  def parse_args(args) do
    {switches, commands, _} =
      args
      |> OptionParser.parse(
        strict: [
          help: :boolean,
          add: :string,
          seed: :boolean,
          empty: :boolean
        ],
        aliases: [
          h: :help,
          a: :add,
          s: :seed,
          e: :empty
        ])
    case {switches, commands} do
      {[help: true], _} -> :help
      {_, ["help"]} -> :help
      {[add: phrase], _} -> {:add, phrase}
      {_, ["add", phrase]} -> {:add, phrase}
      {[seed: true], _} -> :seed
      {_, ["seed"]} -> :seed
      {[empty: true], _} -> :empty
      {_, ["empty"]} -> :empty
      _ -> :pick
    end
  end

  @doc """
  Execute the command passed
  """
  def process(:pick) do
    {:ok, file} = File.open(vault, [:read])
    case IO.read(file, :all) do
      {:error, reason} ->
        error reason
      lines ->
        :random.seed()
        phrase_list = lines
        |> String.split("\n")
        |> Enum.filter(fn(x) -> String.strip(x) !== "" end)
        case phrase_list do
          [] ->
            error "Your phrase vault is empty!"
          list ->
            list
            |> Enum.random
            |> picked
        end
    end
  end

  def process({:add, phrase}) do
    {:ok, file} = File.open(vault, [:append])
    if IO.write(file, phrase <> "\n") === :ok do
      success "Your phrase was added successfully!"
    end
  end

  def process(:seed) do
    if File.cp(seed_vault, vault) === :ok do
      success "Your phrase vault was seeded successfully!"
    end
  end

  def process(:empty) do
    {:ok, _} = File.open(vault, [:write])
    success "Your phrase vault was emptied successfully!"
  end


  def process(:help) do
    info """
    - hitme: pick a phrase
    - hitme add <phrase>: add a phrase to the list
    - hitme seed: copy the default set of phrases to your vault (courtesy of Oscar Wilde)
    - hitme empty: empty your phrase vault
    - hitme help: see this info
    """
  end

  @doc """
  Print the picked phrase (in blue)
  """
  def picked(phrase) do
    IO.puts "\n" <> IO.ANSI.reset <> IO.ANSI.blue <> phrase <> IO.ANSI.reset <> "\n"
  end

  @doc """
  Print a success message (in green)
  """
  def success(message) do
    IO.puts "\n" <> IO.ANSI.reset <> IO.ANSI.green <> message <> IO.ANSI.reset <> "\n"
  end

  @doc """
  Print some neutral info (in yellow)
  """
  def info(message) do
    IO.puts "\n" <> IO.ANSI.reset <> IO.ANSI.yellow <> message <> IO.ANSI.reset <> "\n"
  end

  @doc """
  Print an error message (in red)
  """
  def error(message) do
    IO.puts "\n" <> IO.ANSI.reset <> IO.ANSI.red <> message <> IO.ANSI.reset <> "\n"
  end
end

defmodule HitmeTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Hitme
  doctest Hitme

  setup_all do
    original_env_vault = System.get_env("HITME_VAULT")
    System.put_env("HITME_VAULT", Path.join(__DIR__, "fixture.txt"))
    on_exit fn ->
      case original_env_vault do
        nil -> System.delete_env("HITME_VAULT")
        value -> System.put_env("HITME_VAULT", value)
      end
    end
  end

  test "picks a phrase" do
    {:ok, seed_file} = File.open(seed_vault, [:read])
    seed = IO.read(seed_file, :all)
    assert String.contains?(capture_io(fn ->
      process(:seed)
    end), "Your phrase vault was seeded successfully!")
    picked = capture_io(fn ->
      process(:pick)
    end)
    assert Enum.any?(String.split(seed, "\n", trim: true), fn(x) -> String.contains?(picked, x) end)
  end

  test "warns when the vault is empty" do
    assert String.contains?(capture_io(fn ->
      process(:empty)
      process(:pick)
    end), "Your phrase vault is empty!")
  end

  test "adds phrases to the vault" do
    assert String.contains?(capture_io(fn ->
      process(:empty)
      process({:add, "Roses are red"})
      process({:add, "Violets are blue"})
    end), "Your phrase was added successfully!")
    {:ok, file} = File.open(vault, [:read])
    assert IO.read(file, :all) == "Roses are red\nViolets are blue\n"
  end

  test "seeds the phrase vault" do
    {:ok, seed_file} = File.open(seed_vault, [:read])
    seed = IO.read(seed_file, :all)
    assert String.contains?(capture_io(fn ->
      process(:seed)
    end), "Your phrase vault was seeded successfully!")
    {:ok, file} = File.open(vault, [:read])
    assert IO.read(file, :all) == seed
  end

  test "empties the vault" do
    {:ok, file} = File.open(vault, [:append])
    assert IO.write(file, "Something not empty\n") === :ok
    assert String.contains?(capture_io(fn ->
      process(:empty)
    end), "Your phrase vault was emptied successfully!")
    {:ok, file} = File.open(vault, [:read])
    if IO.read(file, :all) !== "", do: flunk "Vault is not empty!"
  end

  test "prints help message" do
    assert String.contains?(capture_io(fn -> process(:help) end), "hitme help: see this info")
  end

  test "prints picked in blue" do
    assert String.contains?(capture_io(fn -> picked("something") end), IO.ANSI.blue <> "something")
  end

  test "prints success in green" do
    assert String.contains?(capture_io(fn -> success("something good") end), IO.ANSI.green <> "something good")
  end

  test "prints info in yellow" do
    assert String.contains?(capture_io(fn -> info("something else") end), IO.ANSI.yellow <> "something else")
  end

  test "prints error in red" do
    assert String.contains?(capture_io(fn -> error("something bad") end), IO.ANSI.red <> "something bad")
  end
end

defmodule NarwinChat.Words do
  @random_big_words "#{:code.priv_dir(:narwin_chat)}/wordlists/random_big.txt"
                    |> File.read!()
                    |> String.split("\n")

  def random_big do
    Enum.random(@random_big_words)
  end
end

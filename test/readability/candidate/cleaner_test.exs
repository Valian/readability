defmodule Readability.Candidate.CleanerTest do
  use ExUnit.Case, async: true

  doctest Readability.Candidate.Cleaner

  alias Readability.Candidate.Cleaner

  @sample """
  <html>
    <head>
      <title>title!</title>
    </head>
    <body class='comment'>
      <div>
        <p class='comment'>a comment</p>
        <div class='comment' id='body'>real content</div>
        <div id="contains_blockquote"><blockquote>something in a table</blockquote></div>
      </div>
    </body>
  </html>
  """

  @html_tree Floki.parse_fragment!(@sample)

  ### Transform misued div

  test "transform divs containing no block elements" do
    html_tree = Cleaner.transform_misused_div_to_p(@html_tree)
    [{tag, _, _} | _] = html_tree |> Floki.find("#body")

    assert tag == "p"
  end

  test "not transform divs that contain block elements" do
    html_tree = Cleaner.transform_misused_div_to_p(@html_tree)
    [{tag, _, _} | _] = html_tree |> Floki.find("#contains_blockquote")
    assert tag == "div"
  end

  ### Remove unlikely tag

  test "remove things that have class comment" do
    html_tree = Cleaner.remove_unlikely_tree(@html_tree)
    refute Floki.text(html_tree) =~ ~r/a comment/
  end

  test "not remove body tags" do
    html_tree = Cleaner.remove_unlikely_tree(@html_tree)
    refute Floki.find(html_tree, "body") == []
  end
end

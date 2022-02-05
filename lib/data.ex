defmodule InsightsScraper.Data do
  @moduledoc ~s"""
  Scrape the insights found here: https://insights.santiment.net/
  """

  def get(opts \\ []) do
    insights_limit = Keyword.get(opts, :insights_limit, 999_999_999)

    get_data(insights_limit)
    |> remove_nil_texts()
    |> remove_paywalled_insights_if_no_apikey()
    |> remove_top_trending_words_insights()
    |> santize_text()
    |> convert_tags_to_project_names()
    |> add_url()
    |> convert_for_export()
  end

  # Private functions

  defp convert_for_export(insights) do
    headers = ["title", "text", "tags", "url"]

    rows =
      Enum.map(insights, fn insight_map ->
        [
          insight_map["title"],
          insight_map["text"],
          insight_map["tags"],
          insight_map["url"]
        ]
      end)

    [headers] ++ rows
  end

  defp add_url(insights) do
    insights
    |> Enum.map(fn %{"id" => id} = insight_map ->
      Map.put(insight_map, "url", "https://insights.santiment.net/read/#{id}")
    end)
  end

  defp remove_nil_texts(insights) do
    insights
    |> Enum.reject(fn insight_map -> is_nil(insight_map["text"]) end)
  end

  # In case there is no apikey, remove all insights that are paywalled
  # as they contain just the first ~200 symbols of the text
  defp remove_paywalled_insights_if_no_apikey(insights) do
    insights =
      case apikey() do
        <<_::binary>> ->
          insights

        nil ->
          insights |> Enum.reject(& &1["isPaywallRequired"])
      end

    insights |> Enum.map(&Map.delete(&1, "isPaywallRequired"))
  end

  defp remove_top_trending_words_insights(insights) do
    insights
    |> Enum.reject(fn insight_map ->
      insight_map["tags"]
      |> Enum.any?(fn %{"name" => tag} -> String.ends_with?(tag, "trending-words") end)
    end)
  end

  defp santize_text(insights) do
    insights
    |> Enum.map(fn insight_map ->
      Map.put(insight_map, "text", HtmlSanitizeEx.strip_tags(insight_map["text"]))
    end)
  end

  # In the tags list the projects are marked with their ticker/symbol.
  # Convert these tickers to the user-friendly name
  # For example BTC becomes Bitcoin, XRP becomes ripple, ADA becomes Cardano
  # The tags that are not project names are either kept or ignored
  defp convert_tags_to_project_names(insights) do
    tickers_map = ProjectsDictionary.get_data()

    insights
    |> Enum.map(fn insight_map ->
      tags = insight_map["tags"] |> Enum.map(& &1["name"])

      improved_tags =
        tags
        |> Enum.map(fn tag ->
          project_map = Map.get(tickers_map, tag)

          # If the tag is a ticker that maps to a project
          # get that project name
          case project_map do
            %{"name" => project_name} ->
              project_name

            _ ->
              cond do
                # The tags ending with trending-words are a special
                # case tags that are used for marking the insight as
                # containing the current trending words. They can
                # safely be ignored as they look like: 2020-01-01-trending-words
                String.ends_with?(tag, "trending-words") -> nil
                # Keep all of the other tags
                true -> tag
              end
          end
        end)
        |> Enum.reject(&is_nil/1)
        |> Enum.map(&String.downcase/1)

      Map.put(insight_map, "tags", improved_tags)
    end)
  end

  # Get the raw data from the GraphQL API endpoint.
  # Run the program with SANTIMENT_API_KEY env var that
  # contains an API key so that paywalled insights can be obtained
  defp get_data(insights_limit) do
    {:ok, response} =
      Neuron.query(
        """
        {
          allInsights(page: 1, pageSize: #{insights_limit}) {
            id
            title
            text
            tags{ name }
            isPaywallRequired
          }
        }
        """,
        %{},
        url: "https://api.santiment.net/graphql",
        headers: authorization_headers()
      )

    response.body["data"]["allInsights"]
  end

  defp authorization_headers() do
    case apikey() do
      <<_::binary>> = apikey -> [authorization: "Apikey #{apikey}"]
      nil -> []
    end
  end

  defp apikey(), do: System.get_env("SANTIMENT_API_KEY")
end

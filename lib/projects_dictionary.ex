defmodule ProjectsDictionary do
  @doc "Return a map with key ticker and value the ticker/name/slug"
  def get_data() do
    Neuron.Config.set(url: "https://api.santiment.net/graphql")

    {:ok, response} =
      Neuron.query("""
      {
        allProjects{
          ticker
          name
          slug
        }
      }
      """)

    response.body["data"]["allProjects"]
    |> Map.new(&{&1["ticker"], &1})
  end
end

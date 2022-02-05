defmodule InsightsScraper.Run do
  def run do
    data = InsightsScraper.Data.get()
    :ok = InsightsScraper.CsvExporter.export("insights.csv", data)
  end
end

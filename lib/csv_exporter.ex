defmodule InsightsScraper.CsvExporter do
  NimbleCSV.define(CsvParser, separator: ",", escape: "\"")

  def export(data, file) do
    data = CsvParser.dump_to_iodata(data)
    :ok = File.write(file, [data])
  end
end

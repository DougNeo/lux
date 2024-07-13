defmodule DataCleaner do
  @month_translation %{
    "JANEIRO" => "JANUARY",
    "FEVEREIRO" => "FEBRUARY",
    "MARÇO" => "MARCH",
    "ABRIL" => "APRIL",
    "MAIO" => "MAY",
    "JUNHO" => "JUNE",
    "JULHO" => "JULY",
    "AGOSTO" => "AUGUST",
    "SETEMBRO" => "SEPTEMBER",
    "OUTUBRO" => "OCTOBER",
    "NOVEMBRO" => "NOVEMBER",
    "DEZEMBRO" => "DECEMBER"
  }

  def clean_data(data) do
    data
    |> upcase_tabela()
    |> trim_space()
    |> trim_space_invisible()
    |> remove_headers()
    |> Enum.map(&process_row/1)
  end

  defp upcase_tabela(data) do
    Enum.map(data, fn linha -> Enum.map(linha, &String.upcase/1) end)
  end

  defp trim_space(data) do
    Enum.map(data, fn linha -> Enum.map(linha, fn item -> String.replace(item, " ", "") end) end)
  end

  def trim_space_invisible(data) do
    Enum.map(data, fn linha -> Enum.map(linha, fn item -> String.replace(item, "\u200B", "") end) end)
  end

  def remove_headers(data) do
    header = hd(data)
    [_hd | sem_hd] = [header | Enum.filter(tl(data), &(&1 != header))]
    sem_hd
  end

  def process_row([month_year | rest]) do
    IO.inspect([month_year | rest])
    [convert_to_date(month_year) | Enum.map(rest, &convert_to_float/1)]
  end

  def convert_to_date(month_year) do
    [month_pt, year] = String.split(month_year, "/")
    month_en = Map.get(@month_translation, month_pt)
    IO.inspect(month_en)
    {:ok, date} = Date.from_iso8601("#{year}-#{month_to_number(month_en)}-01")
    date
  end

  defp convert_to_float(percent_str) do
    percent_str
    |> String.replace(",", ".")
    |> String.replace("%", "")
    |> Float.parse()
    |> elem(0)
  end

  defp month_to_number(month) do
    case month do
      "JANUARY" -> "01"
      "FEBRUARY" -> "02"
      "MARCH" -> "03"
      "APRIL" -> "04"
      "MAY" -> "05"
      "JUNE" -> "06"
      "JULY" -> "07"
      "AUGUST" -> "08"
      "SEPTEMBER" -> "09"
      "OCTOBER" -> "10"
      "NOVEMBER" -> "11"
      "DECEMBER" -> "12"
    end
  end
end

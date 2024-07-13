defmodule Lux.Imposto do
    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://www.edp.com.br"

    def get_page do
      cookies = ["_edp-estado-selecionado=ES"]

      {:ok, %Tesla.Env{body: body}} = get("/icms-pis-e-cofins/", headers: [{"Cookie", cookies}])
      {:ok, html_parsed} = Floki.parse_document(body)
      html_parsed
    end

    def get_tax do
      get_page()
      |> Floki.find("#estrutura-de-conteudo-63281924")
      |> IO.inspect()
      |> Floki.find("tbody tr")
      |> Enum.map(fn row ->
        Floki.find(row, "td")
        |> Enum.map(&Floki.text/1)
        |> Enum.map(&String.trim/1)
      end)
      |> DataCleaner.clean_data()
    end

    def tax_per_year do
      get_tax()
      |> Enum.map(fn [year, icms, pis, cofins] ->
        %{
          year: year,
          icms: icms,
          pis: pis,
          cofins: cofins
        }
      end)
    end


  end

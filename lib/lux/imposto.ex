defmodule Lux.Imposto do
    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://www.edp.com.br"
    plug Tesla.Middleware.Headers, [
      {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"},
      {"Accept-Language", "pt-BR,pt;q=0.9"},
      {"Cache-Control", "max-age=0"},
      {"Connection", "keep-alive"},
      {"Referer", "https://www.edp.com.br/icms-pis-e-cofins/"},
      {"Sec-Fetch-Dest", "document"},
      {"Sec-Fetch-Mode", "navigate"},
      {"Sec-Fetch-Site", "same-origin"},
      {"Sec-Fetch-User", "?1"},
      {"Upgrade-Insecure-Requests", "1"},
      {"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"},
      {"sec-ch-ua", "\"Google Chrome\";v=\"125\", \"Chromium\";v=\"125\", \"Not.A/Brand\";v=\"24\""},
      {"sec-ch-ua-mobile", "?0"},
      {"sec-ch-ua-platform", "\"Windows\""}
    ]

    def get_page do
      cookies = [
        "_edp-exibe-triagem=S",
        "_gcl_au=1.1.1435026011.1718153908",
        "_clck=1v2sn5j%7C2%7Cfmk%7C0%7C1624",
        "_hjSessionUser_4941482=eyJpZCI6IjQwYjFmMzY5LWQxMTAtNTAzYS05YjcyLTE4N2ViZWVlNTgwMSIsImNyZWF0ZWQiOjE3MTgxNTM5MDg1MjMsImV4aXN0aW5nIjpmYWxzZX0=",
        "_hjSession_4941482=eyJpZCI6IjExMWNlMjE1LWExMGMtNDY4OC1hOTFkLWFhOGQyNzFkYjliMCIsImMiOjE3MTgxNTM5MDg1MjQsInMiOjAsInIiOjAsInNiIjowLCJzciI6MCwic2UiOjAsImZzIjoxLCJzcCI6MH0=",
        "_ga=GA1.3.267121229.1718153909",
        "_gid=GA1.3.2099659401.1718153909",
        "_dc_gtm_UA-99619129-5=1",
        "_ga_ZB81Y73WQ7=GS1.3.1718153908.1.0.1718153908.0.0.0",
        "_fbp=fb.2.1718153909194.864818796189681306",
        "_clsk=xuxxi9%7C1718153909344%7C1%7C1%7Cx.clarity.ms%2Fcollect",
        "OptanonAlertBoxClosed=2024-06-12T00:58:42.941Z",
        "OptanonConsent=isGpcEnabled=0&datestamp=Tue+Jun+11+2024+21%3A58%3A42+GMT-0300+(Hor%C3%A1rio+Padr%C3%A3o+de+Bras%C3%ADlia)&version=202211.1.0&isIABGlobal=false&hosts=&consentId=c3882ff6-bad8-4d9c-88fa-fd95ce29a56d&interactionCount=2&landingPath=NotLandingPage&groups=C0001%3A1%2CC0002%3A0%2CC0004%3A0",
        "_ga_6FWYRJ93HF=GS1.1.1718153908.1.1.1718153929.0.0.0",
        "_edp-estado-selecionado=ES",
        "_gali=btnESModal3"
      ] |> Enum.join("; ")

      {:ok, %Tesla.Env{body: body}} = get("/icms-pis-e-cofins/", headers: [{"Cookie", cookies}])
      {:ok, html_parsed} = Floki.parse_document(body)
      html_parsed
    end

    def get_tax do
      get_page()
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

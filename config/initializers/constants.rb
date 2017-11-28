# -*- coding: utf-8 -*-
MenuItems = {
  "Accounts" => "/accounts",
  "Rating" => "/rating",
}

FigoPublicKey="-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1qB2hmObbCbAM+lc+ggDauoIZReejEimnvrmeqEs0opeTeZiiietoHT1FkB8HjlgCWrh6UimxrRvBwwvNn/4uiVEqxuPb37ozWRj87bp1R3iwhzIGHBMgkibfFf9v3FxEjtY6CgCvOJ/12+AiotL+4jBCwsUWcqui3phq4/C19bQTWaN8u1Q1ABB0SSExcfqH3Ahg6i4pJfDwY+/khb4rgvmqPpb7a0tHiWuWqAMUxfEO/GJVaDV+Bq4k5vfUNirIcazUtmnLhBVSTBcjw7OEDEIHGckwUHs6prKE0kkQD4Xjm06XupuZW8/H+/oPBdHJBr+Ugv5Kzlsst/81BEyoQIDAQAB-----END PUBLIC KEY-----"

BlzSearchUrls = {}
BlzSearchUrls["DE"]="https://www.bundesbank.de/Navigation/DE/Service/Suche_BLZ/Erweitert/erweiterte_blz_suche_node.html"

BankLoginURLs = {
  "10050000" => "https://www.berliner-sparkasse.de/de/home.html"
}

FigoDemoBank = {
  "bank_name" => "Figo DemoBank",
  'bank_code' => "90090042",
  "advice" => "Just Enter demo/demo for username/password",
  "credentials" => [{ "label" => "Username", "masked" => false},
                    { "label" => "Password", "masked" => true }
                   ],
  "icon" => ["https://api.figo.me/assets/images/accounts/default.png",
     {"120x120"=>"https://api.figo.me/assets/images/accounts/default_120.png",
      "144x144"=>"https://api.figo.me/assets/images/accounts/default_144.png",
      "192x192"=>"https://api.figo.me/assets/images/accounts/default_192.png",
      "256x256"=>"https://api.figo.me/assets/images/accounts/default_256.png",
      "48x48"  =>"https://api.figo.me/assets/images/accounts/default_48.png",
      "60x60"  =>"https://api.figo.me/assets/images/accounts/default_60.png",
      "72x72"  =>"https://api.figo.me/assets/images/accounts/default_72.png",
      "84x84"  =>"https://api.figo.me/assets/images/accounts/default_84.png",
      "96x96"  =>"https://api.figo.me/assets/images/accounts/default_96.png"}]
}

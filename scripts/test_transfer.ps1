$ErrorActionPreference = "Stop"

$base = "http://127.0.0.1:8000/api"

function PostJson($url, $body, $headers = @{}) {
  Invoke-RestMethod -Method Post -Uri $url -ContentType "application/json" -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
}

function GetJson($url, $headers = @{}) {
  Invoke-RestMethod -Method Get -Uri $url -Headers $headers
}

$jean = PostJson "$base/auth/login" @{ email = "jean.dupont@example.com"; password = "password123" }
$jeanToken = $jean.token
$jeanHeaders = @{ Authorization = "Bearer $jeanToken" }

$jeanAccounts = GetJson "$base/accounts" $jeanHeaders
$from = $jeanAccounts.accounts[0].id

$benef = GetJson "$base/beneficiaries" $jeanHeaders
$to = ($benef.beneficiaries | Where-Object { $_.owner.name -like "*Marie*" } | Select-Object -First 1).id
if (-not $to) { throw "No Marie beneficiary found" }

$transfer = PostJson "$base/transactions/transfer" @{
  from_account_id = $from
  to_account_id   = $to
  amount          = 10.00
  description     = "Test virement"
} $jeanHeaders

$ref = $transfer.transaction.reference_number

$marie = PostJson "$base/auth/login" @{ email = "marie.martin@example.com"; password = "password123" }
$marieToken = $marie.token
$marieHeaders = @{ Authorization = "Bearer $marieToken" }

$marieTx = GetJson "$base/transactions" $marieHeaders
$match = $marieTx.transactions | Where-Object { $_.reference_number -eq $ref }

"OK transferRef=$ref foundInMarieTx=$((@($match)).Count)"


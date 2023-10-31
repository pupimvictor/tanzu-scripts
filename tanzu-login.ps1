# Prompt the user to select the server
Write-Host "Selecione o servidor:"
Write-Host "1. sv05"
Write-Host "2. sv06"
$serverChoice = Read-Host "Escolha o número do servidor (1 ou 2):"
switch ($serverChoice) {
    1 { $serverChoice = "sv05" }
    2 { $serverChoice = "sv06" }
    default { Write-Host "Escolha de servidor inválida." ; Exit }
}

# Define the IP addresses based on the server choice
$serverIP = @{
    "sv05" = "10.18.0.2"
    "sv06" = "10.38.0.2"
}

# Prompt the user to select the namespace
Write-Host "Selecione o namespace do cluster de tanzu-kubernetes:"
Write-Host "1. sbx-ns"
Write-Host "2. dev-ns"
Write-Host "3. qa-ns"
Write-Host "4. prd-ns"
$namespaceChoice = Read-Host "Escolha o número do namespace (1 a 4):"
switch ($namespaceChoice) {
    1 { $namespaceChoice = "sbx-ns" }
    2 { $namespaceChoice = "dev-ns" }
    3 { $namespaceChoice = "qa-ns" }
    4 { $namespaceChoice = "prd-ns" }
    default { Write-Host "Escolha de namespace inválida." ; Exit }
}

# Prompt the user to select admin access
Write-Host "Selecione o acesso de administrador:"
Write-Host "1. Sim"
Write-Host "2. Não"
$adminAccessChoice = Read-Host "Escolha o número do acesso de administrador (1 ou 2):"
switch ($adminAccessChoice) {
    1 { $TANZU_USER = "administrator@vsphere.local" }
    2 { $TANZU_USER = $env:TANZU_USER; if (-not $TANZU_USER) { Write-Host "Erro: A variável de ambiente 'TANZU_USER' não está definida." ; Exit } }
    default { Write-Host "Escolha de acesso de administrador inválida." ; Exit }
}

# Prompt the user for the cluster name
$clusterName = Read-Host "Informe o nome do cluster de tanzu-kubernetes (deixe em branco se não desejar):"

# Construct the kubectl vsphere login command with the selected IP, namespace, and admin access
$kubectlCommand = "kubectl vsphere login --server https://$($serverIP[$serverChoice]):6443 --insecure-skip-tls-verify --vsphere-username $TANZU_USER --tanzu-kubernetes-cluster-namespace $namespaceChoice"

# Add the cluster name flag if provided
if (-not [string]::IsNullOrEmpty($clusterName)) {
    $kubectlCommand += " --tanzu-kubernetes-cluster-name $clusterName"
}

# Display a message explaining what's going to happen
Write-Host "Aqui está o que vai acontecer:"
Write-Host "Você vai executar o seguinte comando kubectl:"
Write-Host $kubectlCommand

# Execute the kubectl command
Invoke-Expression $kubectlCommand
Write-Host "Comando executado com sucesso."
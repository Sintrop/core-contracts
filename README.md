# SINTROP CONTRACTS 

Para realizar o deploy dos contratos na rede ganache, é necessário ter instalado os seguintes programas:

### Instalar o Ganache:

Ganache:
```
https://trufflesuite.com/ganache/
```

### Instalar o Truffle:
```
npm install -g truffle
```
# 🚀 FAZENDO O DEPLOY DOS CONTRATOS

### Para fazer o deploy dos contratos, siga estas etapas:

1. Comente  a linha 5 do `migrations/4_deploy_producer.js.` Este contrato necessitará do endereço do contrato principal e do SAT.
2. Realize o comando: ` truffle migrate --reset `
3. Após o deploy do contrato Sintrop, comentar a linha 5 do arquivo `migrations/2_deploy_contracts.js` e a linha 9 do arquivo `migrations/3_deploy_contracts_SAT.js`
4. Copiar o endereço do contrato Sintrop no console ` > contract address:    0x...` e do contrato SAT para as respectivas variaveis do contrato `migrations/4_deploy_producer.js`
5. Realize o comando: ` truffle migrate --reset `

# 💻 LINKAR OS CONTRATOS COM O DASHBOARD

1. Copiar os arquivos criados na pasta `/abis` para a pasta `/data/contracts` do dashboard para que os métodos e endereços sejam atualizados. Caso necessário realize o comando `ng serve` novamente.

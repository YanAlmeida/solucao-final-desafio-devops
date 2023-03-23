# Solução Desafio Devops - Let's Code Ada

Esse repositório consiste na solução do desafio proposto.
Desenvolvi a solução em duas etapas: a primeira consistindo no desenvolvimento dos templates IaC e no deploy da aplicação na cloud escolhida (AWS) e a segunda consistindo na criação dos dockerfiles, build das imagens e desenvolvimento dos manifests para deploy da aplicação em cluster Kubernetes. A segunda parte foi testada localmente, utilizando o MiniKube.

## Organização do repositório

```

├── backend
│   ├── app
│   │   └── ...
│   ├── manifests
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── secrets.yaml
│   │   └── service.yaml
│   └── Dockerfile
├── frontend
│   ├── app
│   │   └── ...
│   ├── manifests
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── service.yaml
│   └── Dockerfile
├── database
│   └── manifests
│   │   ├── deployment.yaml
│   │   ├── secrets.yaml
│   │   └── service.yaml
├── templates_cloudformation
│   ├── template-bucket-deploy-backend.yaml # Contém a criação do bucket para armazenar o .JAR
│   ├── template-bucket-website-frontend.yaml # Contém a criação do bucket para hospedagem do website estático
│   ├── template-instancia.yaml # Contém a criação da instância, do banco de dados e de todos os recursos necessários (security groups, roles etc.)
│   └── template-vpc.yaml # Contém a criação da VPC e suas subredes
└── deploy_app.sh

```

## Parte 1 - Efetuando o deploy na AWS

Inicialmente, desenvolvi o template IaC para criação da VPC com três subredes públicas e três subredes privadas. Como parâmetros default, dado que é especificado que o tamanho da rede é pequeno, estabeleci os ranges de IPs da seguinte forma: utilizando a máscara /25 para a VPC, possibilitando 128 hosts, e a máscara /28 para cada uma das 6 subredes, possibilitando 16 hosts para cada. No template, é criada a VPC, bem como suas subredes (públicas e privadas), o Internet Gateway para as redes públicas e a Route Table pública.

Em um segundo momento, desenvolvi os templates referentes ao deploy do backend. A solução compreende a criação da instância do banco de dados (bem como seu security group, confiando apenas no security group da instância, etc) e a criação de uma instância EC2 com um ElasticIP associado, um security group garantindo as necessidades do desafio (acesso à porta 22 por SSH apenas para um range determinado de IPs, acesso livre à 8080 e à 443) e um script de boostrap para instalação do Java, definição das variáveis de ambiente necessárias à aplicação (utilizando serviços como o SecretsManager e SSM Parameter Store na criação do banco de dados para guardar informações como a senha, o usuário etc.) e, por fim, ativação do CFN-INIT para recuperação do .JAR de um bucket S3 e posterior execução. 
O formato desenvolvido atende as necessidades de launch da instância executando a aplicação, mas se torna ineficiente quando precisamos de novos deploys ou garantir a resiliência da aplicação. Por conta disso, muitas melhorias são possíveis e não puderam ser desenvolvidas em tempo hábil: uso do CodePipeline, em conjunto com o CodeCommit, para criar um fluxo de CI/CD, uso do CodeBuild para build das aplicações e do CodeDeploy para deploy. Além disso, decisões arquiteturais melhores são possíveis (utilizar um Elastic Load Balancer, AutoScaling etc.) para aumentar a resiliência, escalabilidade e confiabilidade do sistema.

Para esse processo, criou-se também um template para gerar um bucket s3 que armazenasse o .JAR, bem como roles contendo permissões necessárias para a preparação e deploy da aplicação (recuperar objetos no bucket, buscar a senha do banco de dados no secretsmanager etc.)

Por fim, desenvolvi o template IaC referente ao website estático. Nele, são inseridos os arquivos estáticos referentes à compilação do código em Angular. Para fins de demonstração, a aplicação está disponível no link `http://letscode.devops.com.s3-website-sa-east-1.amazonaws.com/`, totalmente integrada com a instância executando o backend e o banco de dados - todos provisionados dentro do free tier da AWS, e que serão desativados por volta do dia 27/03/2023 para evitar custos.
Para testes na aplicação do link, o usuário cadastrado é `myuser123`, e a senha `mypassword123`.

## Parte 2 - K8S

Para deploy da aplicação em um cluster Kubernetes, inicialmente trabalhei a dockerização das aplicações. Para o backend, o dockerfile foi criado em duas partes: build da aplicação e execução do jar. De forma similar, para o frontend o dockerfile do frontend também é dividido em duas etapas, porém alterações foram feitas no código-fonte (geração de scripts js para inclusão de váriaveis de ambiente em runtime, possibilitando a inclusão da url do backend de forma dinâmica). Após o build das imagens e envio para o Docker Hub, criei os manifests para cada aplicação, fazendo as devidas referências. Para o backend, os manifests criados foram o deployment, secrets, service e ingress (para acesso a ele a partir do front, que é executado no browser do usuário), para o frontend o deployment, service e ingress (para acesso do usuario) e para o banco de dados, deployment, service e secrets.

O script deploy_app.sh foi desenvolvido para executar o kubectl -f apply em cada uma das pastas. Durante os testes, utilizei o MiniKube para gerar um cluster Kubernetes localmente, editei o arquivo /etc/hosts para uso dos domínios criados e inseri usuários novos através da API. Com isso, a aplicação foi executada com sucesso, exibindo corretamente o frontend e efetuando as chamadas certas ao backend, devidamente integrado ao banco de dados.

## Imagens

Stacks do CloudFormation na AWS:

![image](https://user-images.githubusercontent.com/66225558/227091912-8e7fbcd5-9a7b-4432-8bbc-82472fdbf299.png)


Resultado final K8S:

![execucao_cluster](https://user-images.githubusercontent.com/66225558/227090885-34841315-e647-4883-b9dc-0521e6eb4146.jpeg)


Aplicação executando com o domínio definido:

![finalizacao_desafio](https://user-images.githubusercontent.com/66225558/227090912-ddc59e5c-a6f1-4de0-986d-1ec47d9c9a77.jpeg)



## terraform 

### terraformのインストール
https://www.terraform.io/

### terraform 初期設定 .terraform/が作成される
terraform init

### フォーマットを整える 
terraform fmt

### 構文のチェック
terraform validate

### 実行
terraform apply

### 状態の確認
terraform show

### 終了
terraform destroy

### 変数の内容を変更できる
terraform apply -var 'instance_name=YetAnotherName'

## cloudfromation
### aws cliのインストール
https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2.html

### aws cli 初期設定
aws configure --profile "profile"
export AWS_PROFILE='terraform' 
export AWS_ACCESS_KEY_ID='アクセスキー' 
export AWS_SECRET_ACCESS_KEY='シークレットアクセスキー'
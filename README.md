文言例
terraform.tfvars の作成

cp terraform.tfvars.example 
terraform.tfvars

terraform.tfvarsに実値を記入
（機密情報を含むためリポジトリに追加しないでください）

必要変数（例）

db_username: DB のユーザー名（必須）
db_password: DB のパスワード（必須, sensitive）
key_name: EC2 用キーペア名（必須）
notification_email: 通知先メール（必須）
my_ip: SSH 許可 IP（例: x.x.x.x/32）

注意事項

terraform.tfvars は機密情報を含むのでコミットしないでください。terraform.tfvars.example を用意しています。
SNS のメールは受信側で Confirm が必要です。Confirmed 状態を確認してください。
誤って機密をコミットした場合は直ちに該当シークレットをローテーションし、履歴のクリーンアップを行ってください（担当: とおる）。
README.md

## Terraform + Ansible によるAWS環境の完全自動構築（CI/CD対応）

<img width="675" height="369" alt="スクリーンショット 2025-10-07 163900" src="https://github.com/user-attachments/assets/95a3bd18-b098-4779-afed-73d28d1a6d49" />


このプロジェクトは、**Terraform** と **Ansible** を組み合わせて、AWS環境構築からアプリケーションデプロイまでを **Push一つで完全自動化** した学習成果物です。  
**GitHub Actions** によるCI/CDパイプラインで、インフラ構築からアプリ起動確認、ブラウザ上での動作確認までを自動実行します。

---

## 概要

Terraformを使用して、以下のAWSリソースを自動構築しました。
固定値のみ設定値を記載しています。

- VPC（CIDR: 10.0.0.0/16）  
- Public subnets
  ```
  AZ: ap-northeast-1a, CIDR: 10.0.1.0/24
  AZ: ap-northeast-1c, CIDR: 10.0.3.0/24
- Private subnets
  ```
  AZ: ap-northeast-1a, CIDR: 10.0.2.0/24
  AZ: ap-northeast-1c, CIDR: 10.0.4.0/24
- InternetGateway　
- PublicRouteTable / PrivateRoutetable
- EC2（Amazon Linux 2, t2.micro）
- RDS
  ```bash
  identifier              = "aws-study-rds"
  engine                  = "mysql"
  engine_version          = "8.0.39"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
- ALBターゲットグループ
  ```bash
  name     = "aws-study-tg"
  port     = 8080
  protocol = "HTTP"
- ALBリスナー
  ```bash
  port              = 80
  protocol          = "HTTP"
  ```
- セキュリティグループ設定（SSH, HTTP, 8080, RDSアクセス等）

**ALB**
```bash
  ingress
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  egress
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
```
**EC2**
```bash
　ingress  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 

  ingress
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  ingress
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 

  egress 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
```
**RDS**
```bash
 ingress 
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"

  egress
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
```

- CloudWatch（メトリクス、アラーム）
```bash
  alarm_name          = "EC2HighCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "実運用を意識して70％に変更"
```
- SNS（メール通知設定）
   protocol  = "email"
- WAF（WebACL + CloudWatch Logs連携）
- IAM ロール（WAFログ送信用等）  
- S3（Backend用 / アプリJARファイル格納用）

---

## 使用技術

| カテゴリ | 使用技術 |
|-----------|-----------|
| インフラ構築 | Terraform 1.13.3 |
| 構成管理・自動化 | Ansible 2.x |
| CI/CD | GitHub Actions |
| AWSサービス | VPC, EC2, RDS (MySQL), ALB, CloudWatch, SNS, WAF, IAM, S3 |
| 開発環境 | VSCode / GitHub / PowerShell / AWS CLI |
| OS | Amazon Linux 2 |
| 言語・ランタイム | Java 17 (Amazon Corretto) |
| ビルドツール | Gradle 8.11.1 |
| フレームワーク | Spring Boot 3.2.2 |
| DB | MySQL 8.0.39 |

---
## リポジトリ構成

```bash
terraform-study/
├── .github/workflows/
│   └──  terraform-ci.yaml    # Terraform用CI/CDワークフロー
│    
├── ansible/
│   └── playbook.yml   # Ansible構成管理プレイブック
│
├── modules/    # 各AWSリソースをモジュール化
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── rds/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── alb/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   ├── waf/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   │
│   └── s3/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
├── main.tf                          # メイン構成ファイル
├── providers.tf                     # プロバイダー設定
├── variables.tf                     # 変数定義
├── outputs.tf                       # 出力値定義
├── terraform.tfvars                 # サンプル変数ファイル
├── README.md                        # このファイル
├── backend.tf
├── main.tftest.hcl
├── .gitignore                       # Git 除外設定
├── .terraform.lock.hcl

```
---

## 構成と動作概要

1. GitHubへのPushをトリガーにCI/CDを自動実行  
2. **Terraform** によりAWSリソースを構築  
   - VPC / Subnet / EC2 / RDS / ALB / WAF / CloudWatch / SNS などを自動生成  
3. **出力値（EC2 IP・RDS Endpoint・S3 Bucket名）** を後続ジョブに渡す  
4. **Spring Bootアプリ** をClone → Gradleでビルド → S3へアップロード  
5. **Ansible** がEC2へ接続し、JAR配置・DB初期化・アプリ起動を自動化  
6. HTTP 200応答を確認し、アプリケーションが正常稼働していることを検証  
7. 最終的に、ブラウザから `http://<EC2_IP>:8080` にアクセスして動作確認

---

## ✅ 確認項目

| 項目 | 確認内容 |
|------|-----------|
| GitHub Actions | 全ジョブ（terraform, build_upload, ansible）が成功 |
| AWSリソース | EC2 / RDS / S3 / ALB / WAF / SNS / CloudWatch が作成済み |
| S3バケット | アプリJARファイルが格納されていること |
| EC2 | Java 17・MySQL Client・Spring Bootアプリが稼働していること |
| HTTP疎通 | `http://<EC2_IP>:8080` へアクセスしステータス200を確認 |

---

## GitHub Actions ワークフロー概要（terraform-ci.yaml）

ワークフローは3ジョブで構成：

| ジョブ名 | 内容 |
|-----------|------|
| **terraform** | Terraformの初期化、検証、リソース構築を実施。構築後にEC2 IP・RDS Endpoint・S3バケット名を出力|
| **build_upload** | Spring Bootアプリを外部リポジトリからClone → GradleでJARビルド → S3へアップロード |
| **ansible** | Ansible Playbookを実行し、EC2上にアプリ展開・DB初期化・サービス起動・HTTP応答確認まで自動化 |

---

## Ansible Playbook概要（playbook.yml）

| 処理フェーズ | 実行内容 |
|---------------|-----------|
| 依存関係導入 | pip3 / boto3 / botocore / PyMySQL / community.mysql をインストール |
| 環境設定 | OSアップデート、Java 17、MySQLクライアントを導入 |
| アプリ配置 | /opt/myapp にJARファイルをS3からダウンロード、SQLを抽出 |
| DB初期化 | RDSへの接続確認後、データベース作成・SQL適用 |
| サービス化 | systemd によりSpring Bootアプリを常駐化 |
| 動作確認 | 8080ポートにHTTPアクセスし、アプリ動作確認 |

---

## デプロイ手順

1. `test` ブランチに Push  
2. GitHub Actions が自動でワークフロー実行  
3. Terraform → Ansible の順で自動デプロイ  
4. 完了後、ブラウザで `http://<EC2_IP>:8080` にアクセスし動作確認

---

## 学んだこと・工夫した点

- **完全自動化の難しさと依存関係整理**
  
  多数のリソース・タスク・変数間依存を誤らずコード化する点に非常に苦労した。転職活動を終え次第、再度勉強したい。
  
- **デバッグタスクの活用**
  
  `debug` や `register` を駆使して、ジョブ間の出力値やファイルパスの動きを把握する経験を得た
  実運用でもトラブルシュートに役立つと実感

- **環境変数とSecret管理の重要性**
  
  AWS資格情報やDB認証情報をGitHub Secretsで安全に扱う設計を学習した

- **手動構築からコード化への移行経験**
  
  AWSマネジメントコンソールで行っていた構築手順を全てコード化し、再現性と効率性を実現する学習をした

- **インフラのコード化スキルの必要性**
  
  現場ではCloudFormationやTerraformを用いて、Ansibleで構築を自動化することが一般的である意味が理解できた。
  コード化するのは大変だが、AWSマネジメントコンソールでこれ以上のリソースを追加して環境構築をするであろう実務では、把握のしにくさ、間違ったときのFBの受けにくさ等があり限度があることを理解。
  
---

## 今後の改善点

- Terraformの変数やモジュールを整理し、再利用性と保守性を向上
- Terraformの出力を**JSON形式で管理**し、他ツールやスクリプトとの連携を容易にする  
- Ansible Playbookをrole化やタスク分割で整理し、チーム開発でも扱いやすくする  
- CloudWatch LogsやALBアクセスログを、集約・可視化して運用監視を強化
  
---

## ⚠️ 注意事項

- AWS課金とSecrets管理には十分注意してください。  
- エラー発生時は `debug` タスクなどを活用して原因を特定してください。
- 環境変数化は以下のように使用すること

---

## 環境変数化した変数一覧表

| 変数名                  | 設定例                     | 説明         | 必須 | 備考              |
| -------------------- | ----------------------- | ---------- | -- | --------------- |
| `db_username`        | `"my_user"`        | DB のユーザー名  | ✅  |                 |
| `db_password`        | `"my_password"`    | DB のパスワード  | ✅  | sensitive       |
| `key_name`           | `"my-ec2-key"`          | EC2 用キーペア名 | ✅  |                 |
| `notification_email` | `"my@gmail.com"` | 通知先メールアドレス | ✅  | SNS 通知確認が必要     |
| `my_ip`              | `"123.45.67.89/32"`     | SSH 許可 IP  | ✅  | 例: `x.x.x.x/32` |


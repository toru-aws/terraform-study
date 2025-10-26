# Terraform + Ansible によるAWS環境の完全自動構築（CI/CD対応）

このプロジェクトは、**Terraform** と **Ansible** を組み合わせて  
AWS環境構築からアプリケーションデプロイまでを **Push一つで完全自動化** した学習成果物です。  
CI/CD パイプラインには **GitHub Actions** を使用し、  
Terraformによるリソース構築
→ Spring Boot アプリのビルド・S3アップロード 
→ AnsibleによるEC2への自動デプロイ  
までの一連の流れを実現しています。

---

## 概要

Terraformを用いてCloudFormationで作成したAWSリソース構成を再現しつつ、  
CI/CD用のS3バケットを追加して完全自動化を実現しました。  
GitHubへのPushをトリガーとして、インフラ構築からアプリケーション起動確認まで自動実行されます。

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

## 構成図（Architecture）

構成概要：  
1. GitHubへのPushをトリガーにCI/CD実行  
2. TerraformでAWSリソースを自動構築  
3. 出力値（EC2 IP / RDS Endpoint / S3 Bucket名）を後続ジョブへ引き渡し  
4. Spring BootアプリをClone・ビルドしS3へアップロード  
5. AnsibleでEC2へJARを自動配置・DB初期化・サービス起動  
6. 最後にHTTP 200応答で稼働確認  

---
## リポジトリ構成

```bash
terraform-study/
├── .github/
│   └── workflows/
│       └── terraform-ci.yaml    # Terraform 用 CI/CD ワークフロー
│
├── ansible/
│   └── playbook.yml   # Ansible 構成管理プレイブック
│
├── modules/    # 各 AWS リソースをモジュール化
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
├── terraform.tfvars.example         # サンプル変数ファイル
├── versions.tf                      # Terraform バージョン指定
├── .gitignore                       # Git 除外設定
├── README.md                        # このファイル

```
---

## TerraformによるAWSリソース構築

- VPC（CIDR: 10.0.0.0/16）  
- Public / Private サブネット（2つのAZに配置）  
- InternetGateway / RouteTable  
- EC2（Amazon Linux 2, t2.micro）  
- RDS（MySQL 8.0.39）  
- ALB（Application Load Balancer）およびターゲットグループ  
- セキュリティグループ設定（SSH, HTTP, 8080, RDSアクセス等）  
- CloudWatch（メトリクス、アラーム）  
- SNS（メール通知設定）  
- WAF（WebACL + CloudWatch Logs連携）  
- IAM ロール（WAF ログ送信用等）  
- S3（Backend用 / アプリJARファイル格納用）

---

## GitHub Actions ワークフロー概要（terraform-ci.yaml）

ワークフローは3ジョブで構成：

| ジョブ名 | 内容 |
|-----------|------|
| **terraform** | Terraformの初期化、検証、リソース構築を実施。構築後にEC2 IP・RDS Endpoint・S3バケット名を出力。 |
| **build_upload** | Spring Bootアプリを外部リポジトリからClone → GradleでJARビルド → S3へアップロード。 |
| **ansible** | Ansible Playbookを実行し、EC2上にアプリ展開・DB初期化・サービス起動・HTTP応答確認まで自動化。 |

---

## Ansible Playbook概要（playbook.yml）

| 処理フェーズ | 実行内容 |
|---------------|-----------|
| 依存関係導入 | pip3 / boto3 / botocore / PyMySQL / community.mysql をインストール |
| 環境設定 | OSアップデート、Java 17、MySQLクライアントを導入 |
| アプリ配置 | /opt/myapp にJARファイルをS3からダウンロード、SQLを抽出 |
| DB初期化 | RDSへの接続確認後、データベース作成・SQL適用 |
| サービス化 | systemd によりSpring Bootアプリを常駐化 |
| 動作確認 | 8080ポートにHTTPアクセスし、ステータス200を確認 |

---

## デプロイ手順

1. `test`ブランチにPush  
2. GitHub Actionsが自動でワークフローを起動  
3. TerraformでAWSリソースを作成  
4. Spring BootアプリをビルドしてS3へアップロード  
5. AnsibleがEC2上にアプリをデプロイ・起動  
6. 最終ステップでHTTP 200応答を確認（自動）

---

## 動作確認

| 確認項目 | 内容 |
|-----------|------|
| GitHub Actions | 全ジョブがオールグリーンで完了 |
| Terraformリソース | EC2 / RDS / S3 / ALB / WAF / CloudWatch / SNS が作成されていることを確認 |
| S3バケット | JARファイルがアップロードされていることを確認 |
| EC2 | Java17, MySQL client, アプリが正常に稼働していることを確認 |
| HTTP疎通 | `http://<EC2_IP>:8080` にアクセスし、アプリが起動していることを確認 |

---

## 学んだこと・工夫した点

- **完全自動化の難しさと依存関係整理**  
  多数のリソース・タスク・変数間依存を誤らずコード化する点に苦労。  
  Ansible内で `--extra-vars` を使用する必要性を学び、CI/CD全体の変数フローを整理。  

- **デバッグタスクの活用**  
  `debug` や `register` を駆使して、ジョブ間の出力値やファイルパスの動きを把握。  
  実運用でもトラブルシュートに役立つと実感。  

- **環境変数とSecret管理の重要性**  
  AWS資格情報やDB認証情報をGitHub Secretsで安全に扱う設計を学習。  

- **手動構築からコード化への移行体験**  
  AWSマネジメントコンソールで行っていた構築手順を全てコード化し、再現性と効率性を実現。  

- **インフラのコード化スキルの必要性**  
  現場ではTerraformやAnsibleで構築を自動化することが一般的であると理解。  

---

## 今後の改善点

- Terraformの`variables.tf`を整理し、再利用性を向上
- Terraformの出力をより汎用的なJSON形式で管理し、外部ツールとの連携を検討
- Ansible Playbookの役割分割（role化）による保守性向上
- CI/CDのブランチ戦略（`dev` / `staging` / `prod`）に対応したパイプライン設計
- CloudWatch LogsとALBアクセスログの集約による運用監視の強化

---

## ⚠️　備考・注意事項

- 本プロジェクトは学習目的で構築していますが、**実務に近い構成と運用フロー**を意識して作成しています。  
- Terraform / Ansible / GitHub Actions の組み合わせにより、AWS環境の構築からアプリのデプロイまでを完全自動化しています。  
- 利用時はAWS課金とSecretsの管理に注意してください。
- エラーが起きた際には必要に応じて、デバック処理をコードに入れて各項目のTask等を確認して解決してください。

## 環境変数化した変数一覧表

| 変数名                  | 設定例                     | 説明         | 必須 | 備考              |
| -------------------- | ----------------------- | ---------- | -- | --------------- |
| `db_username`        | `"my_user"`        | DB のユーザー名  | ✅  |                 |
| `db_password`        | `"my_password"`    | DB のパスワード  | ✅  | sensitive       |
| `key_name`           | `"my-ec2-key"`          | EC2 用キーペア名 | ✅  |                 |
| `notification_email` | `"my@gmail.com"` | 通知先メールアドレス | ✅  | SNS 通知確認が必要     |
| `my_ip`              | `"123.45.67.89/32"`     | SSH 許可 IP  | ✅  | 例: `x.x.x.x/32` |


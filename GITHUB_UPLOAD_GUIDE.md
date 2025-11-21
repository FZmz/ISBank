# ISBank 项目上传 GitHub 指南

## 📋 准备工作

### 1. 检查 Git 配置

```bash
# 配置用户名和邮箱（如果还没配置）
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 查看当前配置
git config --list
```

### 2. 初始化 Git 仓库（如果还没初始化）

```bash
# 在项目根目录执行
cd /data/mj/ISBank

# 初始化 Git 仓库
git init

# 查看状态
git status
```

## 📦 文件过滤说明

`.gitignore` 文件已配置，会自动过滤以下内容：

### ✅ 会被忽略的文件/目录

- **Maven 构建输出**: `target/` 目录
- **Node.js 依赖**: `frontend/node_modules/` 目录
- **IDE 配置**: `.idea/`, `.vscode/`, `.settings/` 等
- **编译文件**: `*.class`, `*.jar`, `*.war` 等
- **日志文件**: `*.log`
- **临时文件**: `*.tmp`, `*.swp`, `*.bak` 等
- **操作系统文件**: `.DS_Store`, `Thumbs.db` 等
- **环境变量**: `.env`, `.env.local` 等

### ✅ 会被保留的重要文件

- **源代码**: 所有 `.java`, `.vue`, `.ts`, `.js` 文件
- **配置文件**: `pom.xml`, `package.json`, `application.yml` 等
- **Docker 文件**: `Dockerfile`, `docker-compose.yml`
- **Kubernetes 配置**: `k8s/` 目录下的所有 YAML 文件
- **脚本文件**: `scripts/` 目录下的所有脚本
- **文档**: 所有 `.md` 文件
- **数据库脚本**: `init-database.sql`

## 🚀 上传到 GitHub

### 方法 1: 使用 GitHub 网页创建仓库

#### 步骤 1: 在 GitHub 创建新仓库

1. 登录 GitHub: https://github.com
2. 点击右上角 `+` → `New repository`
3. 填写仓库信息:
   - **Repository name**: `ISBank` 或 `isbank-microservices`
   - **Description**: `韧性银行微服务系统 - Spring Cloud + Vue3 完整实现`
   - **Visibility**: 选择 `Public` 或 `Private`
   - **不要勾选** "Initialize this repository with a README"（因为本地已有）
4. 点击 `Create repository`

#### 步骤 2: 添加远程仓库并推送

```bash
# 添加所有文件到暂存区
git add .

# 提交到本地仓库
git commit -m "Initial commit: ISBank microservices system"

# 添加远程仓库（替换 YOUR_USERNAME 为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/ISBank.git

# 推送到 GitHub（首次推送）
git branch -M main
git push -u origin main
```

### 方法 2: 使用 SSH 方式（推荐）

#### 步骤 1: 生成 SSH 密钥（如果还没有）

```bash
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "your.email@example.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub
```

#### 步骤 2: 添加 SSH 密钥到 GitHub

1. 复制上面命令输出的公钥
2. 登录 GitHub → Settings → SSH and GPG keys
3. 点击 `New SSH key`
4. 粘贴公钥，点击 `Add SSH key`

#### 步骤 3: 使用 SSH 推送

```bash
# 添加远程仓库（SSH 方式）
git remote add origin git@github.com:YOUR_USERNAME/ISBank.git

# 推送
git branch -M main
git push -u origin main
```

## 📊 验证上传内容

### 检查将要上传的文件

```bash
# 查看将要提交的文件
git status

# 查看被忽略的文件
git status --ignored

# 查看文件大小统计
git ls-files | xargs du -sh | sort -h | tail -20
```

### 预期的文件结构

```
ISBank/
├── account-service/          # 账户服务
├── common/                   # 公共模块
├── docker/                   # Docker 配置
├── eureka-server/            # 服务注册中心
├── frontend/                 # Vue3 前端（不含 node_modules）
├── gateway-service/          # 网关服务
├── k8s/                      # Kubernetes 配置
├── ledger-service/           # 账本服务
├── notification-service/     # 通知服务
├── risk-service/             # 风控服务
├── scripts/                  # 部署脚本
├── transfer-service/         # 转账服务
├── .gitignore               # Git 忽略配置
├── pom.xml                  # Maven 父 POM
├── README.md                # 项目说明
├── init-database.sql        # 数据库初始化脚本
└── 其他文档...
```

## 🔧 常见问题

### 问题 1: 文件太大无法推送

如果遇到文件太大的问题：

```bash
# 检查大文件
find . -type f -size +50M

# 如果有大文件需要忽略，添加到 .gitignore
echo "path/to/large/file" >> .gitignore
```

### 问题 2: 已经提交了不该提交的文件

```bash
# 从 Git 中删除但保留本地文件
git rm --cached path/to/file

# 从 Git 中删除整个目录
git rm -r --cached path/to/directory

# 重新提交
git commit -m "Remove unnecessary files"
```

### 问题 3: 推送失败

```bash
# 如果远程有更新，先拉取
git pull origin main --rebase

# 然后再推送
git push origin main
```

## 📝 后续维护

### 日常提交流程

```bash
# 1. 查看修改
git status

# 2. 添加修改的文件
git add .

# 3. 提交
git commit -m "描述你的修改"

# 4. 推送
git push
```

### 创建 .gitattributes（可选）

为了确保跨平台一致性，可以创建 `.gitattributes` 文件：

```bash
cat > .gitattributes << 'EOF'
# 自动检测文本文件并规范化行尾
* text=auto

# Java 源文件
*.java text eol=lf
*.xml text eol=lf
*.properties text eol=lf
*.yml text eol=lf
*.yaml text eol=lf

# 前端文件
*.js text eol=lf
*.ts text eol=lf
*.vue text eol=lf
*.json text eol=lf
*.css text eol=lf
*.html text eol=lf

# Shell 脚本
*.sh text eol=lf

# 二进制文件
*.jar binary
*.png binary
*.jpg binary
*.gif binary
EOF
```

## ✅ 完成检查清单

- [ ] 已配置 Git 用户名和邮箱
- [ ] 已创建 GitHub 仓库
- [ ] 已检查 `.gitignore` 配置
- [ ] 已执行 `git add .`
- [ ] 已执行 `git commit`
- [ ] 已添加远程仓库
- [ ] 已成功推送到 GitHub
- [ ] 在 GitHub 网页上验证文件已上传

---

**提示**: 推送前建议先在本地测试构建，确保项目可以正常运行！


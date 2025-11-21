# 多阶段构建 - 构建阶段
FROM node:18-alpine AS builder

WORKDIR /build

# 复制package文件
COPY frontend/package*.json ./

# 安装依赖
RUN npm install --registry=https://registry.npmmirror.com

# 复制源代码
COPY frontend/ ./

# 构建生产版本（跳过类型检查以加快构建速度）
RUN npm run build:prod

# 运行阶段
FROM nginx:alpine

# 复制构建产物到nginx目录
COPY --from=builder /build/dist /usr/share/nginx/html

# 复制nginx配置
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]


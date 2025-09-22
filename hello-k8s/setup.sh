#!/bin/bash
set -e

echo "📦 ディレクトリとファイルを生成中..."

# ディレクトリ作成
mkdir -p app k8s

# アプリコード
cat > app/app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Kubernetes!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

# Python依存
echo "flask" > app/requirements.txt

# Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY app/ /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
EOF

# Deployment
cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-k8s
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-k8s
  template:
    metadata:
      labels:
        app: hello-k8s
    spec:
      containers:
      - name: hello-k8s
        image: hello-k8s:v1
        ports:
        - containerPort: 5000
EOF

# Service
cat > k8s/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: hello-k8s-service
spec:
  selector:
    app: hello-k8s
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: NodePort
EOF

echo "✅ ファイル生成完了！"
echo ""
echo "次のコマンドを実行してください："
echo "1. docker build -t hello-k8s:v1 ."
echo "2. kubectl apply -f k8s/"
echo "3. kubectl get pods"
echo "4. kubectl get svc"

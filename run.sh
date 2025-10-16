#!/usr/bin/env bash

echo "🚀 Memulai environment nix..."
nix-shell --pure --packages python310 chromium curl git cacert openssl lsof --run '

echo "✅ Environment siap."

# 🔹 Repo Git
REPO_URL="https://github.com/vokerjok/joko-web.git"
FOLDER="joko-web"

# 🔹 Clone repo jika belum ada
if [ ! -d "$FOLDER" ]; then
    echo "📥 Clone repo dari $REPO_URL ..."
    git clone "$REPO_URL"
else
    echo "✅ Repo sudah ada, skip download"
fi

# 🔹 Masuk folder repo
cd "$FOLDER" || { echo "❌ Gagal masuk folder $FOLDER"; exit 1; }

# 🔹 Pilih port bebas mulai dari 8090
PORT=8090
while lsof -i :$PORT >/dev/null 2>&1; do
    PORT=$((PORT+1))
done
echo "📦 Menggunakan port $PORT"

# 🔹 Cek index.html ada atau tidak
FILE="index.html"
if [ ! -f "$FILE" ]; then
    echo "⚠️ $FILE tidak ditemukan, Chromium akan buka root /"
    URL="http://localhost:$PORT/"
else
    URL="http://localhost:$PORT/$FILE"
fi

# 🔹 Cek apakah server Python sudah jalan
SERVER_PID=$(lsof -ti tcp:$PORT)
if [ -n "$SERVER_PID" ]; then
    echo "✅ Server sudah jalan di port $PORT, skip start server"
else
    echo "📦 Menjalankan server Python di http://localhost:$PORT ..."
    python3 -m http.server $PORT &
    sleep 2
fi

# 🔹 Cek apakah Chromium sudah jalan
CHROME_PID=$(pgrep -f "chromium.*$URL")
if [ -n "$CHROME_PID" ]; then
    echo "✅ Chromium sudah jalan ke $URL, skip start Chromium"
else
    echo "🌐 Membuka $URL dengan Chromium headless..."
    chromium --headless --disable-gpu --no-sandbox --remote-debugging-port=9222 "$URL" &
fi

# 🔹 Loop refresh otomatis setiap 1 jam
while true; do
    echo "🔄 Refresh halaman $URL ..."
    curl -s -X POST http://localhost:9222/json/reload > /dev/null
    sleep 3600
done

'

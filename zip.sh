version=v2.2
versionCode=22

# module.prop
sed -e "s/version=.*/version=${version}/" module.prop > module.prop.tmp && mv module.prop.tmp module.prop
sed -e "s/versionCode=.*/versionCode=${versionCode}/" module.prop > module.prop.tmp && mv module.prop.tmp module.prop

# zip
rm -f perf-limit-xiaomi-12*.zip
zip -vr perf-limit-xiaomi-12-$version.zip . -x "*.DS_Store" -x "*.zip" -x ".git/*" -x ".gitignore" -x ".github" -x "README.md" -x "LICENSE" -x "docs" -x "zip.sh" -x "test.sh"

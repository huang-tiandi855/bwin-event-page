flutter build web --release --no-sound-null-safety --web-renderer html
cd build/web
zip -q -r dist.zip ./*
scp  dist.zip server@192.168.1.9:/home/server/yjmh/h5/test
ssh  server@192.168.1.9 "/home/server/yjmh/h5/test/test_dist.sh"
rm -f dist.zip

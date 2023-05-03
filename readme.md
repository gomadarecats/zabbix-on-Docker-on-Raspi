### build
- must be set build-arg ZBXPASSWD
```
docker build --build-arg ZBXPASSWD=<PASSWORD> -t tag/image .
```
### run
```
docker run -d -p 80:8080 tag/image
```

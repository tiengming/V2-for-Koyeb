FROM nginx:latest
EXPOSE 80
WORKDIR /app
USER root

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh ./
COPY version_anchor.txt ./

RUN apt-get update && apt-get install -y wget unzip iproute2 tini && \
    rm -rf /var/lib/apt/lists/* && \
    V2RAY_VER=$(cat version_anchor.txt | tr -d '\n\r') && \
    wget -O temp.zip "https://github.com/v2fly/v2ray-core/releases/download/${V2RAY_VER}/v2ray-linux-64.zip" && \
    unzip temp.zip v2ray geoip.dat geosite.dat && \
    rm -f temp.zip && \
    # 使用 base64 -di 忽略所有因换行产生的非法字符（如反斜杠或回车），确保解码绝对成功
    echo 'ewogICAgImxvZyI6ewogICAgICAgICJsb2dsZXZlbCI6Indhcm5pbmciLAogICAgICAgICJhY2Nl\
c3MiOiIvZGV2L251bGwiLAogICAgICAgICJlcnJvciI6Ii9kZXYvbnVsbCIKICAgIH0sCiAgICAi\
aW5ib3VuZHMiOlsKICAgICAgICB7CiAgICAgICAgICAgICJwb3J0IjoxMDAwMCwKICAgICAgICAg\
ICAgInByb3RvY29sIjoidm1lc3MiLAogICAgICAgICAgICAibGlzdGVuIjoiMTI3LjAuMC4xIiwK\
ICAgICAgICAgICAgInNldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAiY2xpZW50cyI6WwogICAg\
ICAgICAgICAgICAgICAgIHsKICAgICAgICAgICAgICAgICAgICAgICAgImlkIjoiVVVJRCIsCiAg\
ICAgICAgICAgICAgICAgICAgICAgICJhbHRlcklkIjowCiAgICAgICAgICAgICAgICAgICAgfQog\
ICAgICAgICAgICAgICAgXQogICAgICAgICAgICB9LAogICAgICAgICAgICAic3RyZWFtU2V0dGlu\
Z3MiOnsKICAgICAgICAgICAgICAgICJuZXR3b3JrIjoid3MiLAogICAgICAgICAgICAgICAgIndz\
U2V0dGluZ3MiOnsKICAgICAgICAgICAgICAgICAgICAicGF0aCI6IlZNRVNTX1dTUEFUSCIKICAg\
ICAgICAgICAgICAgIH0KICAgICAgICAgICAgfQogICAgICAgIH0sCiAgICAgICAgewogICAgICAg\
ICAgICAicG9ydCI6MjAwMDAsCiAgICAgICAgICAgICJwcm90b2NvbCI6InZsZXNzIiwKICAgICAg\
ICAgICAgImxpc3RlbiI6IjEyNy4wLjAuMSIsCiAgICAgICAgICAgICJzZXR0aW5ncyI6ewogICAg\
ICAgICAgICAgICAgImNsaWVudHMiOlsKICAgICAgICAgICAgICAgICAgICB7CiAgICAgICAgICAg\
ICAgICAgICAgICAgICJpZCI6IlVVSUQiCiAgICAgICAgICAgICAgICAgICAgfQogICAgICAgICAg\
ICAgICAgXSwKICAgICAgICAgICAgICAgICJkZWNyeXB0aW9uIjoibm9uZSIKICAgICAgICAgICAg\
fSwKICAgICAgICAgICAgInN0cmVhbVNldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAibmV0d29y\
ayI6IndzIiwKICAgICAgICAgICAgICAgICJ3c1NldHRpbmdzIjp7CiAgICAgICAgICAgICAgICAg\
ICAgInBhdGgiOiJWTEVTU19XU1BBVEgiCiAgICAgICAgICAgICAgICB9CiAgICAgICAgICAgIH0K\
ICAgICAgICB9CiAgICBdLAogICAgIm91dGJvdW5kcyI6WwogICAgICAgIHsKICAgICAgICAgICAg\
InByb3RvY29sIjoiZnJlZWRvbSIsCiAgICAgICAgICAgICJzZXR0aW5ncyI6ewoKICAgICAgICAg\
ICAgfQogICAgICAgIH0KICAgIF0sCiAgICAiZG5zIjp7CiAgICAgICAgInNlcnZlcnMiOlsKICAg\
ICAgICAgICAgIjguOC44LjgiLAogICAgICAgICAgICAiOC44LjQuNCIsCiAgICAgICAgICAgICJs\
b2NhbGhvc3QiCiAgICAgICAgXQogICAgfQp9Cg==' | base64 -di > config.json && \
    chmod +x v2ray entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "./entrypoint.sh"]
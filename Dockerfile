FROM node:11.6.0-alpine AS builder
COPY . ./test-application
WORKDIR /test-application
RUN npm i
RUN $(npm bin)/ng build --prod

FROM nginx:stable-alpine
COPY --from=builder /test-application/dist/test-application/ /usr/share/nginx/html
# support running as arbitrary user which belogs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx
RUN chgrp -R root /var/cache/nginx

# users are not allowed to listen on priviliged ports
RUN sed -i.bak 's/listen\(.*\)80;/listen 8081;/' /etc/nginx/conf.d/default.conf
EXPOSE 8081

# comment user directive as master process is run as user in OpenShift anyhow
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

RUN addgroup nginx root
USER nginx


FROM node:14.21.3-alpine3.17 as build
WORKDIR /app
COPY ./app .
RUN npm install
RUN npm run build-prod

FROM nginx:stable-alpine
WORKDIR /app
RUN rm /usr/share/nginx/html/index.html
COPY --from=build /app/dist/letscodebyada-app /usr/share/nginx/html
EXPOSE 80
ENV API_URL http://
ENTRYPOINT ["/bin/sh",  "-c",  "envsubst < /usr/share/nginx/html/assets/env.template.js > /usr/share/nginx/html/assets/env.js && exec nginx -g 'daemon off;'"]

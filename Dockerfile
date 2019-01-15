ARG FROM
FROM $FROM
WORKDIR /src
ARG PACKAGE_JSON="package.json"
COPY ./${PACKAGE_JSON} /src/package.json
RUN yarn
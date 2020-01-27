# FROM defines the base image layer for node applications
FROM node:7
#ADD adds app.js to the root folder
ADD app.js /app.js 
#ENTRYPOINT runs `node app.js` when the container is started.
ENTRYPOINT ["node", "app.js"]
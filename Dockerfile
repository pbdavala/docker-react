# This composition takes care of two separate phases of build and run. 
# First we build, copy the built folder to run phase and execute run phase.
 
# specify a base image. Tagged as builder
FROM node:16-alpine as builder

# work dir setup in the container. Will be created if does not exist
WORKDIR '/app'

# Copy only package.json from current workdir "frontend" to the current workdir inside container.
COPY package.json .

# Install some dependencies
RUN npm install

# Copy NOW everything from current workdir "frontend" to the current workdir inside container.
# Straight copy because this is production build. We don't need volumes in docker-compose.
# We mapped volumes so as to refresh the container content as and when we change the files in Dev
COPY . .

# Default RUN Command. The build folder will be in /app/build in production container
RUN npm run build

##################################################################
# FROM is the delimiter for the previous block. Start of run phase.
#Specifying base image for nginx

FROM nginx

# Expose port 80 for Elastic Beanstalk. 80 is mapped for incoming traffic for container.
EXPOSE 80

# Copy the build folder from build phase location /app/build into the run container /usr/...
# Anything copied to /usr/share/nginx/html will be automatically served by nginx by default
COPY --from=builder /app/build /usr/share/nginx/html

# Default command to start nginx in a nginx container is automatically taken care of. No need to start nginx specifically.
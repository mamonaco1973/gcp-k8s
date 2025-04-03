# Use the official Ubuntu 24.04 base image
FROM ubuntu:24.04

# Update the package manager and install Python 3 and pip
RUN apt update -y && \                              
    apt install -y python3-pip && \
    apt-get clean && \                              
    mkdir /breakout && \                               
    chmod 777 /breakout

# Copy application files to the /tetris directory in the container
COPY index.html /breakout                       
COPY start.sh /breakout
RUN chmod +x /breakout/start.sh

# Expose port 8000 for HTTP server
EXPOSE 8000                                         

# Set the default command to run the python based HTTP server
ENTRYPOINT [ "/breakout/start.sh" ]          

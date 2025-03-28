# Use the official Ubuntu 24.04 base image
FROM ubuntu:24.04

# Update the package manager and install Python 3 and pip
RUN apt update -y && \                              
    apt install -y python3-pip && \                 
    apt-get clean && \                              
    mkdir /flask && \                               
    chmod 777 /flask                                

# Copy application files to the /flask directory in the container
COPY app.py /flask/                                 
COPY requirements.txt /flask/                       
COPY start_flask_app.sh /flask/                     

# Prepare the application environment
RUN chmod +x /flask/start_flask_app.sh && \         
    pip3 install -r /flask/requirements.txt --break-system-packages 

# Expose port 8000 for the Flask application
EXPOSE 8000                                         

# Set the default command to run the Flask application
ENTRYPOINT [ "/flask/start_flask_app.sh" ]          

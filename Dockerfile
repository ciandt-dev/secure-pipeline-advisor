FROM ubuntu:xenial-20210611

LABEL author="Rodrigo Alves"
LABEL author_github="https://github.com/ralves20"

# Install essentials
RUN apt-get update && \
    apt-get -y install module-assistant && \
    apt-get -y install build-essential && \
    apt-get -y install zip unzip nano curl wget && \
    apt-get -y install git;

# Install Java Projects Dependencies
RUN apt install -y openjdk-8-jdk

## Install Maven
RUN apt install -y maven;

## Install gradle
ARG GRADLE_VERSION=7.1
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp
RUN unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip
RUN ln -s /opt/gradle/gradle-${GRADLE_VERSION} /opt/gradle/latest
ENV GRADLE_HOME=/opt/gradle/latest
ENV PATH=$PATH:$GRADLE_HOME/bin


# Install Node Projects Dependencies
RUN cd ~/
RUN curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install -y nodejs
RUN cd -


# Google Chrome
RUN apt install -y xdg-utils libxkbcommon0 libgtk-3-0 libgbm1 libatspi2.0-0 libatk-bridge2.0-0 fonts-liberation
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb

# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_DIR /chromedriver
RUN mkdir -p $CHROMEDRIVER_DIR


# Install Chromedriver
RUN apt-get install -y wget xvfb unzip
RUN apt-get install libxi6 libgconf-2-4 -y
RUN CHROMEVER=$(google-chrome --product-version | grep -o "[^\.]*\.[^\.]*\.[^\.]*") && \
    DRIVERVER=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROMEVER") && \
    wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$DRIVERVER/chromedriver_linux64.zip"
RUN unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR
RUN chmod +x $CHROMEDRIVER_DIR/chromedriver

## Put Chromedriver into the PATH
ENV PATH $CHROMEDRIVER_DIR:$PATH

## set display port to avoid crash on webdrivers
ENV DISPLAY=:99


# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME





# SECURITY TOOLS

## Git Leaks
ARG GITLEAKS_VERSION=7.5.0
RUN wget https://github.com/zricethezav/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks-linux-amd64 -P /opt
RUN chmod +x /opt/gitleaks-linux-amd64
RUN ln -s /opt/gitleaks-linux-amd64 /usr/bin/gitleaks

## Dependency Check
ARG DEPENDENCY_CHECK_VERSION=6.2.2
RUN wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.2.2/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip -P /tmp
RUN unzip -d /opt/dependency-check /tmp/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip
RUN ls /opt/dependency-check
RUN chmod +x /opt/dependency-check/dependency-check/bin/dependency-check.sh
RUN ln -s /opt/dependency-check/dependency-check/bin/dependency-check.sh /usr/bin/dependency-check
RUN dependency-check

## SSLyze
RUN apt-get install -y python3
RUN curl https://bootstrap.pypa.io/pip/3.5/get-pip.py | python3
RUN pip install typing
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools pip
RUN pip install --upgrade sslyze

## Find Sec Bugs (FSB)
ARG FIND_SEC_BUGS_VERSION=1.11.0
RUN wget https://github.com/find-sec-bugs/find-sec-bugs/releases/download/version-1.11.0/findsecbugs-cli-${FIND_SEC_BUGS_VERSION}.zip -P /tmp
RUN unzip -d /opt/findsecbugs-fsb /tmp/findsecbugs-cli-${FIND_SEC_BUGS_VERSION}.zip
RUN ls /opt/findsecbugs-fsb
RUN chmod +x /opt/findsecbugs-fsb/findsecbugs.sh
RUN sed -i -e 's/\r$//' /opt/findsecbugs-fsb/findsecbugs.sh
RUN ln -s /opt/findsecbugs-fsb/findsecbugs.sh /usr/bin/findsecbugs
RUN findsecbugs -version



# Set config to job reports
RUN mkdir /opt/job-reports/
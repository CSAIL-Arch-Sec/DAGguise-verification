FROM ubuntu:18.04

# STEP1 tools
RUN apt update && \
    apt install -y --no-install-recommends \
    git \
    wget \
    curl \
    ca-certificates \
    vim \
    graphviz \
    make

# STEP2 racket8.3
RUN wget https://download.racket-lang.org/installers/8.3/racket-8.3-x86_64-linux-cs.sh && \
    bash racket-8.3-x86_64-linux-cs.sh --in-place --dest /usr/racket && \
    rm racket-8.3-x86_64-linux-cs.sh && \
    echo "export PATH=/usr/racket/bin:\$PATH" >> /root/.bashrc

# STEP3 rosette4.0
RUN git clone https://github.com/emina/rosette.git && \
    cd rosette && \
    git checkout 4.0 && \
    cd .. && \
    /usr/racket/bin/raco pkg install --no-docs --copy --auto -i -t dir rosette && \
    rm -rf rosette


#!/usr/bin/env bash

# STEP1 tools
apt-get update
apt-get install -y firefox graphviz make python3-pip

# STEP2 dask
# dask for batch experiments during develop to find the "k" used in k-indectuion
# can skip in final version since we already know the "k"
python3 -m pip install "dask[complete]"

# STEP3 racket8.3
wget https://download.racket-lang.org/installers/8.3/racket-8.3-x86_64-linux-cs.sh
bash racket-8.3-x86_64-linux-cs.sh --in-place --dest /usr/racket
rm racket-8.3-x86_64-linux-cs.sh
echo "export PATH=/usr/racket/bin:\$PATH" >> /home/vagrant/.bashrc

# STEP4 rosette4.0
git clone https://github.com/emina/rosette.git
cd rosette && git checkout 4.0 && cd ..
/usr/racket/bin/raco pkg install --no-docs --copy --auto -i -t dir rosette
rm -rf rosette


if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

rsync -av --exclude=.DS_Store script src rosette@aws:PrjDAG/$1

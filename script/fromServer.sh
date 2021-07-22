if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

rsync -av rosette@aws:PrjDAG/$1/result/ ./result/$1

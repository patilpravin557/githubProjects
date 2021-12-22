db2 connect to mall user db2inst1 using diet4coke

while :
do
     db2 -xvf connect.snap.sql
     cat connections.tmp.csv >> connections.csv
     sleep 2
done

db2 connect reset

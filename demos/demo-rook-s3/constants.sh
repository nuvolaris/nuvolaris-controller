AWS_HOST=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_HOST}') 
PORT=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_PORT}') 
BUCKET_NAME=$(kubectl -n nuvolaris get cm ceph-bucket -o jsonpath='{.data.BUCKET_NAME}') 
AWS_ACCESS_KEY_ID=$(kubectl -n nuvolaris get secret ceph-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode) 
AWS_SECRET_ACCESS_KEY=$(kubectl -n nuvolaris get secret ceph-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode) 

echo $AWS_HOST
echo $PORT
echo $BUCKET_NAME
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

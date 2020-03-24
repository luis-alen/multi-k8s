# automatically generate new tags so kubernetes doesn't think nothing has changed on our deployments
# because pods are already running :latest. Instead pods will run :$SHA and images/pods will be
# automatically updated
docker build -t luisalen/multi-client:$SHA -t luisalen/multi-client:latest -f ./client/Dockerfile ./client
docker build -t luisalen/multi-server:$SHA -t luisalen/multi-server:latest -f ./server/Dockerfile ./server
docker build -t luisalen/multi-worker:$SHA -t luisalen/multi-worker:latest -f ./worker/Dockerfile ./worker

# .travis.yml already logged in so need to login again to push the built images
docker push luisalen/multi-client:latest
docker push luisalen/multi-client:$SHA
docker push luisalen/multi-server:latest
docker push luisalen/multi-server:$SHA
docker push luisalen/multi-worker:latest
docker push luisalen/multi-worker:$SHA

# gcloud auth and setup already done as well as kubectl on .travis.yml

kubectl apply -f k8s

# setup latest images

# kubectl set image <object type>/<object name> <container name>/<image>
# imperatively update our images
kubectl set image deployments/server-deployment server=luisalen/multi-server:$SHA
kubectl set image deployments/server-deployment server=luisalen/multi-client:$SHA
kubectl set image deployments/server-deployment server=luisalen/multi-worker:$SHA

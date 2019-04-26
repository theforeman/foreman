$ kubectl create namespace foreman
$ kubectl config set-context --current --namespace=foreman

$ kubectl create secret generic db-user-pass --from-literal=password=mysecretpass
$ kubectl create secret generic db-user --from-literal=username=postgres
$ kubectl create secret generic db-url --from-literal=url=postgres://postgres:mysecretpass@postgres/foreman_production?pool=5 
$ kubectl create secret generic secret-key-base --from-literal=secret-key-base=`bundle exec rake secret`

$ kubectl create -f volumes/postgres_volumes.yaml
$ kubectl create -f services/postgres_svc.yaml
$ kubectl create -f deployments/postgres_deploy.yaml
$ kubectl create -f jobs/setup.yaml
$ kubectl create -f services/rails_svc.yaml
$ kubectl create -f deployments/rails_deploy.yaml
$ kubectl create -f deployments/worker_deploy.yaml
$ kubectl create -f ingresses/ingress.yaml


